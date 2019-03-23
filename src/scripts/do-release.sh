#!/bin/sh
#
# Generate release notes for Meza

#
# SET VARIABLES FOR COLORIZING BASH OUTPUT
#
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

#
# SETUP KNOWN VARS PRIOR TO USER INPUT
#
PREVIOUS_RELEASES=$(git tag -l | sed '/^v0/ d' | sed '/^v1/ d')
LATEST="${PREVIOUS_RELEASES##*$'\n'}"
GIT_HASH=$(git rev-parse HEAD | cut -c1-8)

#
# READ IN USER INPUTS
#
read -p "Add optional single line of overview text: " OVERVIEW

echo -e "${BLUE}"
echo "${PREVIOUS_RELEASES}"
echo -e "${NC}"

while [ -z "$OLD_VERSION" ]; do
	read -p "Enter previous release number (options in blue above): " -i "$LATEST" -e OLD_VERSION
done;

while [ -z "$NEW_VERSION" ]; do
	read -p "Enter new version number in form X.Y.Z: " NEW_VERSION
done;

#
# SETUP VARS BASED UPON USER INPUT
#
MAJOR_VERSION=$(echo "$OLD_VERSION" | cut -f1 -d".")
RELEASE_BRANCH="${MAJOR_VERSION}.x"
COMMITS=$(git log --oneline --no-merges "${OLD_VERSION}..HEAD" | while read line; do echo "* $line"; done)
CONTRIBUTORS=$(git shortlog -sn "${OLD_VERSION}..HEAD" | while read line; do echo "* $line"; done)

#
# GENERATE RELEASE NOTES INTO TEMP FILE
#
RELEASE_NOTES_FILE=./.release-notes.tmp
cat > ${RELEASE_NOTES_FILE} <<- EOM
${OVERVIEW}

### Commits since $OLD_VERSION

${COMMITS}

### Contributors

${CONTRIBUTORS}

### Mediawiki.org pages updated

* TBD

### What still isn't documented?

* TBD
* See [list of issues and pull requests indicating missing docs](https://github.com/enterprisemediawiki/meza/pulls?utf8=%E2%9C%93&q=label%3A%22open+post-merge+actions%22+)

# How to upgrade

\`\`\`bash
sudo meza update ${NEW_VERSION}
sudo meza deploy <insert-your-environment-name>
\`\`\`
EOM

#
# OUTPUT RELEASE NOTES IN GREEN ON COMMAND LINE
#
echo -e "${GREEN}"
cat "${RELEASE_NOTES_FILE}"
echo -e "${NC}"

#
# TO-DO: Automate edit of release notes
#
# sed -e '1,/=============/r.release-notes.tmp' ./RELEASE-NOTES.md

#
# OUTPUT DIRECTIONS FOR COMPLETING RELEASE
#
echo
echo    "1. Edit RELEASE-NOTES.md"
echo -e "   * Copy the ${GREEN}green text${NC} from above and add it under the title ${GREEN}## Meza $NEW_VERSION${NC}"
echo    "   * Edit the text as required"
echo    "2. Commit your changes and submit a pull request"
echo    "3. After the PR is merged create a new release of Meza with these details:"
echo    "   * Tag: $NEW_VERSION"
echo    "   * Title: Meza $NEW_VERSION"
echo -e "   * Description: ${GREEN}green text${NC} from above (edits as required)"
echo    "4. Bump the release branch $RELEASE_BRANCH to this release:"
echo -e "   ${RED}git checkout $RELEASE_BRANCH"
echo    "   git merge $GIT_HASH --ff-only"
echo -e "   git push origin $RELEASE_BRANCH${NC}"
echo -e "5. Update ${BLUE}https://www.mediawiki.org/wiki/Meza/Version_history${NC}"
echo -e "6. Announce on ${BLUE}https://riot.im/app/#/room/#mwstake-MEZA:matrix.org${NC}"
echo

rm ${RELEASE_NOTES_FILE}
