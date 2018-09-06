# Bootstrapping large wikis
# -------------------------
# Since most of the load involved in indexing is parsing the pages in php we provide a few options
# to split the process into multiple processes. Don't worry too much about the database during this
# process.  It can generally handle more indexing processes then you are likely to be able to spawn.
#
# General strategy:
# 0.  Make sure you have a good job queue setup.  It'll be doing most of the work.  In fact, Cirrus
#     won't work well on large wikis without it.
# 1.  Generate scripts to add all the pages without link counts to the index.
# 2.  Execute them any way you like.
# 3.  Generate scripts to count all the links.
# 4.  Execute them any way you like.

source "/opt/.deploy-meza/config.sh"

CIRRUS_REBUILD="$m_meza_data/cirrus_rebuild"
CIRRUS_LOG="$CIRRUS_REBUILD/cirrus_log"
CIRRUS_SCRIPTS="$CIRRUS_REBUILD/cirrus_scripts"
wiki_id="iss"

# Step 1:
# In bash I do this:
#  export PROCS=5 #or whatever number you want
#  rm -rf cirrus_scripts
#  mkdir cirrus_scripts
#  mkdir cirrus_log
#  pushd cirrus_scripts
#  php extensions/CirrusSearch/maintenance/forceSearchIndex.php --queue --maxJobs 10000 --pauseForJobs 1000 \
#     --skipLinks --indexOnSkip --buildChunks 250000 |
#     sed -e 's/$/ | tee -a cirrus_log\/'$wiki'.parse.log/' |
#     split -n r/$PROCS
#  for script in x*; do sort -R $script > $script.sh && rm $script; done
#  popd

rm -rf "$CIRRUS_SCRIPTS"
mkdir -p "$CIRRUS_LOG"
mkdir -p "$CIRRUS_SCRIPTS"
cd "$CIRRUS_SCRIPTS"

WIKI_ID="$wiki_id" php "$m_mediawiki/extensions/CirrusSearch/maintenance/forceSearchIndex.php" --queue --maxJobs 10000 --pauseForJobs 1000 \
    --skipLinks --indexOnSkip --buildChunks 250000 | \
    sed -e 's/$/ | tee -a '$CIRRUS_LOG'\/'$wiki_id'.parse.log/' | \
    split -n r/$PROCS

for script in x*; do
	sort -R $script > $script.sh && rm $script;
done

# Step 2:
# Just run all the scripts that step 1 made.  Best to run them in screen or something and in the directory above
# cirrus_scripts.  So like this:
#  bash cirrus_scripts/xaa.sh

for script in "$CIRRUS_SCRIPTS/"*; do
	bash "$script"
done


# Step 3:
# In bash I do this:
#  pushd cirrus_scripts
#  rm *.sh
#  php extensions/CirrusSearch/maintenance/forceSearchIndex.php --queue --maxJobs 10000 --pauseForJobs 1000 \
#     --skipParse --buildChunks 250000 |
#     sed -e 's/$/ | tee -a cirrus_log\/'$wiki'.parse.log/' |
#     split -n r/$PROCS
#  for script in x*; do sort -R $script > $script.sh && rm $script; done
#  popd

cd "$CIRRUS_SCRIPTS"
rm *.sh

WIKI_ID="$wiki_id" php "$m_mediawiki/extensions/CirrusSearch/maintenance/forceSearchIndex.php" --queue --maxJobs 10000 --pauseForJobs 1000 \
	--skipParse --buildChunks 250000 | \
	sed -e 's/$/ | tee -a '$CIRRUS_LOG'\/'$wiki_id'.parse.log/' | \
	split -n r/$PROCS

for script in x*; do
	sort -R $script > $script.sh && rm $script;
done



# Step 4:
# Same as step 2 but for the new scripts.  These scripts put more load on Elasticsearch so you might want to run
# them just one at a time if you don't have a huge Elasticsearch cluster or you want to make sure not to cause load
# spikes.

for script in "$CIRRUS_SCRIPTS/"*; do
	bash "$script"
done



# If you don't have a good job queue you can try the above but lower the buildChunks parameter significantly and
# remove the --queue parameter.
