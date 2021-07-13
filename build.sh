set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source ~/.ghcup/env
export PATH="/opt/homebrew/opt/llvm/bin:$PATH"

cd ${DIR}

cabal configure --disable-shared --enable-static --ghc-option=-threaded
cabal build --disable-shared --enable-static --ghc-option=-threaded
rm -f cabal.project.local~*

LIB_NAME=app

BUILT_LIB=$(find ${DIR} | grep ".*inplace-.*a$")
RAW_LIB=${DIR}/.raw_lib${LIB_NAME}.a
LIB=${DIR}/lib${LIB_NAME}.a

updateLib() {
    cp ${BUILT_LIB} ${RAW_LIB}
    
    cp ${RAW_LIB} ${LIB}
    
    # forall *.o: LC_BUILD_VERSION: PLATFORM_MACOS(1) -> PLATFORM_IOS(2)
    perl -pi -e 's/(\62\0\0\0.{4})\01\0\0\0/\1\02\0\0\0/g' ${LIB}
}

diff ${BUILT_LIB} ${RAW_LIB} || updateLib
