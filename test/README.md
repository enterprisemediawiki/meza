Tests
=====

Automated testing is still fairly rudimentary within meza. Mostly these automate some aspects of meza to streamline manual testing. In the future this directory will handle running the automated tests associated with all the component parts of meza (e.g. MediaWiki's phpunit tests)

## Structure

Each test should be in a separate directory as a way of grouping the files. The main entrypoint of each test should be `run-test.sh` within that directory. Eventually someday there may be a file at `/opt/meza/test/run-all.sh` to run all tests.
