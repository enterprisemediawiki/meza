echo "******* Generating elasticsearch index *******"

source /opt/.deploy-meza/config.sh

disable_search_file="$m_deploy/public/wikis/$wiki_id/postLocalSettings.d/disable-search-update.php"

# disable search update in wiki-specific settings
# FIXME: May only work in monolithic case
echo -e "<?php\n\$wgDisableSearchUpdate = true;\n" > "$disable_search_file"

# Run script to generate elasticsearch index
cd "$m_mediawiki"
WIKI="$wiki_id" php "$m_mediawiki/extensions/CirrusSearch/maintenance/updateSearchIndexConfig.php" --startOver

# Remove search-update disable in wiki-specific settings
rm -f "$disable_search_file"

# Bootstrap the search index
#
# Note that this can take some time
# For large wikis read "Bootstrapping large wikis" in https://git.wikimedia.org/blob/mediawiki%2Fextensions%2FCirrusSearch.git/REL1_25/README
WIKI="$wiki_id" php "$m_mediawiki/extensions/CirrusSearch/maintenance/forceSearchIndex.php" --skipLinks --indexOnSkip
WIKI="$wiki_id" php "$m_mediawiki/extensions/CirrusSearch/maintenance/forceSearchIndex.php" --skipParse

echo "******* Elastic Search build index complete! *******"
