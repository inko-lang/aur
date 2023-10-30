#!/usr/bin/env bash

set -e

name="${1}"

if [[ "${name}" = '' ]]
then
    echo 'The package name must be specified as the first argument'
    exit 1
fi

cd "${name}"
makepkg --cleanbuild --force --noconfirm --clean
rm *.tar.gz
rm *.zst
