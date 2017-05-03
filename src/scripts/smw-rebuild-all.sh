#!/bin/sh

source "/opt/.deploy-meza/config.sh"

cd "$m_htdocs/wikis"
for d in */; do

    wiki_id=${d%/}

	timestamp=$(date +%s)
	exception_log="$m_logs/smw-rebuilddata-exceptions-$wiki_id-$timestamp.log"
	out_log="$m_logs/smw-rebuilddata-out.$wiki_id.$timestamp.log"

    echo "Rebuilding SMW data for $wiki_id"
    echo "  Exception log (if req'd):"
    echo "    $exception_log"
    echo "  Output log:"
    echo "    $out_log"

	WIKI="$wiki_id" \
	php "$m_mediawiki/extensions/SemanticMediaWiki/maintenance/rebuildData.php" \
	-d 5 -v --ignore-exceptions \
	--exception-log="$exception_log" \
	> "$out_log"

	# If the above command had a failing exit code
	if [[ $? -ne 0 ]]; then

		# FIXME: add notification/warning system here
		echo "rebuildData FAILED for $wiki_id"

	#if the above command had a passing exit code (e.g. zero)
	else
		echo "rebuildData completed for $wiki_id"
	fi

done

