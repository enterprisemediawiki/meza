bash printTitle.sh "Begin $0"

echo "******* Generating elasticsearch index *******"

# Add "$wgDisableSearchUpdate = true;"
sed -r -i 's/false/true/g;' "$m_htdocs/wikis/$wiki_id/config/disableSearchUpdate.php"


# Run script to generate elasticsearch index
cd "$m_mediawiki"
WIKI="$wiki_id" php "$m_mediawiki/extensions/CirrusSearch/maintenance/updateSearchIndexConfig.php"

# Remove $wgDisableSearchUpdate = true (updates should start heading to elasticsearch)
sed -r -i 's/true/false/g;' "$m_htdocs/wikis/$wiki_id/config/disableSearchUpdate.php"

# Bootstrap the search index
#
# Note that this can take some time
# For large wikis read "Bootstrapping large wikis" in https://git.wikimedia.org/blob/mediawiki%2Fextensions%2FCirrusSearch.git/REL1_25/README
WIKI="$wiki_id" php "$m_mediawiki/extensions/CirrusSearch/maintenance/forceSearchIndex.php" --skipLinks --indexOnSkip
WIKI="$wiki_id" php "$m_mediawiki/extensions/CirrusSearch/maintenance/forceSearchIndex.php" --skipParse

echo "******* Elastic Search build index complete! *******"
