#!/bin/sh
#
# Test if an image exists on a wiki


# -e: kill script if anything fails
# -u: don't allow undefined variables
# -x: debug mode; print executed commands
set -eux

origin="http://127.0.0.1:8080"
wiki_id="$1"
image_title="$2"
expected_code="200"


# Check if title of "Test image" exists
api_url_base="$origin/$wiki_id/api.php"
curl --insecure -L "$url_base?action=query&titles=File:$image_title&prop=imageinfo&iiprop=sha1|url&format=json" | jq '.query.pages[].title'

# Get image url, get sha1 according to database (via API)
img_url=$( curl --insecure -L "$url_base/api.php?action=query&titles=File:Test_image.png&prop=imageinfo&iiprop=sha1|url&format=json" | jq --raw-output '.query.pages[].imageinfo[0].url' )
img_url=$( echo $img_url | sed 's/https:\/\/[[:digit:]]\+\.[[:digit:]]\+\.[[:digit:]]\+\.[[:digit:]]\+\///' )
img_url="http://127.0.0.1:8080/$img_url"

# Retrieve image
curl --write-out %{http_code} --silent --output /dev/null "$img_url" \
	| grep -q "$expected_code" \
	&& (echo 'Image test: pass' && exit 0) \
	|| (echo 'Image test: fail' && exit 1)

