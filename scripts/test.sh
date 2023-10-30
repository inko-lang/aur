#!/usr/bin/env bash

set -e

name="${1}"

if [[ "${name}" = '' ]]
then
    echo 'The package name must be specified as the first argument'
    exit 1
fi

cd "${name}"

if [[ -v CI ]]
then
    sudo -u build makepkg --cleanbuild --force --noconfirm --clean
else
    makepkg --cleanbuild --force --noconfirm --clean
fi

rm *.tar.gz
rm *.zst
