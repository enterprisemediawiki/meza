#!/bin/sh
#
# Reindexing of elasticsearch indices

# FIXME: Make MediaWiki stop updating search index before doing any of this

# Append this to the name of all indices: version of elasticsearch
version_quoted=$(curl localhost:9200 | jq .version.number)
version="${version_quoted%\"}"
version="${version#\"}"
reindex_suffix="$version"

# Get a list of all indices. Note, each index name is quoted like:
#
#	"mediawiki_cirrussearch_frozen_indexes"
#	"mw_cirrus_metastore"
#	"mw_cirrus_versions"
#	"wiki_demo_content_first"
#	"wiki_demo_general_first"
all_indices=$(curl localhost:9200/_stats/store | jq '.indices | keys | .[]')

# Loop over all the indices
while read -r index_quoted; do

	# print it quoted
	echo "... quoted index name = $index_quoted ..."

	# strip quotes from index_quoted and print it unquoted
	index="${index_quoted%\"}"
	index="${index#\"}"
	echo "... stripped quotes = $index ..."

	# FIXME: backup index ???

	# The old index will be made read-only during the reindexing process, after
	# which it will be deleted.
	curl -XPUT "localhost:9200/$index/_settings" -d '{"index" : {"blocks" : { "read_only": true } } }'

	# Indices will be reindexed to a new index called {name}-{reindex_suffix}
	curl -XPOST 'localhost:9200/_reindex' -d "{
	  \"source\": {
		\"index\": \"$index\"
	  },
	  \"dest\": {
		\"index\": \"$index-$reindex_suffix\"
	  }
	}"

	# Get list of aliases pointing to the original index. Will use after
	# deleting the original index.
	all_aliases_quotes=$(curl "localhost:9200/$index/_alias" | jq '.[] | .[] | keys | .[]')

	# Delete the old index (after making it not read-only)
	curl -XPUT "localhost:9200/$index/_settings" -d '{"index" : {"blocks" : { "read_only": false } } }'
	curl -XDELETE "http://localhost:9200/$index/"

	# The original index name will be added as an alias for the new index
	curl -XPOST "localhost:9200/_aliases" -d "
	{
		\"actions\" : [
			{ \"add\" : { \"index\" : \"$index-$reindex_suffix\", \"alias\" : \"$index\" } }
		]
	}"

	# Add any aliases that previously pointed to the old index to the new index
	while read -r alias_quoted; do

		an_alias="${alias_quoted%\"}"
		an_alias="${an_alias#\"}"

		curl -XPOST "localhost:9200/_aliases" -d "
		{
			\"actions\" : [
				{ \"add\" : { \"index\" : \"$index-$reindex_suffix\", \"alias\" : \"$an_alias\" } }
			]
		}"

	done <<< "$all_aliases_quotes"


done <<< "$all_indices"


# FIXME: If MediaWiki search-indexing disabled, reenable now
