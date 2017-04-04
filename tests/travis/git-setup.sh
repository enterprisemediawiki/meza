#!/bin/sh
#
# Checkout the appropriate meza version in Travis

# TRAVIS_EVENT_TYPE: Indicates how the build was triggered. One of push, pull_request, api, cron.
TRAVIS_EVENT_TYPE="$1"

# TRAVIS_COMMIT: The commit that the current build is testing.
TRAVIS_COMMIT="$2"

# TRAVIS_PULL_REQUEST_SHA:
# if the current job is a pull request, the commit SHA of the HEAD commit of the PR.
# if the current job is a push build, this variable is empyty ("").
TRAVIS_PULL_REQUEST_SHA="$3"

# TRAVIS_BRANCH:
# for push builds, or builds not triggered by a pull request, this is the name of the branch.
# for builds triggered by a pull request this is the name of the branch targeted by the pull request.
TRAVIS_BRANCH="$4"

# TRAVIS_PULL_REQUEST_BRANCH:
# if the current job is a pull request, the name of the branch from which the PR originated.
# if the current job is a push build, this variable is empty ("").
TRAVIS_PULL_REQUEST_BRANCH="$5"

cd /opt/meza
if [ "$TRAVIS_EVENT_TYPE" = "pull_request" ]; then
	git checkout "$TRAVIS_BRANCH"
	git config --global user.name "Docker User"
	git config --global user.email docker@example.com
	git merge "origin/$TRAVIS_PULL_REQUEST_BRANCH" || true
	git status
	echo
	echo "rev-parse HEAD:"
	git rev-parse HEAD
	echo
	echo "Pull Request hash:"
	echo "$TRAVIS_PULL_REQUEST_SHA"
else
	git reset --hard "$TRAVIS_COMMIT"
fi
