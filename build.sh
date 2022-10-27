#!/bin/zsh

set -e

DIR=${0:a:h}

ALL_FRAMEWORKS_DIR="${MAIN_DIR}/Frameworks"

rm -Rf "${DIR}/Frameworks"
echo -n "" > "${DIR}/.filesToLink"

for MODULE in $(ls -1 "${DIR}/modules")
do
    echo "!!!!module: $MODULE"
    zsh "${DIR}/buildModule.sh" "${DIR}/modules/${MODULE}"
done
