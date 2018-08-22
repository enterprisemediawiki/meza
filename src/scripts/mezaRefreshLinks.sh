#!/bin/sh
#
# Refresh links for a given wiki

if [ "$(whoami)" != "root" ]; then
	echo "Try running this script with sudo: \"sudo bash mezaRefreshLinks.sh\""
	exit 1
fi

# wiki id entery
while [ -z "$wiki_id" ]
do
echo -e "Enter the ID of the wiki and press [ENTER]: "
read wiki_id
done

num_pages=$(WIKI=$wiki_id php /opt/htdocs/mediawiki/maintenance/showSiteStats.php | grep "Total pages" | sed 's/[^0-9]*//g')
end_id=0
delta=2000

echo "Beginning refreshLinks.php script"
echo "  Total pages = $num_pages"
echo "  Doing it in $delta-page chunks to avoid memory leak"

while [ "$end_id" -lt "$num_pages" ]; do
start_id=$(($end_id + 1))
end_id=$(($end_id + $delta))
echo "Running refreshLinks.php from $start_id to $end_id"
WIKI=$wiki_id php /opt/htdocs/mediawiki/maintenance/refreshLinks.php --e "$end_id" -- "$start_id"
done

# Just in case there are more IDs beyond the guess we made with showSiteStats, run
# one more unbounded refreshLinks.php starting at the last ID previously done
start_id=$(($end_id + 1))
echo "Running final refreshLinks.php in case there are more pages beyond $num_pages"
WIKI=$wiki_id php /opt/htdocs/mediawiki/maintenance/refreshLinks.php "$start_id"
