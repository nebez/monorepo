#!/bin/bash

##
# Validates the .circleci/config.yml file from the root of the project is valid
# and was recently packed to reflect the latest changes made to its source.
#
# Usage:
#   validate-config.sh
##

set -eu

# Find script directory (no support for symlinks)
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# Validate that both circleci is available to us
which circleci > /dev/null || "CircleCI CLI not installed"

# Move to the root of the project
cd "${DIR}/../../../"

# We don't actually want our script to rewrite the contents of the file - that'd
# be kind of weird. Instead we'll capture the output of packing the file, diff
# the file with the contents of the new pack, and emit a warning if they're not
# identical and print out a useful difference.
CIRCLE_NEW_CONFIG=$(circleci config pack .circleci/src/)

printf "Checking for differences in .circleci/config.yml..."

CIRCLE_DIFF=$(echo "${CIRCLE_NEW_CONFIG}" | diff -B .circleci/config.yml - || exit 0)

if [[ -z "${CIRCLE_DIFF}" ]]; then
    echo " Valid!"
    exit 0
fi

echo " error! Found differences:"
echo
echo "${CIRCLE_DIFF}"
echo
echo "Did you forget to repack the config? Try running"
echo "  circleci config pack .circleci/src/ > .circleci/config.yml"

exit 1
