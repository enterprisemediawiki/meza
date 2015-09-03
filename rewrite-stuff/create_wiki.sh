#!/usr/bin/sh
#
#

#
# Wiki ID
#
if [ ! -z "$1" ]; then
    wiki_id="$1"
fi

while [ -z "$wiki_id" ]
do
echo -e "\nEnter the desired wiki identifier. This should be a short "
echo -e "\nalphanumeric string (no spaces) which will be part of the "
echo -e "\nURL for your wiki. Example: in the following URL the "
echo -e "\n\"mywiki\" part is your wiki ID http://example.com/mywiki"
echo -e "\n\nType the desired wiki ID and press [ENTER]:"
read wiki_id
done

#
# Wiki name
#
if [ ! -z "$2" ]; then
    wiki_name="$2"
fi

while [ -z "$wiki_name" ]
do
echo -e "\nType the desired full wiki name and press [ENTER]: "
read wiki_name
done


cd /var/www/meza1/htdocs/wikis


# check if dir already exists
if [ -d "./$wiki_id" ]; then
	echo "Wiki \"$wiki_id\" already exists. Cannot create. Exiting."
	exit 1;
fi

# Check that desired name is alpha-numeric
if [ $wiki_id =~ ^[\w\d]+$ ]; then
	echo "Wiki name is acceptable"
	cp ~/sources/meza1/wiki-init "./$wiki_id"
	chown -R apache:www "./$wiki_id/images"
else
	echo "Wiki name is not alphanumeric. Exiting."
	exit 1;
fi

# insert wiki name into setup.php
sed -r -i "s/\$wgSitename = 'placeholder';/\$wgSitename = '$wiki_name';/g;" "./wikis/$wiki_id/setup.php"

# inserter auth type into setup.php
sed -r -i "s/\$mezaAuthType = 'placeholder';/\$mezaAuthType = 'local_dev';/g;" "./wikis/$wiki_id/setup.php"

echo "Complete setting up \"$wiki_id\""





