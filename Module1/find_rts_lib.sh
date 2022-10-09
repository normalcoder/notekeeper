#!/bin/zsh

set -e

# DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DIR=${0:a:h}

cd ${DIR}

getRtsLibFileName() {
    echo "${OTOOL_OUTPUT}" | grep libHSrts | sed -nE 's/^.*rpath\/(.*\.dylib).*/\1/p'
}

GHC_SCRIPT_FILE=$(readlink -f $(which ghc))
set +e
OTOOL_OUTPUT=$(otool -L "${GHC_SCRIPT_FILE}")
set -e

if [[ ${OTOOL_OUTPUT} == *"is not an object file"* ]]; then
  GHC_BIN_FILE=$(cat ${GHC_SCRIPT_FILE} | grep "^executablename=" | sed -nE 's/^executablename="(.*)"$/\1/p')
  OTOOL_OUTPUT=$(otool -L "${GHC_BIN_FILE}")
  getRtsLibFileName
else
  getRtsLibFileName
fi

# if OTOOL_OUTPUT=$(otool -L /bin/bash) ; then
#     echo "1: ${OTOOL_OUTPUT}"
# else
#     echo "2"
# fi
# echo "3"

# ls -la /Users/alex/.ghcup/bin/ghc
# cat /Users/alex/.ghcup/bin/../ghc/9.4.2/bin/ghc-9.4.2  
# otool -L /Users/alex/.ghcup/ghc/9.4.2/lib/ghc-9.4.2/bin/./ghc-9.4.2
