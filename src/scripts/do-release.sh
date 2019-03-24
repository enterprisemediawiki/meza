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
# WELCOME MESSAGE
#
echo
echo "* * * * * * * * * * * * * * * * * * * * * * * *"
echo "*                                             *"
echo "*           Meza Release Generator            *"
echo "*                                             *"
echo "* * * * * * * * * * * * * * * * * * * * * * * *"

#
# USER INPUT: CHOOSE OLD VERSION NUMBER TO BASE FROM
#
echo -e "${GREEN}"
echo "${PREVIOUS_RELEASES}"
echo -e "${NC}"

while [ -z "$OLD_VERSION" ]; do
	read -p "Enter previous release number (options in green above): " -i "$LATEST" -e OLD_VERSION
done;

#
# SETUP LIST OF COMMITS FOR DISPLAY NOW AND INCLUSION IN RELEASE-NOTES.MD
#
COMMITS=$(git log --oneline --no-merges "${OLD_VERSION}..HEAD" | while read line; do echo "* $line"; done)

echo
echo -e "From ${GREEN}${OLD_VERSION}${NC} to ${GREEN}HEAD${NC}, these are the non-merge commits:"
echo -e "${GREEN}"
echo "${COMMITS}"
echo -e "${NC}"

#
# USER INPUT: CHOOSE NEW VERSION NUMBER
#
while [ -z "$NEW_VERSION" ]; do
	read -p "Enter new version number in form X.Y.Z: " NEW_VERSION
done;

#
# USER INPUT: OVERVIEW TEXT
#
read -p "Based upon commits above, choose optional 1-line overview: " OVERVIEW

#
# SETUP VARS BASED UPON USER INPUT
#
MAJOR_VERSION=$(echo "$NEW_VERSION" | cut -f1 -d".")
RELEASE_BRANCH="${MAJOR_VERSION}.x"
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
# I think preferable not to output this here
# echo -e "${GREEN}"
# cat "${RELEASE_NOTES_FILE}"
# echo -e "${NC}"


#
# TO-DO: Automate edit of release notes
#
sed -i -e '/=============/r.release-notes.tmp' ./RELEASE-NOTES.md
sed -i "s/=============/\0\n\n## Meza $NEW_VERSION/" ./RELEASE-NOTES.md


#
# OUTPUT DIRECTIONS FOR COMPLETING RELEASE
#
echo
echo "* * * * * * * * * * * * * * * * * * * * * * * *"
echo "*                                             *"
echo "*           Release process started           *"
echo "*                                             *"
echo "* * * * * * * * * * * * * * * * * * * * * * * *"
echo
echo    "Release notes generated. To complete the release do the following:"
echo
echo -e "1. Check changes to RELEASE-NOTES.md with ${RED}git diff${NC}"
echo    "2. Commit changes and submit a pull request"
echo    "3. After the PR is merged create a new release of Meza with these details:"
echo    "   * Tag: $NEW_VERSION"
echo    "   * Title: Meza $NEW_VERSION"
echo -e "   * Description: the ${GREEN}Meza $NEW_VERSION${NC} section from RELEASE-NOTES.md"
echo -e "4. Move the ${GREEN}$RELEASE_BRANCH${NC} branch to the same point as the ${GREEN}${NEW_VERSION}${NC} release:"
echo -e "   ${RED}git checkout $RELEASE_BRANCH"
echo    "   git merge $GIT_HASH --ff-only"
echo -e "   git push origin $RELEASE_BRANCH${NC}"
echo -e "5. Update ${GREEN}https://www.mediawiki.org/wiki/Meza/Version_history${NC}"
echo -e "6. Announce on ${GREEN}https://riot.im/app/#/room/#mwstake-MEZA:matrix.org${NC}"
echo

rm ${RELEASE_NOTES_FILE}
