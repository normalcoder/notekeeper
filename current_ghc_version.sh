#!/bin/zsh

set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

cd ${DIR}

readlink -f $(which ghc) | sed -nE 's/^.*\-(.*)$/\1/p'
