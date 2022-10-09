#!/bin/zsh

set -e

# DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DIR=${0:a:h}

cd ${DIR}

readlink -f $(which ghc) | sed -nE 's/^.*\-(.*)$/\1/p'
