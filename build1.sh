#!/bin/zsh

set -e

DIR=${0:a:h}

cd ${DIR}

MAIN_MODULE_NAME=notekeeper


IPHONEOS_PLATFORM="iphoneos"
IPHONESIMULATOR_PLATFORM="iphonesimulator"

PLATFORM_NAME=${PLATFORM_NAME:-$IPHONEOS_PLATFORM}

RELATIVE_LIBS_DIR=".build/dylibs/${PLATFORM_NAME}"
LIBS_DIR="${DIR}/${RELATIVE_LIBS_DIR}"

mkdir -p "${LIBS_DIR}"

markLibsForIos() {
    perl -pi -e 's/\x32\0\0\0(\x20|\x28)\0\0\0\x01\0\0\0\0(\0|\x01|\x02|\x03|\x04)(\x0b|\x0c)\0\0(\0|\x01|\x02|\x03|\x04)(\x0b|\x0c)\0/\x32\0\0\0\1\0\0\0\x02\0\0\0\0\2\3\0\0\4\5\0/g' ${1}
}

markLibsForSimulator() {
    perl -pi -e 's/\x32\0\0\0(\x20|\x28)\0\0\0\x01\0\0\0\0(\0|\x01|\x02|\x03|\x04)(\x0b|\x0c)\0\0(\0|\x01|\x02|\x03|\x04)(\x0b|\x0c)\0/\x32\0\0\0\1\0\0\0\x07\0\0\0\0\2\3\0\0\4\5\0/g' ${1}
}

markLibs() {
    if [ ${PLATFORM_NAME} = ${IPHONESIMULATOR_PLATFORM} ]; then
        markLibsForSimulator "${1}"
    else
        markLibsForIos "${1}"
    fi
}

signLibs() {
    codesign -f -s 949CA008AA70C44D456B5C63DFF47B488897AF14 "${1}"
}


for MODULE in $(ls -1 "${DIR}/modules"); do
    MODULES+=(${MODULE})
done


for MODULE in ${MODULES}; do
    EXISTING_LIB_PATH="$(find ${LIBS_DIR} | grep "${MODULE}-" | head -n 1)"

    if [ ! -f "${EXISTING_LIB_PATH}" ]; then
        CHANGED_MODULES+=(${MODULE})
        continue
    fi

    for SRC_FILE in $(find "${DIR}/modules/${MODULE}/src" | egrep "\.hs$|\.lhs$|\.c$"); do
        if [ "${SRC_FILE}" -nt "${EXISTING_LIB_PATH}" ]; then
            CHANGED_MODULES+=(${MODULE})
        fi
    done
done
echo "CHANGED_MODULES: ${CHANGED_MODULES}"


for MODULE in ${CHANGED_MODULES}; do
    MODULE_DIR="${DIR}/modules/${MODULE}"
    HS_SRC_FILES=$(cd ${MODULE_DIR} && find src | grep .hs$ | sed "s/src\//    /" | sed "s/.hs//" | sed "s/\//./" | sort)
    perl -i -pe "BEGIN{undef $/;} s/(exposed-modules:)(.*?)(  [a-z])/\1\n${HS_SRC_FILES}\n\3/sm" "${MODULE_DIR}/${MODULE}.cabal"
done


echo "packages:" > "${DIR}/root/cabal.project"
echo " ./" >> "${DIR}/root/cabal.project"
for MODULE in ${MODULES}; do
    echo " ./../modules/${MODULE}/*.cabal" >> "${DIR}/root/cabal.project"
done


for MODULE in ${MODULES}; do
    ROOT_DEPS+=("   ${MODULE},\n")
done

perl -i -pe "BEGIN{undef $/;} s/(build-depends:\n)(.*)(^(?!    $))/\1 ${ROOT_DEPS}\3/sm" "${DIR}/root/root.cabal"


(cd "${DIR}/root" && env -i HOME="$HOME" PATH="$PATH" USER="$USER" cabal build --ghc-options="-threaded -O2 +RTS -A64m -AL128m -qn8 -RTS -optc -Wno-nullability-completeness -optc -Wno-expansion-to-defined -optc -Wno-availability -optc -Wno-int-conversion")

for MODULE in ${CHANGED_MODULES}; do
    for LIB in ${DIR}/root/dist-newstyle/build/*/*/${MODULE}*/build/*.dylib; do
        LIB_NAME=$(basename ${LIB})
        UPDATED_LIB="${LIBS_DIR}/${LIB_NAME}"
        cp "${LIB}" "${UPDATED_LIB}"
        # (markLib "${UPDATED_LIB}" && signLib "${UPDATED_LIB}") || rm "${UPDATED_LIB}"
        UPDATED_LIBS+=(${LIB_NAME})
    done
done

declare -A existingLibs

for EXISTING_LIB_FILE_NAME in $(ls "${LIBS_DIR}"); do
    existingLibs[${EXISTING_LIB_FILE_NAME}]=1
done


CABAL_DIR=$(zsh current_cabal_store_dir.sh)
GHCUP_DIR=$(zsh current_ghc_dir.sh)

CABAL_LIBS=$(find ${CABAL_DIR} | grep 'lib.*.dylib')
GHC_LIBS=$(find ${GHCUP_DIR} | grep 'lib.*.dylib')
HASKELL_LIBS="${CABAL_LIBS}\n${GHC_LIBS}"

declare -A allDeps

addRtsToDeps() {
    RTS_LIB_FILE_NAME=$(zsh find_rts_lib.sh)
    RTS_LIB_FILE=$(echo ${GHC_LIBS} | grep "${RTS_LIB_FILE_NAME}")
    allDeps[${RTS_LIB_FILE_NAME}]=${RTS_LIB_FILE}
}

for key val in "${(@kv)existingLibs}"; do
    if [[ $key == libHSrts* ]]; then
        RTS_ALREADY_COPIED=1
    fi
done

if [ -z "${RTS_ALREADY_COPIED}" ]; then
    echo "Add rts to deps"
    addRtsToDeps
fi


findFile() {
    echo ${HASKELL_LIBS} | grep $1$ | head -n 1
}

collectDeps() {
    LIB_FILE_NAME=${1}
    if [ -n "${allDeps[$LIB_FILE_NAME]}" ]; then
        return
    fi
    LIB_FILE_PATH=${2}

    allDeps[${LIB_FILE_NAME}]=${LIB_FILE_PATH}

    otool -L ${LIB_FILE_PATH} | grep -v "\-inplace\-" | grep -o 'libHS.*.dylib' | while read LIB_FILE_NAME; do
        collectDeps ${LIB_FILE_NAME} $(findFile ${LIB_FILE_NAME})
    done
}

for MODULE in ${CHANGED_MODULES}; do
    for BUILT_LIB in ${DIR}/root/dist-newstyle/build/*/*/${MODULE}*/build/*.dylib; do
        LIB_FILE_NAME=$(basename ${BUILT_LIB})
        collectDeps ${LIB_FILE_NAME} ${BUILT_LIB}
    done
done


# for key val in "${(@kv)allDeps}"; do
#     echo "allDeps: ${key} -> ${val}"
# done

# for key val in "${(@kv)immediateToLink}"; do
#     echo "immediateToLink: ${key} -> ${val}"
# done

for LIB_FILE_NAME LIB_FILE_PATH in "${(@kv)allDeps}"; do
    if [ -z "${existingLibs[$LIB_FILE_NAME]}" ]; then
        UPDATED_LIB="${LIBS_DIR}/${LIB_FILE_NAME}"
        cp "${LIB_FILE_PATH}" "${UPDATED_LIB}"
        # (markLib "${UPDATED_LIB}" && signLib "${UPDATED_LIB}") || rm "${UPDATED_LIB}"
        UPDATED_LIBS+=(${LIB_FILE_NAME})
    fi
done


declare -A immediateToLink

collectImmediateToLink() {
    LIB_FILE_NAME=${1}
    if [ -n "${immediateToLink[$LIB_FILE_NAME]}" ]; then
        return
    fi
    LIB_FILE_PATH=${2}

    immediateToLink[${LIB_FILE_NAME}]=${LIB_FILE_PATH}
     
    otool -L ${LIB_FILE_PATH} | grep -o "libHS.*dylib" | while read LIB_FILE_NAME; do
        collectImmediateToLink ${LIB_FILE_NAME} "${LIBS_DIR}/${LIB_FILE_NAME}"
    done
}

# for key val in "${(@kv)existingLibs}"; do
#     if [[ $key == libHSrts* ]]; then
#         RTS_ALREADY_COPIED=1
#     fi
# done

# find
# $(ls -1 "${LIBS_DIR}")
# (cd ${LIBS_DIR} && )

MAIN_LIB_PATH=$(find ${LIBS_DIR} | grep "libHS${MAIN_MODULE_NAME}-" | head -n 1)

collectImmediateToLink $(basename ${MAIN_LIB_PATH}) ${MAIN_LIB_PATH}
immediateToLink[${RTS_LIB_FILE_NAME}]=${RTS_LIB_FILE}


for key val in "${(@kv)immediateToLink}"; do
    echo "${key} -> ${val}"
done

if [ -n "${UPDATED_LIBS}" ]; then
    echo "!!!LIBS_DIR: ${LIBS_DIR}"
    echo "!!!UPDATED_LIBS: ${UPDATED_LIBS}"
    # (cd ${LIBS_DIR} && markLibs ${UPDATED_LIBS} && signLibs ${UPDATED_LIBS})
    (cd ${LIBS_DIR} && for i in ${UPDATED_LIBS}; do markLibs $i; done && signLibs ${UPDATED_LIBS})
fi

echo -n "" > "${DIR}/.filesToLink"
for FILE_NAME val in "${(@kv)immediateToLink}"; do
    echo "${RELATIVE_LIBS_DIR}/${FILE_NAME}" >> "${DIR}/.filesToLink"
done


# (cd ${LIBS_DIR} && markLibsForIos ${UPDATED_LIBS} && codesign -f -s 949CA008AA70C44D456B5C63DFF47B488897AF14 ${UPDATED_LIBS})

# markLibsForIos ${LIBS_DIR}/*
# codesign -f -s 949CA008AA70C44D456B5C63DFF47B488897AF14 ${LIBS_DIR}/*

# LINKED_TO_DIR=$(readlink -f "${DIR}/dylibs")

# if [ "${LINKED_TO_DIR}" != "${LIBS_DIR}" ]; then
#     echo "Switch to ${LIBS_DIR}"
#     rm -f "${DIR}/dylibs"
#     ln -s "${LIBS_DIR}" "${DIR}/dylibs"
# fi

# echo "allDeps2: ${allDeps}"


# updateLibs() {
    # CABAL_DIR=$(zsh current_cabal_store_dir.sh)
    # GHCUP_DIR=$(zsh current_ghc_dir.sh)

    # CABAL_LIBS=$(find ${CABAL_DIR} | grep 'lib.*.dylib')
    # GHC_LIBS=$(find ${GHCUP_DIR} | grep 'lib.*.dylib')
    # HASKELL_LIBS="${CABAL_LIBS}\n${GHC_LIBS}"

    # addRts
    # collectDeps ${LIB_FILE_NAME} ${BUILT_LIB}
    
    # mkdir -p ${LIB_DIR}

    # (rm ${LIB_DIR}/* || true) 2> /dev/null
    # cp ${allDeps} ${LIB_DIR}

    # if [ ${PLATFORM_NAME} = ${IPHONESIMULATOR_PLATFORM} ]; then
    #     markLibsForSimulator
    # else
    #     markLibsForIos
    # fi

    # signLibs
# }

# LIBS_DIR="${DIR}/.build/dylibs/${PLATFORM_NAME}"



# MODULES=$(cd ${MODULE_DIR} && find src | grep .hs$ | sed "s/src\//    /" | sed "s/.hs//" | sed "s/\//./" | sort)
# perl -i -pe "BEGIN{undef $/;} s/(exposed-modules:)(.*?)(  [a-z])/\1\n${MODULES}\n\3/sm" ${MODULE_DIR}/${MODULE_NAME}.cabal

# MODULE_DIR

# Frameworks/libHSnotekeeper-0.1.0.0-inplace-ghc9.5.20221014.dylib
# Frameworks/libHSrts-1.0.2_thr-ghc9.5.20221014.dylib


# target:
#  1) dylibs
#  2) .filesToLink: main + rts
#  
# Makefile: rebuild when date of dylibs < date of sources (.hs, .c, .lhs)
# 
# build separate modules?
# generalize patch for all versions
# save separate results for each platform (make symlink)
# 
# actions:
#  1) (many) add sources to cabal files
#  2) (one/many) add modules to cabal.project
#  3) (one) cabal build
#  4) (many) copy&patch&sign only changed dylibs
#  5) (one) create .filesToLink (add main + rts)
#  



# MODULE_NAME=$(basename ${1})
# MAIN_MODULE_NAME=notekeeper

# if [[ ${MODULE_NAME} == ${MAIN_MODULE_NAME} ]]; then
#     LINK_IMMEDIATELY=1
# else
#     LINK_IMMEDIATELY=0
# fi

# MODULE_DIR=${1}

# MAIN_DIR=$(dirname $(dirname ${MODULE_DIR}))
# ALL_FRAMEWORKS_DIR="${MAIN_DIR}/Frameworks"

# # BUILD_DIR="${MAIN_DIR}/dist-newstyle"
# BUILD_DIR="${MODULE_DIR}/dist-newstyle"

# #source ~/.ghcup/env
# #export PATH="/opt/homebrew/opt/llvm/bin:$PATH"
# #export PATH="/usr/local/bin:/opt/homebrew/opt/llvm/bin:$PATH"

# MODULES=$(cd ${MODULE_DIR} && find src | grep .hs$ | sed "s/src\//    /" | sed "s/.hs//" | sed "s/\//./" | sort)
# perl -i -pe "BEGIN{undef $/;} s/(exposed-modules:)(.*?)(  [a-z])/\1\n${MODULES}\n\3/sm" ${MODULE_DIR}/${MODULE_NAME}.cabal

# #env -i HOME="$HOME" PATH="$PATH" USER="$USER" cabal build --enable-static --ghc-options='-threaded -O2 +RTS -A64m -AL128m -qn8'
# #env -i HOME="$HOME" PATH="$PATH" USER="$USER" cabal build --enable-static --ghc-option=-threaded

# #cabal new-build --ghc-option="`pkg-config --cflags libffi`"

# #PKG_CONFIG=/opt/homebrew/bin/pkg-config

# #echo "!!!!pkg-config --cflags libffi: `pkg-config --cflags libffi`"

# #/opt/homebrew/bin/pkg-config --cflags libffi
# #/Library/Developer/CommandLineTools/SDKs/MacOSX12.0.sdk/usr/include/ffi

# #-fllvm


# #env -i HOME="$HOME" PATH="$PATH" USER="$USER" cabal update
# #env -i HOME="$HOME" PATH="$PATH" USER="$USER" cabal build --enable-static --ghc-options="-fllvm -threaded -O2 +RTS -A64m -AL128m -qn8 -RTS -optc -Wno-nullability-completeness -optc -Wno-expansion-to-defined -optc -Wno-availability -optc -Wno-int-conversion -optc -I/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/include/ffi -optc -I/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk/usr/include -optl -L/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk/usr/lib"
# (cd ${MODULE_DIR} && env -i HOME="$HOME" PATH="$PATH" USER="$USER" cabal build --ghc-options="-threaded -O2 +RTS -A64m -AL128m -qn8 -RTS -optc -Wno-nullability-completeness -optc -Wno-expansion-to-defined -optc -Wno-availability -optc -Wno-int-conversion")
# #env -i HOME="$HOME" PATH="$PATH" USER="$USER" cabal build --ghc-options="-threaded -O2 +RTS -A64m -AL128m -qn8 -RTS -optc -Wno-nullability-completeness -optc -Wno-expansion-to-defined -optc -Wno-availability -optc -Wno-int-conversion -optc -I/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/include/ffi -optc -I/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk/usr/include -optl -L/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk/usr/lib"

# #env -i HOME="$HOME" PATH="$PATH" USER="$USER" cabal build --ghc-options="-fllvm -optc -Wno-nullability-completeness -optc -Wno-expansion-to-defined -optc -Wno-availability -optc -I/Library/Developer/CommandLineTools/SDKs/MacOSX12.0.sdk/usr/include/ffi -optc -I/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk/usr/include -optl -L/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk/usr/lib"

# #env -i HOME="$HOME" PATH="$PATH" USER="$USER" cabal build --enable-static --ghc-options="-fllvm -optc -Wno-nullability-completeness -optc -Wno-expansion-to-defined -optc -Wno-availability -optc -I/Library/Developer/CommandLineTools/SDKs/MacOSX12.0.sdk/usr/include/ffi -optc -I/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk/usr/include -optl -L/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk/usr/lib"

# (rm -f cabal.project.local~* || true) 2> /dev/null


# LIB_DIR=${MODULE_DIR}/Frameworks
# #LIB_DIR=${DIR}

# echo "!BUILD_DIR: ${BUILD_DIR}"

# #BUILT_LIB=$(find ${DIR} | grep ".*inplace-.*a$")
# BUILT_LIB=$(find ${BUILD_DIR} | grep "libHS${MODULE_NAME}.*inplace-.*dylib$" | head -n 1)
# #BUILT_LIB=$(find ${DIR}/dist-newstyle | grep ".*inplace-.*a$" | head -n 1)

# #echo "!!!BUILT_LIB: ${BUILT_LIB}"

# echo "!BUILT_LIB: ${BUILT_LIB}"

# # [ -n "${BUILT_LIB}" ] && 

# LIB_FILE_NAME=$(basename ${BUILT_LIB})

# #echo "!!!LIB_FILE_NAME: ${LIB_FILE_NAME}"

# #LIB=${LIB_FILE_NAME}
# LIB=${LIB_DIR}/${LIB_FILE_NAME}

# # RAW_LIB=${MODULE_DIR}/.raw_${LIB_FILE_NAME}


# IPHONEOS_PLATFORM="iphoneos"
# IPHONESIMULATOR_PLATFORM="iphonesimulator"

# PLATFORM_NAME=${PLATFORM_NAME:-$IPHONEOS_PLATFORM}

# # CURRENT_PLATFORM_FILE=.currentPlatform

# reduceMinOsVer() {
#     # forall *.o: LC_BUILD_VERSION: Minimum OS Version 12 -> 11
# #    perl -pi -e 's/(\62\0\0\0.{4}\02\0\0\0\0\0)\14/\1\13/g' ${LIB}

# #    perl -pi -e 's/\x32\0\0\0\x20\0\0\0\x01\0\0\0\0\0\x0c\0\0\0\0\0/\x32\0\0\0\x20\0\0\0\x02\0\0\0\0\0\x0c\0\0\0\0\0/g' ${LIB}
# #    perl -pi -e 's/\x32\0\0\0\x20\0\0\0\x01\0\0\0\0\0\x0b\0\0\0\0\0/\x32\0\0\0\x20\0\0\0\x02\0\0\0\0\0\x0b\0\0\0\0\0/g' ${LIB}
# #    perl -pi -e 's/\x32\0\0\0\x18\0\0\0\x01\0\0\0\0\0\x0c\0\0\0\0\0/\x32\0\0\0\x18\0\0\0\x02\0\0\0\0\0\x0c\0\0\0\0\0/g' ${LIB}
# #    perl -pi -e 's/\x32\0\0\0\x18\0\0\0\x01\0\0\0\0\0\x0b\0\0\0\0\0/\x32\0\0\0\x18\0\0\0\x02\0\0\0\0\0\x0b\0\0\0\0\0/g' ${LIB}
# #    perl -pi -e 's/\x32\0\0\0\x18\0\0\0\x01\0\0\0\0\0\x0c\0\0\x01\x0c\0/\x32\0\0\0\x18\0\0\0\x02\0\0\0\0\0\x0c\0\0\x01\x0c\0/g' ${LIB}
# #
# #    perl -pi -e 's/\x32\0\0\0\x18\0\0\0\x01\0\0\0\0\0\x0b\0\0\x03\x0b\0/\x32\0\0\0\x18\0\0\0\x02\0\0\0\0\0\x0b\0\0\x03\x0b\0/g' ${LIB}

# }

# markLibsForIos() {
#     perl -pi -e 's/\x32\0\0\0(\x20|\x28)\0\0\0\x01\0\0\0\0\0(\x0b|\x0c)\0\0(\0|\x01|\x02|\x03|\x04)(\x0b|\x0c)\0/\x32\0\0\0\1\0\0\0\x02\0\0\0\0\0\2\0\0\3\4\0/g' ${LIB_DIR}/*
# }

# markLibsForSimulator() {
#     perl -pi -e 's/\x32\0\0\0(\x20|\x28)\0\0\0\x01\0\0\0\0\0(\x0b|\x0c)\0\0(\0|\x01|\x02|\x03|\x04)(\x0b|\x0c)\0/\x32\0\0\0\1\0\0\0\x07\0\0\0\0\0\2\0\0\3\4\0/g' ${LIB_DIR}/*
# }

# signLibs() {
#     # codesign -f -s 949CA008AA70C44D456B5C63DFF47B488897AF14 ${LIB_DIR}/*
# }

# # isCurrentPlatformUnchanged() {
# #     grep -F ${PLATFORM_NAME} ${CURRENT_PLATFORM_FILE} > /dev/null
# # #    exit 0
# # }

# declare -A allDeps

# findFile() {
#     echo ${HASKELL_LIBS} | grep $1$ | head -n 1
# }

# findFileLocally() {
#     find ${BUILD_DIR} | grep $1$ | head -n 1
# }


# BUILT_LIB=$(find ${BUILD_DIR} | grep "libHS${MODULE_NAME}.*inplace-.*dylib$" | head -n 1)


# collectDeps() {
#     EXT_FILE=${2:-$(findFile $1)}
#     FILE=${EXT_FILE:-$(findFileLocally $1)}
#     allDeps[$1]=${FILE}
#     otool -L ${FILE} | grep -o 'libHS.*.dylib' | while read line
#     do
#         [ -z "${allDeps[$line]}" ] && collectDeps $line
#     done
# }

# addRts() {
#     RTS_LIB_FILE_NAME=$(zsh find_rts_lib.sh)
#     RTS_LIB_FILE=$(echo ${GHC_LIBS} | grep "${RTS_LIB_FILE_NAME}")
#     allDeps[${RTS_LIB_FILE_NAME}]=${RTS_LIB_FILE}
# }

# updateLibs() {
#     # CABAL_DIR=${HOME}/.cabal
#     CABAL_DIR=$(zsh current_cabal_store_dir.sh)
#     # GHCUP_DIR=${HOME}/.ghcup
#     GHCUP_DIR=$(zsh current_ghc_dir.sh)

#     CABAL_LIBS=$(find ${CABAL_DIR} | grep 'lib.*.dylib')
#     GHC_LIBS=$(find ${GHCUP_DIR} | grep 'lib.*.dylib')
#     HASKELL_LIBS="${CABAL_LIBS}\n${GHC_LIBS}"

#     addRts
#     collectDeps ${LIB_FILE_NAME} ${BUILT_LIB}
    
#     mkdir -p ${LIB_DIR}

#     (rm ${LIB_DIR}/* || true) 2> /dev/null
#     cp ${allDeps} ${LIB_DIR}

#     if [ ${PLATFORM_NAME} = ${IPHONESIMULATOR_PLATFORM} ]; then
#         markLibsForSimulator
#     else
#         markLibsForIos
#     fi

#     signLibs
# }

# updateLibs
# #(isCurrentPlatformUnchanged && test -f ${LIB} && diff ${BUILT_LIB} ${RAW_LIB}) || updateLibs

# mkdir -p "${ALL_FRAMEWORKS_DIR}"
# rsync -a ${MODULE_DIR}/Frameworks/* ${ALL_FRAMEWORKS_DIR}/

# FILES_TO_LINK=$(cd ${MODULE_DIR} && find Frameworks | grep dylib$)

# if [ ${LINK_IMMEDIATELY} = 0 ]; then
#     FILES_TO_LINK=$(echo "${FILES_TO_LINK}" | grep -v ${LIB_FILE_NAME})
# fi
# # (cd ${LIB_DIR} && find . | grep dylib$ | grep -v ${LIB_FILE_NAME} > "${MODULE_DIR}/.filesToLink")
# # echo "${FILES_TO_LINK}" > "${MAIN_DIR}/.filesToLink"

# { echo $(cat "${MAIN_DIR}/.filesToLink") & echo "${FILES_TO_LINK}" } | sort | uniq | awk 'NF' > "${MAIN_DIR}/.filesToLink"


# # ditto "${MAIN_DIR}/.filesToLink" "${MAIN_DIR}/.tmp_filesToLink"
# # cat "${MODULE_DIR}/.filesToLink" >> "${MAIN_DIR}/.tmp_filesToLink"
# # sort "${MAIN_DIR}/.tmp_filesToLink" | uniq > "${MAIN_DIR}/.filesToLink"
# # rm "${MAIN_DIR}/.tmp_filesToLink"
