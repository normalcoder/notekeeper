#!/bin/zsh

set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

#source ~/.ghcup/env
#export PATH="/opt/homebrew/opt/llvm/bin:$PATH"
#export PATH="/usr/local/bin:/opt/homebrew/opt/llvm/bin:$PATH"

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

#-fllvm

#env -i HOME="$HOME" PATH="$PATH" USER="$USER" cabal update
#env -i HOME="$HOME" PATH="$PATH" USER="$USER" cabal build --enable-static --ghc-options="-fllvm -threaded -O2 +RTS -A64m -AL128m -qn8 -RTS -optc -Wno-nullability-completeness -optc -Wno-expansion-to-defined -optc -Wno-availability -optc -Wno-int-conversion -optc -I/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/include/ffi -optc -I/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk/usr/include -optl -L/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk/usr/lib"
env -i HOME="$HOME" PATH="$PATH" USER="$USER" cabal build --enable-static --ghc-options="-threaded -O2 +RTS -A64m -AL128m -qn8 -RTS -optc -Wno-nullability-completeness -optc -Wno-expansion-to-defined -optc -Wno-availability -optc -Wno-int-conversion -optc -I/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/include/ffi -optc -I/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk/usr/include -optl -L/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk/usr/lib"

exit 0;

#env -i HOME="$HOME" PATH="$PATH" USER="$USER" cabal build --ghc-options="-fllvm -optc -Wno-nullability-completeness -optc -Wno-expansion-to-defined -optc -Wno-availability -optc -I/Library/Developer/CommandLineTools/SDKs/MacOSX12.0.sdk/usr/include/ffi -optc -I/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk/usr/include -optl -L/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk/usr/lib"

#env -i HOME="$HOME" PATH="$PATH" USER="$USER" cabal build --enable-static --ghc-options="-fllvm -optc -Wno-nullability-completeness -optc -Wno-expansion-to-defined -optc -Wno-availability -optc -I/Library/Developer/CommandLineTools/SDKs/MacOSX12.0.sdk/usr/include/ffi -optc -I/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk/usr/include -optl -L/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk/usr/lib"

(rm -f cabal.project.local~* || true) 2> /dev/null


#LIB_DIR=${DIR}/Frameworks
#LIB_DIR=${DIR}

#BUILT_LIB=$(find ${DIR} | grep ".*inplace-.*a$")
#BUILT_LIB=$(find ${DIR}/dist-newstyle | grep ".*inplace-.*dylib$" | head -n 1)
BUILT_LIB=$(find ${DIR}/dist-newstyle | grep ".*inplace-.*a$" | head -n 1)

LIB_FILE_NAME=$(basename ${BUILT_LIB})

echo "!!!LIB_FILE_NAME: ${LIB_FILE_NAME}"

LIB=${LIB_FILE_NAME}
echo "!!!LIB_FILE_NAME: ${LIB_FILE_NAME}"

RAW_LIB=${DIR}/.raw_${LIB_FILE_NAME}


IPHONEOS_PLATFORM="iphoneos"
IPHONESIMULATOR_PLATFORM="iphonesimulator"

PLATFORM_NAME=${PLATFORM_NAME:-$IPHONEOS_PLATFORM}

CURRENT_PLATFORM_FILE=.currentPlatform

reduceMinOsVer() {
    # forall *.o: LC_BUILD_VERSION: Minimum OS Version 12 -> 11
    perl -pi -e 's/(\62\0\0\0.{4}\02\0\0\0\0\0)\14/\1\13/g' ${LIB}
}

markLibsForIos() {
    # forall *.o: LC_BUILD_VERSION: PLATFORM_MACOS(1) -> PLATFORM_IOS(2)
##    perl -pi -e 's/(\62\0\0\0.{4})\01\0\0\0/\1\02\0\0\0/g' ${LIB}
    perl -pi -e 's/\x32\0\0\0\x20\0\0\0\x01\0\0\0\0\0\x0c\0/\x32\0\0\0\x20\0\0\0\x02\0\0\0\0\0\x0c\0/g' ${LIB}
    perl -pi -e 's/\x32\0\0\0\x20\0\0\0\x01\0\0\0\0\0\x0b\0/\x32\0\0\0\x20\0\0\0\x02\0\0\0\0\0\x0b\0/g' ${LIB}
    perl -pi -e 's/\x32\0\0\0\x18\0\0\0\x01\0\0\0\0\0\x0c\0/\x32\0\0\0\x18\0\0\0\x02\0\0\0\0\0\x0c\0/g' ${LIB}
    perl -pi -e 's/\x32\0\0\0\x18\0\0\0\x01\0\0\0\0\0\x0b\0/\x32\0\0\0\x18\0\0\0\x02\0\0\0\0\0\x0b\0/g' ${LIB}
    
#    perl -pi -e 's/\x32\0\0\0\x18\0\0\0\x01\0\0\0\0\x01\x0c\0/\x32\0\0\0\x18\0\0\0\x02\0\0\0\0\x01\x0c\0/g' ${LIB}
##    perl -pi -e 's/(\62\0\0\0.{4})\07\0\0\0/\1\02\0\0\0/g' ${LIB}

#    perl -pi -e 's/\x32\0\0\0\x20\0\0\0\x01\0\0\0\0\0\x0c\0\0\0\0\0/\x32\0\0\0\x20\0\0\0\x02\0\0\0\0\0\x0c\0\0\0\0\0/g' $@
#    perl -pi -e 's/\x32\0\0\0\x20\0\0\0\x01\0\0\0\0\0\x0b\0\0\0\0\0/\x32\0\0\0\x20\0\0\0\x02\0\0\0\0\0\x0b\0\0\0\0\0/g' $@
#    perl -pi -e 's/\x32\0\0\0\x18\0\0\0\x01\0\0\0\0\0\x0c\0\0\0\0\0/\x32\0\0\0\x18\0\0\0\x02\0\0\0\0\0\x0c\0\0\0\0\0/g' $@
#    perl -pi -e 's/\x32\0\0\0\x18\0\0\0\x01\0\0\0\0\0\x0b\0\0\0\0\0/\x32\0\0\0\x18\0\0\0\x02\0\0\0\0\0\x0b\0\0\0\0\0/g' $@

    perl -pi -e 's/\x32\0\0\0\x20\0\0\0\x01\0\0\0\0\0\x0c\0\0\0\0\0/\x32\0\0\0\x20\0\0\0\x02\0\0\0\0\0\x0c\0\0\0\0\0/g' libHSnotekeeper-0.1.0.0-inplace-ghc9.2.1.a
    perl -pi -e 's/\x32\0\0\0\x20\0\0\0\x01\0\0\0\0\0\x0b\0\0\0\0\0/\x32\0\0\0\x20\0\0\0\x02\0\0\0\0\0\x0b\0\0\0\0\0/g' libHSnotekeeper-0.1.0.0-inplace-ghc9.2.1.a
    perl -pi -e 's/\x32\0\0\0\x18\0\0\0\x01\0\0\0\0\0\x0c\0\0\0\0\0/\x32\0\0\0\x18\0\0\0\x02\0\0\0\0\0\x0c\0\0\0\0\0/g' libHSnotekeeper-0.1.0.0-inplace-ghc9.2.1.a
    perl -pi -e 's/\x32\0\0\0\x18\0\0\0\x01\0\0\0\0\0\x0b\0\0\0\0\0/\x32\0\0\0\x18\0\0\0\x02\0\0\0\0\0\x0b\0\0\0\0\0/g' libHSnotekeeper-0.1.0.0-inplace-ghc9.2.1.a
    perl -pi -e 's/\x32\0\0\0\x18\0\0\0\x01\0\0\0\0\0\x0c\0\0\x01\x0c\0/\x32\0\0\0\x18\0\0\0\x02\0\0\0\0\0\x0c\0\0\x01\x0c\0/g' libHSnotekeeper-0.1.0.0-inplace-ghc9.2.1.a
    
    perl -pi -e 's/\x32\0\0\0\x18\0\0\0\x01\0\0\0\0\0\x0b\0\0\x03\x0b\0/\x32\0\0\0\x18\0\0\0\x02\0\0\0\0\0\x0b\0\0\x03\x0b\0/g' libHSnotekeeper-0.1.0.0-inplace-ghc9.2.1.a

    echo ${IPHONEOS_PLATFORM} > ${CURRENT_PLATFORM_FILE}
}

markLibsForSimulator() {
    # forall *.o: LC_BUILD_VERSION: PLATFORM_MACOS(1) -> PLATFORM_IOSSIMULATOR(7)
    perl -pi -e 's/(\62\0\0\0.{4})\01\0\0\0/\1\07\0\0\0/g' ${LIB}
    perl -pi -e 's/(\62\0\0\0.{4})\02\0\0\0/\1\07\0\0\0/g' ${LIB}

#    # forall *.o: LC_VERSION_MIN_IPHONEOS -> LC_BUILD_VERSION.PLATFORM_IOSSIMULATOR(7)
#    perl -pi -e 's/\45\0\0\0\20\0\0\0(\0\0..)(\0\0..)/\62\0\0\0\20\0\0\0\07\0\0\0\1/g' ${LIB_DIR}

    echo ${IPHONESIMULATOR_PLATFORM} > ${CURRENT_PLATFORM_FILE}
}

signLibs() {
    codesign -f -s 9BC6CBB53C42376BD19529C10FF83CDB0BDB38BB ${LIB_DIR}/*
}

isCurrentPlatformUnchanged() {
    grep -F ${PLATFORM_NAME} ${CURRENT_PLATFORM_FILE} > /dev/null
#    exit 0
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
#libHSrts-1.0.2-ghc9.2.1.dylib
#libffi.dylib
#libHSrts-ghc
#    RTS_LIB_FILE=$(echo ${GHC_LIBS} | grep "rts.*thr_debug" | head -n 1)
#    RTS_LIB_FILE=$(echo ${GHC_LIBS} | grep "libHSrts-ghc8.10.7" | head -n 1)
#    RTS_LIB_FILE=$(echo ${GHC_LIBS} | grep "libHSrts_thr_l-ghc8.10.7" | head -n 1)
#    RTS_LIB_FILE=$(echo ${GHC_LIBS} | grep "libHSrts_thr_debug-ghc8.10.7" | head -n 1)
    RTS_LIB_FILE=$(echo ${GHC_LIBS} | grep "libHSrts-1.0.2_thr_debug-ghc9.2.1.dylib" | head -n 1)



    RTS_LIB_FILE_NAME=$(basename ${RTS_LIB_FILE})
    allDeps[${RTS_LIB_FILE_NAME}]=${RTS_LIB_FILE}
}

#addFfi() {
#    FFI_LIB_FILE=$(echo ${GHC_LIBS} | grep "libffi.dylib" | head -n 1)
#    FFI_LIB_FILE_NAME=$(basename ${FFI_LIB_FILE})
#    allDeps[${FFI_LIB_FILE_NAME}]=${FFI_LIB_FILE}
#}

updateLibs() {
#    CABAL_DIR=${HOME}/.cabal
#    GHCUP_DIR=${HOME}/.ghcup
#
#    CABAL_LIBS=$(find ${CABAL_DIR} | grep 'lib.*.dylib')
#    GHC_LIBS=$(find ${GHCUP_DIR} | grep 'lib.*.dylib')
#    HASKELL_LIBS="${CABAL_LIBS}\n${GHC_LIBS}"


#    addRts
#    addFfi
#    echo "LIB_FILE_NAME: ${LIB_FILE_NAME}"
#    echo "BUILT_LIB: ${BUILT_LIB}"
#    collectDeps ${LIB_FILE_NAME} ${BUILT_LIB}
#
#    echo "!!!!allDeps: ${allDeps}"
    
#    mkdir -p ${LIB_DIR}

#    (rm ${LIB_DIR}/* || true) 2> /dev/null
#    cp ${allDeps} ${LIB_DIR}
    
    echo "!!!1"
    
    cp ${BUILT_LIB} ${RAW_LIB}
    
    echo "!!!2"
    
    cp ${RAW_LIB} ${LIB}
    
    echo "!!!3"

    if [ ${PLATFORM_NAME} = ${IPHONESIMULATOR_PLATFORM} ]; then
        markLibsForSimulator
    else
        markLibsForIos
    fi
    
    echo "!!!4"

    reduceMinOsVer
    
    echo "!!!5"

#    signLibs
    

#    find ${LIB_DIR} | grep dylib$ > .filesToLink
    echo ${LIB} > .filesToLink
    
    echo "!!!6"
}

updateLibs
#(isCurrentPlatformUnchanged && test -f ${LIB} && diff ${BUILT_LIB} ${RAW_LIB}) || updateLibs
