#!/bin/sh

source "/opt/meza/config/core/config.sh"

cd /opt/meza/htdocs/wikis
for d in */; do

    wiki_id=${d%/}
	timestamp=$(date +%s)

	out_log="$m_logs/search-index.$wiki_id.$timestamp.log"

    echo "Rebuilding index for $wiki_id"
    echo "  Output log:"
    echo "    $out_log"


	wiki_id="$wiki_id" bash /opt/meza/src/scripts/elastic-build-index.sh > "$out_log"

	# If the above command had a failing exit code
	if [[ $? -ne 0 ]]; then

		# FIXME: add notification/warning system here
		echo "elastic-build-index FAILED for $wiki_id"

	#if the above command had a passing exit code (e.g. zero)
	else
		echo "elastic-build-index completed for $wiki_id"
	fi

done
