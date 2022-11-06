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
    perl -pi -e 's/\x32\0\0\0(\x20|\x28)\0\0\0\x01\0\0\0\0(\0|\x01|\x02|\x03|\x04)(\x0b|\x0c)\0\0(\0|\x01|\x02|\x03|\x04)(\x0b|\x0c)\0/\x32\0\0\0\1\0\0\0\x02\0\0\0\0\2\3\0\0\4\5\0/g' $@
}

markLibsForSimulator() {
    perl -pi -e 's/\x32\0\0\0(\x20|\x28)\0\0\0\x01\0\0\0\0(\0|\x01|\x02|\x03|\x04)(\x0b|\x0c)\0\0(\0|\x01|\x02|\x03|\x04)(\x0b|\x0c)\0/\x32\0\0\0\1\0\0\0\x07\0\0\0\0\2\3\0\0\4\5\0/g' $@
}

markLibs() {
    if [ ${PLATFORM_NAME} = ${IPHONESIMULATOR_PLATFORM} ]; then
        markLibsForSimulator $@
    else
        markLibsForIos $@
    fi
}

signLibs() {
    codesign -f -s D7F51AF2AD47BCB242BEC840F995F49AA74D4A1A $@
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


for LIB_FILE_NAME LIB_FILE_PATH in "${(@kv)allDeps}"; do
    if [ -z "${existingLibs[$LIB_FILE_NAME]}" ]; then
        UPDATED_LIB="${LIBS_DIR}/${LIB_FILE_NAME}"
        cp "${LIB_FILE_PATH}" "${UPDATED_LIB}"
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

MAIN_LIB_PATH=$(find ${LIBS_DIR} | grep "libHS${MAIN_MODULE_NAME}-" | head -n 1)

collectImmediateToLink $(basename ${MAIN_LIB_PATH}) ${MAIN_LIB_PATH}

RTS_LIB_PATH=$(find ${LIBS_DIR} | grep "libHSrts" | head -n 1)
immediateToLink[$(basename ${RTS_LIB_PATH})]=${RTS_LIB_PATH}


if [ -n "${UPDATED_LIBS}" ]; then
    (cd ${LIBS_DIR} && markLibs ${UPDATED_LIBS} && signLibs ${UPDATED_LIBS})
fi

RESULT_LIBS_DIR="${DIR}/dylibs"

mkdir -p ${RESULT_LIBS_DIR}

rsync -a ${LIBS_DIR}/* ${RESULT_LIBS_DIR}/

echo -n "" > "${DIR}/.filesToLink"
for FILE_NAME val in "${(@kv)immediateToLink}"; do
    echo "dylibs/${FILE_NAME}" >> "${DIR}/.filesToLink"
done
