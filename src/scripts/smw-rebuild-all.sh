#!/bin/sh

source "/opt/meza/config/core/config.sh"

cd /opt/meza/htdocs/wikis
for d in */; do

    wiki_id=${d%/}
    echo "Rebuilding SMW data for $wiki_id"

	timestamp=$(date +%s)

	WIKI="$wiki_id" \
	php "$m_mediawiki/extensions/SemanticMediaWiki/maintenance/rebuildData.php" \
	-d 5 -v --ignore-exceptions \
	--exception-log="$m_logs/smw-rebuilddata-exceptions-$wiki_id-$timestamp.log" \
	> $m_logs/smw-rebuilddata-out.$wiki_id.$timestamp.log

	# If the above command had a failing exit code
	if [[ $? -ne 0 ]]; then

		# FIXME: add notification/warning system here
		echo "rebuildData FAILED for $wiki_id"

	#if the above command had a passing exit code (e.g. zero)
	else
		echo "rebuildData completed for $wiki_id"
	fi

done

