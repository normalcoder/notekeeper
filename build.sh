set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source ~/.mobile-haskell/env

cd ${DIR}

PASSED_ARCH=${1}
DEFAULT_ARCH=x86_64
SELECTED_ARCH="${ARCHS:-${PASSED_ARCH:-$DEFAULT_ARCH}}"
TARGET_ARCH="${SELECTED_ARCH/arm64/aarch64}"

${TARGET_ARCH}-apple-ios-cabal new-configure --disable-shared --enable-static --allow-newer --ghc-option=-fllvmng --ghc-option=-threaded
${TARGET_ARCH}-apple-ios-cabal new-build --allow-newer --ghc-option=-fllvmng --ghc-option=-threaded

LIB_NAME=app

rsync -c $(find . | grep ${TARGET_ARCH}.*inplace-.*a$) ${DIR}/lib${LIB_NAME}.a
