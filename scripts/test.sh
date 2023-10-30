#!/usr/bin/env bash

set -e
source ./scripts/setup.sh

name="${1}"

if [[ "${name}" = '' ]]
then
    error 'The package name must be specified as the first argument'
fi

cd "${name}"

info 'Running test build'

if [[ -v CI ]]
then
    sudo -u build makepkg --cleanbuild --force --noconfirm --clean --syncdeps \
        --noconfirm --noprogressbar
else
    makepkg --cleanbuild --force --noconfirm --clean --syncdeps --noconfirm \
        --noprogressbar
fi

rm *.tar.gz
rm *.zst
