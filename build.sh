set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source ~/.ghcup/env
export PATH="/opt/homebrew/opt/llvm/bin:$PATH"

cd ${DIR}

MODULES=$(find src | grep .hs$ | sed "s/src\//    /" | sed "s/.hs//" | sed "s/\//./" | sort)
perl -i -pe "BEGIN{undef $/;} s/(exposed-modules:)(.*?)(  [a-z])/\1\n${MODULES}\n\3/sm" notekeeper.cabal

#env -i HOME="$HOME" PATH="$PATH" USER="$USER" cabal build --enable-static --ghc-options='-threaded -O2 +RTS -A64m -AL128m -qn8'
#env -i HOME="$HOME" PATH="$PATH" USER="$USER" cabal build --enable-static --ghc-option=-threaded

#cabal new-build --ghc-option="`pkg-config --cflags libffi`"

#PKG_CONFIG=/opt/homebrew/bin/pkg-config

#echo "!!!!pkg-config --cflags libffi: `pkg-config --cflags libffi`"

#/opt/homebrew/bin/pkg-config --cflags libffi
#/Library/Developer/CommandLineTools/SDKs/MacOSX12.0.sdk/usr/include/ffi


env -i HOME="$HOME" PATH="$PATH" USER="$USER" cabal build --ghc-options="-threaded -optc -Wno-nullability-completeness -optc -Wno-expansion-to-defined -optc -Wno-availability -optc -Wno-int-conversion -optc -I/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/include/ffi -optc -I/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk/usr/include -optl -L/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk/usr/lib"


#env -i HOME="$HOME" PATH="$PATH" USER="$USER" cabal build --ghc-options="-fllvm -optc -Wno-nullability-completeness -optc -Wno-expansion-to-defined -optc -Wno-availability -optc -I/Library/Developer/CommandLineTools/SDKs/MacOSX12.0.sdk/usr/include/ffi -optc -I/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk/usr/include -optl -L/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk/usr/lib"

#env -i HOME="$HOME" PATH="$PATH" USER="$USER" cabal build --enable-static --ghc-options="-fllvm -optc -Wno-nullability-completeness -optc -Wno-expansion-to-defined -optc -Wno-availability -optc -I/Library/Developer/CommandLineTools/SDKs/MacOSX12.0.sdk/usr/include/ffi -optc -I/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk/usr/include -optl -L/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk/usr/lib"

rm -f cabal.project.local~*

LIB_NAME=app

BUILT_LIB=$(find ${DIR} | grep ".*inplace-.*a$")
RAW_LIB=${DIR}/.raw_lib${LIB_NAME}.a
LIB=${DIR}/lib${LIB_NAME}.a
IPHONEOS_PLATFORM="iphoneos"
IPHONESIMULATOR_PLATFORM="iphonesimulator"


CURRENT_PLATFORM_FILE=.currentPlatform

markLibForIos() {
    # forall *.o: LC_BUILD_VERSION: PLATFORM_MACOS(1) -> PLATFORM_IOS(2)
    perl -pi -e 's/(\62\0\0\0.{4})\01\0\0\0/\1\02\0\0\0/g' ${LIB}

#perl -pi -e 's/(\62\0\0\0.{4}\02\0\0\0\0\0)\14/\1\13/g'

    echo ${IPHONEOS_PLATFORM} > ${CURRENT_PLATFORM_FILE}
}

markLibForSimulator() {
    # forall *.o: LC_BUILD_VERSION: PLATFORM_MACOS(1) -> PLATFORM_IOSSIMULATOR(7)
    perl -pi -e 's/(\62\0\0\0.{4})\01\0\0\0/\1\07\0\0\0/g' ${LIB}

    # forall *.o: LC_VERSION_MIN_IPHONEOS -> LC_BUILD_VERSION.PLATFORM_IOSSIMULATOR(7)
    perl -pi -e 's/\45\0\0\0\20\0\0\0(\0\0..)(\0\0..)/\62\0\0\0\20\0\0\0\07\0\0\0\1/g' ${LIB}

    echo ${IPHONESIMULATOR_PLATFORM} > ${CURRENT_PLATFORM_FILE}
}

isCurrentPlatformUnchanged() {
#    grep -F ${PLATFORM_NAME} ${CURRENT_PLATFORM_FILE} >> /dev/null
    exit 1
}

updateLib() {
    cp ${BUILT_LIB} ${RAW_LIB}

    cp ${RAW_LIB} ${LIB}

    if [ ${PLATFORM_NAME} == ${IPHONESIMULATOR_PLATFORM} ]; then
        markLibForSimulator
    else
        markLibForIos
    fi
}


(isCurrentPlatformUnchanged && test -f ${LIB} && diff ${BUILT_LIB} ${RAW_LIB}) || updateLib
