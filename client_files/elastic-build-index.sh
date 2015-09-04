bash printTitle.sh "Begin $0"

echo "******* Generating elasticsearch index *******"

# Add "$wgDisableSearchUpdate = true;" to LocalSettings.php
cd "$m_mediawiki"
echo '$wgDisableSearchUpdate = true;' >> ./LocalSettings.php

# @todo: do we need to remove $wgSearchType = 'CirrusSearch' if it is present?
# it appears to work without doing that

# Run script to generate elasticsearch index
php "$m_mediawiki/extensions/CirrusSearch/maintenance/updateSearchIndexConfig.php"

# Remove $wgDisableSearchUpdate = true from LocalSettings.php (updates should start heading to elasticsearch)
sed -i -e 's/$wgDisableSearchUpdate = true;//g' LocalSettings.php

# Bootstrap the search index
#
# Note that this can take some time
# For large wikis read "Bootstrapping large wikis" in https://git.wikimedia.org/blob/mediawiki%2Fextensions%2FCirrusSearch.git/REL1_25/README
php "$m_mediawiki/extensions/CirrusSearch/maintenance/forceSearchIndex.php" --skipLinks --indexOnSkip
php "$m_mediawiki/extensions/CirrusSearch/maintenance/forceSearchIndex.php" --skipParse

echo "******* Elastic Search build index complete! *******"
