#!/bin/zsh

set -e

# DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DIR=${0:a:h}

cd ${DIR}

echo "${HOME}/.cabal/store/ghc-$(zsh current_ghc_version.sh)"
