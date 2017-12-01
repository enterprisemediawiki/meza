#!/bin/sh
#
# Perform standard checks against a wiki. This may only work on a monolith

# -e: kill script if anything fails
# -u: don't allow undefined variables
# -x: debug mode; print executed commands
set -eux

origin="http://127.0.0.1:8080"
wiki_id="$1"
wiki_name="$2"

# Wiki API test
api_url_base="$origin/$wiki_id/api.php"
api_url_siteinfo="$api_url_base?action=query&meta=siteinfo&format=json"
api_url_ve="$api_url_base?action=visualeditor&format=json&paction=parse&page=Main_Page&uselang=en"

# API siteinfo returns values like
# {
#     "batchcomplete": "",
#     "query": {
#         "general": {
#             "mainpage": "Main Page",
#             "base": "https://en.wikipedia.org/wiki/Main_Page",
#             "sitename": "Wikipedia",
curl -L "$api_url_siteinfo"
curl -L "$api_url_siteinfo" | jq ".query.general.sitename == \"$wiki_name\"" -e \
    && (echo "$wiki_name API test: pass" && exit 0) \
    || (echo "$wiki_name API test: fail" && exit 1)

# Verify Parsoid is working
curl -L "$api_url_ve"
curl -L "$api_url_ve" | jq ".visualeditor.result == \"success\"" -e \
	&& (echo 'VisualEditor PASS' && exit 0) || (echo 'VisualEditor FAIL' && exit 1)

# Verify an indices exist for this wiki
curl "http://127.0.0.1:9200/_stats/store"
curl "http://127.0.0.1:9200/_stats/store" | jq ".indices | has(\"wiki_${wiki_id}_content_first\")" -e \
	&& (echo 'Elasticsearch PASS' && exit 0) || (echo 'Elasticsearch FAIL' && exit 1)
curl "http://127.0.0.1:9200/_stats/store" | jq ".indices | has(\"wiki_${wiki_id}_general_first\")" -e \
	&& (echo 'Elasticsearch PASS' && exit 0) || (echo 'Elasticsearch FAIL' && exit 1)
