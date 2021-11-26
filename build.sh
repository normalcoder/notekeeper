#!/bin/zsh

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

(rm -f cabal.project.local~* || true) 2> /dev/null


LIB_DIR=${DIR}/Frameworks

#BUILT_LIB=$(find ${DIR} | grep ".*inplace-.*a$")
BUILT_LIB=$(find ${DIR} | grep ".*inplace-.*dylib$" | head -n 1)

LIB_FILE_NAME=$(basename ${BUILT_LIB})
LIB=${LIB_DIR}/${LIB_FILE_NAME}

RAW_LIB=${DIR}/.raw_${LIB_FILE_NAME}


IPHONEOS_PLATFORM="iphoneos"
IPHONESIMULATOR_PLATFORM="iphonesimulator"

PLATFORM_NAME=${PLATFORM_NAME:-$IPHONEOS_PLATFORM}

CURRENT_PLATFORM_FILE=.currentPlatform

reduceMinOsVer() {
    # forall *.o: LC_BUILD_VERSION: Minimum OS Version 12 -> 11
    perl -pi -e 's/(\62\0\0\0.{4}\02\0\0\0\0\0)\14/\1\13/g' ${LIB_DIR}/*
}

markLibForIos() {
    # forall *.o: LC_BUILD_VERSION: PLATFORM_MACOS(1) -> PLATFORM_IOS(2)
    perl -pi -e 's/(\62\0\0\0.{4})\01\0\0\0/\1\02\0\0\0/g' ${LIB_DIR}/*
    
    reduceMinOsVer

    echo ${IPHONEOS_PLATFORM} > ${CURRENT_PLATFORM_FILE}
}

markLibForSimulator() {
    # forall *.o: LC_BUILD_VERSION: PLATFORM_MACOS(1) -> PLATFORM_IOSSIMULATOR(7)
    perl -pi -e 's/(\62\0\0\0.{4})\01\0\0\0/\1\07\0\0\0/g' ${LIB_DIR}/*
    
    reduceMinOsVer

#    # forall *.o: LC_VERSION_MIN_IPHONEOS -> LC_BUILD_VERSION.PLATFORM_IOSSIMULATOR(7)
#    perl -pi -e 's/\45\0\0\0\20\0\0\0(\0\0..)(\0\0..)/\62\0\0\0\20\0\0\0\07\0\0\0\1/g' ${LIB_DIR}

    echo ${IPHONESIMULATOR_PLATFORM} > ${CURRENT_PLATFORM_FILE}
}

isCurrentPlatformUnchanged() {
#    grep -F ${PLATFORM_NAME} ${CURRENT_PLATFORM_FILE} > /dev/null
    exit 1
}

#echo "!!!$CABAL_LIBS"
#echo "!!!$GHC_LIBS"

#declare -A allDeps=( ["${LIB_FILE_NAME}"]="${LIB}")
declare -A allDeps

#echo "!!!${allDeps}"

findFile() {
#    echo "!!!findFile: $1"
#    SYSTEM_FILE=$(echo ${CABAL_LIBS} | grep $1$ | head -n 1)
#    echo "!!!findFile SYSTEM_FILE: $SYSTEM_FILE"
#    q=${SYSTEM_FILE:-$(echo ${GHCUP_DIR} | grep $1$ | head -n 1)}
#    echo "!!!findFile q: $q"
#    echo $q
    
    echo ${HASKELL_LIBS} | grep $1$ | head -n 1
}

collectDeps() {
#    echo "!!!collectDeps: key: $1, value: $2"

    FILE=${2:-$(findFile $1)}
#    echo "!!!will assign ${1} -> $FILE"
#    echo "!!!allDeps before: ${allDeps[$1]}"
    allDeps[$1]=${FILE}
#    echo "!!!allDeps: ${allDeps}"
#    echo "!!!allDeps after: ${allDeps[$1]}"
    otool -L ${FILE} | grep -o 'libHS.*.dylib' | while read line
    do
#        echo "@@@line: key: $line, value: ${allDeps[$line]}"
        [ -z "${allDeps[$line]}" ] && collectDeps $line
#        q=${allDeps[$line]}
#        echo "!!!${q}"
#        ${CABAL_DIR}
#        echo "!!!$line"
    done
    
#    echo "!!!allDeps: $allDeps"
    
#    while read p; do
#        echo "$p"
#    done <peptides.txt
#    while p; do
#        echo "$p"
#    done <$q
#    $(otool -L $1) | while read line
#    do
#        echo "!!!${line}"
#    done
#
}

addRts() {
    RTS_LIB_FILE=$(echo ${GHC_LIBS} | grep "rts.*thr_debug" | head -n 1)
    RTS_LIB_FILE_NAME=$(basename RTS_LIB_FILE)
    allDeps[${RTS_LIB_FILE_NAME}]=${RTS_LIB_FILE}
}

updateLibs() {
    CABAL_DIR=${HOME}/.cabal
    GHCUP_DIR=${HOME}/.ghcup

    CABAL_LIBS=$(find ${CABAL_DIR} | grep 'libHS.*.dylib')
    GHC_LIBS=$(find ${GHCUP_DIR} | grep 'libHS.*.dylib')
    HASKELL_LIBS="${CABAL_LIBS}\n${GHC_LIBS}"

    addRts
    collectDeps ${LIB_FILE_NAME} ${BUILT_LIB}
    
    mkdir -p ${LIB_DIR}
    cp ${allDeps} ${LIB_DIR}
    
    cp ${BUILT_LIB} ${RAW_LIB}

    if [ ${PLATFORM_NAME} = ${IPHONESIMULATOR_PLATFORM} ]; then
        markLibForSimulator
    else
        markLibForIos
        codesign -f -s B552EDEF2C84A620A46E429989D9706683B87328 ${LIB_DIR}/*
    fi
}

#updateLibs

(isCurrentPlatformUnchanged && test -f ${LIB} && diff ${BUILT_LIB} ${RAW_LIB}) || updateLibs
