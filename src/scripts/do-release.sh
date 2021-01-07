#!/usr/bin/env bash
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

# Set current branch as base branch
BASE_BRANCH=$(git branch | grep \* | cut -d ' ' -f2)

if [ "${BASE_BRANCH}" != "master" ]; then
	echo
	echo -e "${RED}You are not on the 'master' branch, and you probably want to be.${NC}"
	printf "^"
	for ((i=1;i<=64;i++)); do
		sleep 0.05
		printf "\b ^"
	done
	printf "\b"
	echo
	echo


	echo -e "If you want to be on 'master', press ${GREEN}ctrl+c${NC} to cancel this script then"
	echo -e "do ${GREEN}git checkout master && git pull origin master --ff-only${NC} to switch."
	printf "^"
	for ((i=1;i<=70;i++)); do
		sleep 0.05
		printf "\b ^"
	done
	printf "\b"
	echo
	echo

fi

echo "Checking for any changes on GitHub..."
git fetch

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
VERSION_BRANCH="${MAJOR_VERSION}.x"
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

### How to upgrade

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
# COMMIT CHANGE
#
git add RELEASE-NOTES.md
RELEASE_BRANCH="${NEW_VERSION}-release"
git checkout -b "${RELEASE_BRANCH}"
git commit -m "${NEW_VERSION} release"
# git push origin "$BASE_BRANCH"

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
echo    "Release notes generated, committed, and pushed. "
echo
echo -e "1. Check what you committed with ${RED}git diff HEAD~1..HEAD${NC}"
echo -e "   If you want to alter anything, make your changes, then do:"
echo -e "   ${RED}git add ."
echo -e "   git commit --amend --no-edit${NC}"
echo -e "2. Push the change: ${GREEN}git push origin ${RELEASE_BRANCH}${NC}"
echo -e "3. Open a pull request at ${GREEN}https://github.com/enterprisemediawiki/meza/compare/${BASE_BRANCH}...${RELEASE_BRANCH}?expand=1${NC}"
echo    "4. After the PR is merged create a new release of Meza with these details:"
echo    "   * Tag: $NEW_VERSION"
echo    "   * Title: Meza $NEW_VERSION"
echo -e "   * Description: the ${GREEN}Meza $NEW_VERSION${NC} section from RELEASE-NOTES.md"
echo -e "   (create a release here: ${GREEN}https://github.com/enterprisemediawiki/meza/releases/new${NC})
echo -e "5. Move the ${GREEN}${VERSION_BRANCH}${NC} branch to the same point as the ${GREEN}${BASE_BRANCH}${NC} branch:"
echo -e "   ${RED}git fetch"
echo -e "   git checkout ${VERSION_BRANCH}"
echo    "   git merge origin/${BASE_BRANCH} --ff-only"
echo -e "   git push origin ${VERSION_BRANCH}${NC}"
echo -e "6. Update ${GREEN}https://www.mediawiki.org/wiki/Meza/Version_history${NC}"
echo -e "7. Announce on ${GREEN}https://riot.im/app/#/room/#mwstake-MEZA:matrix.org${NC}"
echo -e "8. Update pages on ${GREEN}https://mediawiki.org/wiki/Meza${NC}"
echo

rm ${RELEASE_NOTES_FILE}

