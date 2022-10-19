#!/bin/zsh

set -e

DIR=${0:a:h}

ALL_FRAMEWORKS_DIR="${MAIN_DIR}/Frameworks"

rm -Rf "${DIR}/Frameworks"
echo -n "" > "${DIR}/.filesToLink"

ls -1 "${DIR}/modules" | xargs -I {} -L 1 zsh "${DIR}/buildModule.sh" "${DIR}/modules/"{}
