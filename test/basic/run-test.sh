#!/bin/sh
#
# "Automate" testing. But not really. Just do as much automatically as possible.

# Get config and check for root
source "/opt/meza/config/core/config.sh"
source "$m_scripts/shell-functions/base.sh"
rootCheck

# prompts from shell-functions/base.sh
prompt_mysql_root_pass

# Turn on debug
sed -r -i 's/mezaForceDebug = false/mezaForceDebug = true/g;' "$m_config/core/LocalSettings.php"


# Create a wiki
imports_dir=new
wiki_id=test_created_wiki
wiki_name="Test Created Wiki"
slackwebhook=n
source "$m_scripts/create-wiki.sh"


# Import a test wiki
cd /tmp
git clone "https://github.com/enterprisemediawiki/meza-test-cases"
imports_dir="/tmp/meza-test-cases/wikis"
source "$m_scripts/import-wikis.sh"

domain=`cat "$m_config/local/domain"`
demo=`curl --insecure "https://$domain/demo/api.php?action=query&meta=siteinfo&format=json" | grep -oh 'Demo Wiki' | head -1`
created=`curl --insecure "https://$domain/test_created_wiki/api.php?action=query&meta=siteinfo&format=json" | grep -oh 'Test Created Wiki' | head -1`
imported=`curl --insecure "https://$domain/import_test/api.php?action=query&meta=siteinfo&format=json" | grep -oh 'Import Test Wiki' | head -1`

echo
echo
echo "API Checks:"

if [ "$demo" = "Demo Wiki" ]; then
	echo "[PASS] Demo Wiki API check"
else
	echo "[FAIL] Demo Wiki API check"
fi

if [ "$created" = "Test Created Wiki" ]; then
	echo "[PASS] Created Wiki API check"
else
	echo "[FAIL] Created Wiki API check"
fi

if [ "$imported" = "Import Test Wiki" ]; then
	echo "[PASS] Imported Wiki API check"
else
	echo "[FAIL] Imported Wiki API check"
fi
