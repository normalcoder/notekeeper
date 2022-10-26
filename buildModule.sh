#!/bin/zsh

set -e

DIR=${0:a:h}

cd ${DIR}

MODULE_NAME=$(basename ${1})
MAIN_MODULE_NAME=notekeeper

if [[ ${MODULE_NAME} == ${MAIN_MODULE_NAME} ]]; then
    LINK_IMMEDIATELY=1
else
    LINK_IMMEDIATELY=0
fi

MODULE_DIR=${1}

MAIN_DIR=$(dirname $(dirname ${MODULE_DIR}))
ALL_FRAMEWORKS_DIR="${MAIN_DIR}/Frameworks"

#source ~/.ghcup/env
#export PATH="/opt/homebrew/opt/llvm/bin:$PATH"
#export PATH="/usr/local/bin:/opt/homebrew/opt/llvm/bin:$PATH"

MODULES=$(cd ${MODULE_DIR} && find src | grep .hs$ | sed "s/src\//    /" | sed "s/.hs//" | sed "s/\//./" | sort)
perl -i -pe "BEGIN{undef $/;} s/(exposed-modules:)(.*?)(  [a-z])/\1\n${MODULES}\n\3/sm" ${MODULE_DIR}/${MODULE_NAME}.cabal

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
(cd ${MODULE_DIR} && env -i HOME="$HOME" PATH="$PATH" USER="$USER" cabal build --ghc-options="-threaded -O2 +RTS -A64m -AL128m -qn8 -RTS -optc -Wno-nullability-completeness -optc -Wno-expansion-to-defined -optc -Wno-availability -optc -Wno-int-conversion")
#env -i HOME="$HOME" PATH="$PATH" USER="$USER" cabal build --ghc-options="-threaded -O2 +RTS -A64m -AL128m -qn8 -RTS -optc -Wno-nullability-completeness -optc -Wno-expansion-to-defined -optc -Wno-availability -optc -Wno-int-conversion -optc -I/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/include/ffi -optc -I/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk/usr/include -optl -L/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk/usr/lib"

#env -i HOME="$HOME" PATH="$PATH" USER="$USER" cabal build --ghc-options="-fllvm -optc -Wno-nullability-completeness -optc -Wno-expansion-to-defined -optc -Wno-availability -optc -I/Library/Developer/CommandLineTools/SDKs/MacOSX12.0.sdk/usr/include/ffi -optc -I/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk/usr/include -optl -L/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk/usr/lib"

#env -i HOME="$HOME" PATH="$PATH" USER="$USER" cabal build --enable-static --ghc-options="-fllvm -optc -Wno-nullability-completeness -optc -Wno-expansion-to-defined -optc -Wno-availability -optc -I/Library/Developer/CommandLineTools/SDKs/MacOSX12.0.sdk/usr/include/ffi -optc -I/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk/usr/include -optl -L/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk/usr/lib"

(rm -f cabal.project.local~* || true) 2> /dev/null


LIB_DIR=${MODULE_DIR}/Frameworks
#LIB_DIR=${DIR}

#BUILT_LIB=$(find ${DIR} | grep ".*inplace-.*a$")
BUILT_LIB=$(find ${MODULE_DIR}/dist-newstyle | grep "libHS${MODULE_NAME}.*inplace-.*dylib$" | head -n 1)
#BUILT_LIB=$(find ${DIR}/dist-newstyle | grep ".*inplace-.*a$" | head -n 1)

#echo "!!!BUILT_LIB: ${BUILT_LIB}"

LIB_FILE_NAME=$(basename ${BUILT_LIB})

#echo "!!!LIB_FILE_NAME: ${LIB_FILE_NAME}"

#LIB=${LIB_FILE_NAME}
LIB=${LIB_DIR}/${LIB_FILE_NAME}

# RAW_LIB=${MODULE_DIR}/.raw_${LIB_FILE_NAME}


IPHONEOS_PLATFORM="iphoneos"
IPHONESIMULATOR_PLATFORM="iphonesimulator"

PLATFORM_NAME=${PLATFORM_NAME:-$IPHONEOS_PLATFORM}

# CURRENT_PLATFORM_FILE=.currentPlatform

reduceMinOsVer() {
    # forall *.o: LC_BUILD_VERSION: Minimum OS Version 12 -> 11
#    perl -pi -e 's/(\62\0\0\0.{4}\02\0\0\0\0\0)\14/\1\13/g' ${LIB}

#    perl -pi -e 's/\x32\0\0\0\x20\0\0\0\x01\0\0\0\0\0\x0c\0\0\0\0\0/\x32\0\0\0\x20\0\0\0\x02\0\0\0\0\0\x0c\0\0\0\0\0/g' ${LIB}
#    perl -pi -e 's/\x32\0\0\0\x20\0\0\0\x01\0\0\0\0\0\x0b\0\0\0\0\0/\x32\0\0\0\x20\0\0\0\x02\0\0\0\0\0\x0b\0\0\0\0\0/g' ${LIB}
#    perl -pi -e 's/\x32\0\0\0\x18\0\0\0\x01\0\0\0\0\0\x0c\0\0\0\0\0/\x32\0\0\0\x18\0\0\0\x02\0\0\0\0\0\x0c\0\0\0\0\0/g' ${LIB}
#    perl -pi -e 's/\x32\0\0\0\x18\0\0\0\x01\0\0\0\0\0\x0b\0\0\0\0\0/\x32\0\0\0\x18\0\0\0\x02\0\0\0\0\0\x0b\0\0\0\0\0/g' ${LIB}
#    perl -pi -e 's/\x32\0\0\0\x18\0\0\0\x01\0\0\0\0\0\x0c\0\0\x01\x0c\0/\x32\0\0\0\x18\0\0\0\x02\0\0\0\0\0\x0c\0\0\x01\x0c\0/g' ${LIB}
#
#    perl -pi -e 's/\x32\0\0\0\x18\0\0\0\x01\0\0\0\0\0\x0b\0\0\x03\x0b\0/\x32\0\0\0\x18\0\0\0\x02\0\0\0\0\0\x0b\0\0\x03\x0b\0/g' ${LIB}

}

markLibsForIos() {
    # forall *.o: LC_BUILD_VERSION: PLATFORM_MACOS(1) -> PLATFORM_IOS(2)
##    perl -pi -e 's/(\62\0\0\0.{4})\01\0\0\0/\1\02\0\0\0/g' ${LIB}
#    perl -pi -e 's/\x32\0\0\0\x20\0\0\0\x01\0\0\0\0\0\x0c\0/\x32\0\0\0\x20\0\0\0\x02\0\0\0\0\0\x0c\0/g' ${LIB}
#    perl -pi -e 's/\x32\0\0\0\x20\0\0\0\x01\0\0\0\0\0\x0b\0/\x32\0\0\0\x20\0\0\0\x02\0\0\0\0\0\x0b\0/g' ${LIB}
#    perl -pi -e 's/\x32\0\0\0\x18\0\0\0\x01\0\0\0\0\0\x0c\0/\x32\0\0\0\x18\0\0\0\x02\0\0\0\0\0\x0c\0/g' ${LIB}
#    perl -pi -e 's/\x32\0\0\0\x18\0\0\0\x01\0\0\0\0\0\x0b\0/\x32\0\0\0\x18\0\0\0\x02\0\0\0\0\0\x0b\0/g' ${LIB}
    
#    perl -pi -e 's/\x32\0\0\0\x18\0\0\0\x01\0\0\0\0\x01\x0c\0/\x32\0\0\0\x18\0\0\0\x02\0\0\0\0\x01\x0c\0/g' ${LIB}
##    perl -pi -e 's/(\62\0\0\0.{4})\07\0\0\0/\1\02\0\0\0/g' ${LIB}

#    perl -pi -e 's/\x32\0\0\0\x20\0\0\0\x01\0\0\0\0\0\x0c\0\0\0\0\0/\x32\0\0\0\x20\0\0\0\x02\0\0\0\0\0\x0c\0\0\0\0\0/g' $@
#    perl -pi -e 's/\x32\0\0\0\x20\0\0\0\x01\0\0\0\0\0\x0b\0\0\0\0\0/\x32\0\0\0\x20\0\0\0\x02\0\0\0\0\0\x0b\0\0\0\0\0/g' $@
#    perl -pi -e 's/\x32\0\0\0\x18\0\0\0\x01\0\0\0\0\0\x0c\0\0\0\0\0/\x32\0\0\0\x18\0\0\0\x02\0\0\0\0\0\x0c\0\0\0\0\0/g' $@
#    perl -pi -e 's/\x32\0\0\0\x18\0\0\0\x01\0\0\0\0\0\x0b\0\0\0\0\0/\x32\0\0\0\x18\0\0\0\x02\0\0\0\0\0\x0b\0\0\0\0\0/g' $@

    echo "!!!mark"
    perl -pi -e 's/\x32\0\0\0(\x20|\x28)\0\0\0\x01\0\0\0\0\0(\x0b|\x0c)\0\0(\0|\x01|\x02|\x03|\x04)(\x0b|\x0c)\0/\x32\0\0\0\1\0\0\0\x02\0\0\0\0\0\2\0\0\3\4\0/g' ${LIB_DIR}/*

    # perl -pi -e 's/\x32\0\0\0\x20\0\0\0\x01\0\0\0\0\0\x0c\0\0\0\0\0/\x32\0\0\0\x20\0\0\0\x02\0\0\0\0\0\x0c\0\0\0\0\0/g' ${LIB_DIR}/*
    # perl -pi -e 's/\x32\0\0\0\x20\0\0\0\x01\0\0\0\0\0\x0b\0\0\0\0\0/\x32\0\0\0\x20\0\0\0\x02\0\0\0\0\0\x0b\0\0\0\0\0/g' ${LIB_DIR}/*
    # perl -pi -e 's/\x32\0\0\0\x18\0\0\0\x01\0\0\0\0\0\x0c\0\0\0\0\0/\x32\0\0\0\x18\0\0\0\x02\0\0\0\0\0\x0c\0\0\0\0\0/g' ${LIB_DIR}/*
    # perl -pi -e 's/\x32\0\0\0\x18\0\0\0\x01\0\0\0\0\0\x0b\0\0\0\0\0/\x32\0\0\0\x18\0\0\0\x02\0\0\0\0\0\x0b\0\0\0\0\0/g' ${LIB_DIR}/*
    # perl -pi -e 's/\x32\0\0\0\x18\0\0\0\x01\0\0\0\0\0\x0c\0\0\x01\x0c\0/\x32\0\0\0\x18\0\0\0\x02\0\0\0\0\0\x0c\0\0\x01\x0c\0/g' ${LIB_DIR}/*
    
    # perl -pi -e 's/\x32\0\0\0\x18\0\0\0\x01\0\0\0\0\0\x0b\0\0\x03\x0b\0/\x32\0\0\0\x18\0\0\0\x02\0\0\0\0\0\x0b\0\0\x03\x0b\0/g' ${LIB_DIR}/*
    
    # perl -pi -e 's/\x32\0\0\0\x20\0\0\0\x01\0\0\0\0\0\x0c\0\0\x01\x0c\0/\x32\0\0\0\x20\0\0\0\x02\0\0\0\0\0\x0c\0\0\x01\x0c\0/g' ${LIB_DIR}/*


#    perl -pi -e 's/\x32\0\0\0\x20\0\0\0\x02\0\0\0\0\0\x0c\0\0\0\0\0/\x32\0\0\0\x20\0\0\0\x02\0\0\0\0\0\x0b\0\0\0\0\0/g' libHSnotekeeper-0.1.0.0-inplace-ghc9.2.1.a
#    perl -pi -e 's/\x32\0\0\0\x18\0\0\0\x02\0\0\0\0\0\x0c\0\0\0\0\0/\x32\0\0\0\x18\0\0\0\x02\0\0\0\0\0\x0b\0\0\0\0\0/g' libHSnotekeeper-0.1.0.0-inplace-ghc9.2.1.a
#    perl -pi -e 's/\x32\0\0\0\x18\0\0\0\x02\0\0\0\0\0\x0c\0\0\x01\x0c\0/\x32\0\0\0\x18\0\0\0\x02\0\0\0\0\0\x0b\0\0\x01\x0c\0/g' libHSnotekeeper-0.1.0.0-inplace-ghc9.2.1.a



    # echo ${IPHONEOS_PLATFORM} > ${CURRENT_PLATFORM_FILE}
}

markLibsForSimulator() {
    # forall *.o: LC_BUILD_VERSION: PLATFORM_MACOS(1) -> PLATFORM_IOSSIMULATOR(7)
    perl -pi -e 's/\x32\0\0\0(\x20|\x28)\0\0\0\x01\0\0\0\0\0(\x0b|\x0c)\0\0(\0|\x01|\x02|\x03|\x04)(\x0b|\x0c)\0/\x32\0\0\0\1\0\0\0\x07\0\0\0\0\0\2\0\0\3\4\0/g' ${LIB_DIR}/*
    # perl -pi -e 's/(\62\0\0\0.{4})\01\0\0\0/\1\07\0\0\0/g' ${LIB}
    # perl -pi -e 's/(\62\0\0\0.{4})\02\0\0\0/\1\07\0\0\0/g' ${LIB}

#    # forall *.o: LC_VERSION_MIN_IPHONEOS -> LC_BUILD_VERSION.PLATFORM_IOSSIMULATOR(7)
#    perl -pi -e 's/\45\0\0\0\20\0\0\0(\0\0..)(\0\0..)/\62\0\0\0\20\0\0\0\07\0\0\0\1/g' ${LIB_DIR}

    # echo ${IPHONESIMULATOR_PLATFORM} > ${CURRENT_PLATFORM_FILE}
}

signLibs() {
    codesign -f -s 949CA008AA70C44D456B5C63DFF47B488897AF14 ${LIB_DIR}/*
}

# isCurrentPlatformUnchanged() {
#     grep -F ${PLATFORM_NAME} ${CURRENT_PLATFORM_FILE} > /dev/null
# #    exit 0
# }

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

findFileLocally() {
#    echo "!!!findFile: $1"
#    SYSTEM_FILE=$(echo ${CABAL_LIBS} | grep $1$ | head -n 1)
#    echo "!!!findFile SYSTEM_FILE: $SYSTEM_FILE"
#    q=${SYSTEM_FILE:-$(echo ${GHCUP_DIR} | grep $1$ | head -n 1)}
#    echo "!!!findFile q: $q"
#    echo $q
    
    find ${MODULE_DIR}/dist-newstyle | grep $1$ | head -n 1
}


BUILT_LIB=$(find ${MODULE_DIR}/dist-newstyle | grep "libHS${MODULE_NAME}.*inplace-.*dylib$" | head -n 1)


collectDeps() {
#    echo "!!!collectDeps: key: $1, value: $2"
    echo "!!!collectDeps: ($1), ($2)"

    EXT_FILE=${2:-$(findFile $1)}
    FILE=${EXT_FILE:-$(findFileLocally $1)}
#    echo "!!!will assign ${1} -> $FILE"
#    echo "!!!allDeps before: ${allDeps[$1]}"
    allDeps[$1]=${FILE}
#    echo "!!!allDeps: ${allDeps}"
#    echo "!!!allDeps after: ${allDeps[$1]}"
    echo "!!!otool for: ${FILE}"
    otool -L ${FILE} | grep -o 'libHS.*.dylib' | while read line
    do
        echo "!!!otool line: ${line}"
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
#libHSrts-ghc
    # echo "$(zsh find_rts_lib.sh)"
    # echo ${GHC_LIBS} | grep "$(zsh find_rts_lib.sh)"
    # echo ${GHC_LIBS}
    RTS_LIB_FILE_NAME=$(zsh find_rts_lib.sh)
    RTS_LIB_FILE=$(echo ${GHC_LIBS} | grep "${RTS_LIB_FILE_NAME}")
#    RTS_LIB_FILE=$(echo ${GHC_LIBS} | grep "libHSrts-ghc8.10.7" | head -n 1)
#    RTS_LIB_FILE=$(echo ${GHC_LIBS} | grep "libHSrts_thr_l-ghc8.10.7" | head -n 1)
#    RTS_LIB_FILE=$(echo ${GHC_LIBS} | grep "libHSrts_thr_debug-ghc8.10.7" | head -n 1)
#    RTS_LIB_FILE=$(echo ${GHC_LIBS} | grep "libHSrts-1.0.2_thr_debug-ghc9.2.1.dylib" | head -n 1)

    # echo "@@RTS_LIB_FILE: ${RTS_LIB_FILE}"


    # RTS_LIB_FILE_NAME=$(basename ${RTS_LIB_FILE})
    allDeps[${RTS_LIB_FILE_NAME}]=${RTS_LIB_FILE}
}

updateLibs() {
    # CABAL_DIR=${HOME}/.cabal
    CABAL_DIR=$(zsh current_cabal_store_dir.sh)
    # GHCUP_DIR=${HOME}/.ghcup
    GHCUP_DIR=$(zsh current_ghc_dir.sh)

    CABAL_LIBS=$(find ${CABAL_DIR} | grep 'lib.*.dylib')
    GHC_LIBS=$(find ${GHCUP_DIR} | grep 'lib.*.dylib')
    HASKELL_LIBS="${CABAL_LIBS}\n${GHC_LIBS}"

    echo "@@1"

    addRts
    echo "LIB_FILE_NAME: ${LIB_FILE_NAME}"
    echo "BUILT_LIB: ${BUILT_LIB}"
    collectDeps ${LIB_FILE_NAME} ${BUILT_LIB}

    echo "!!!!allDeps: ${allDeps}"
    
    mkdir -p ${LIB_DIR}

    (rm ${LIB_DIR}/* || true) 2> /dev/null
    cp ${allDeps} ${LIB_DIR}
    
    echo "!!!1"
    
    # cp ${BUILT_LIB} ${RAW_LIB}
    
    echo "!!!2"
    
#    cp ${RAW_LIB} ${LIB}
    
    echo "!!!3"

    if [ ${PLATFORM_NAME} = ${IPHONESIMULATOR_PLATFORM} ]; then
        markLibsForSimulator
    else
        markLibsForIos
    fi
    
    echo "!!!4"

#    reduceMinOsVer
    
    echo "!!!5"

    signLibs
    
    echo "!!!6"

    echo "LIB_DIR: ${LIB_DIR}"
    find ${LIB_DIR}
    # find ${LIB_DIR} | grep dylib$ > "${MODULE_DIR}/.filesToLink"
    # FILES_TO_LINK=$(cd $(dirname ${LIB_DIR}) && find $(basename ${LIB_DIR}) | grep dylib$)
    # if [ ${LINK_IMMEDIATELY} = 0 ]; then
    #     FILES_TO_LINK=$(echo "${FILES_TO_LINK}" | grep -v ${LIB_FILE_NAME})
    # fi
    # # (cd ${LIB_DIR} && find . | grep dylib$ | grep -v ${LIB_FILE_NAME} > "${MODULE_DIR}/.filesToLink")
    # echo "${FILES_TO_LINK}"
    # echo "${FILES_TO_LINK}" > "${MODULE_DIR}/.filesToLink"
    # LIB_FILE_NAME
#    echo ${LIB} > .filesToLink
    
    echo "!!!7"
}

updateLibs
#(isCurrentPlatformUnchanged && test -f ${LIB} && diff ${BUILT_LIB} ${RAW_LIB}) || updateLibs

mkdir -p "${ALL_FRAMEWORKS_DIR}"
rsync -a ${MODULE_DIR}/Frameworks/* ${ALL_FRAMEWORKS_DIR}/

FILES_TO_LINK=$(cd ${MODULE_DIR} && find Frameworks | grep dylib$)

if [ ${LINK_IMMEDIATELY} = 0 ]; then
    FILES_TO_LINK=$(echo "${FILES_TO_LINK}" | grep -v ${LIB_FILE_NAME})
fi
# (cd ${LIB_DIR} && find . | grep dylib$ | grep -v ${LIB_FILE_NAME} > "${MODULE_DIR}/.filesToLink")
echo "${FILES_TO_LINK}"
# echo "${FILES_TO_LINK}" > "${MAIN_DIR}/.filesToLink"

{ echo $(cat "${MAIN_DIR}/.filesToLink") & echo "${FILES_TO_LINK}" } | sort | uniq | awk 'NF' > "${MAIN_DIR}/.filesToLink"


# ditto "${MAIN_DIR}/.filesToLink" "${MAIN_DIR}/.tmp_filesToLink"
# cat "${MODULE_DIR}/.filesToLink" >> "${MAIN_DIR}/.tmp_filesToLink"
# sort "${MAIN_DIR}/.tmp_filesToLink" | uniq > "${MAIN_DIR}/.filesToLink"
# rm "${MAIN_DIR}/.tmp_filesToLink"
