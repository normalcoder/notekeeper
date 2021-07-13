set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# source ~/.mobile-haskell/env

source ~/.bashrc

cd ${DIR}

export

## PASSED_ARCH=${1}
#PASSED_ARCH=${PLATFORM_PREFERRED_ARCH}
##DEFAULT_ARCH=x86_64
#DEFAULT_ARCH=arm64
## SELECTED_ARCH="${ARCHS:-${PASSED_ARCH:-$DEFAULT_ARCH}}"
#SELECTED_ARCH="${PASSED_ARCH}"
#TARGET_ARCH="${SELECTED_ARCH/arm64/aarch64}"


# ${TARGET_ARCH}-apple-ios-cabal new-list --installed
# ${TARGET_ARCH}-apple-ios-cabal new-configure --disable-shared --enable-static --allow-newer --ghc-option=-fllvmng --ghc-option=-threaded
# ${TARGET_ARCH}-apple-ios-cabal new-build --allow-newer --ghc-option=-fllvmng --ghc-option=-threaded
#cabal new-configure --ghc-option=-threaded
#cabal new-build --enable-static --ghc-option=-threaded

cabal new-configure --disable-shared --enable-static --ghc-option=-threaded
cabal new-build --disable-shared --enable-static --ghc-option=-threaded

LIB_NAME=app

rsync -c $(find ${DIR} | grep ".*inplace-.*a$") ${DIR}/lib${LIB_NAME}.a

perl -pi -e 's/(\62\0\0\0.{4})\01\0\0\0/\1\02\0\0\0/g' libapp.a

rm -f cabal.project.local~*
