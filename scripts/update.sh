#!/usr/bin/env bash

set -e
source ./scripts/setup.sh

name="${1}"
version="${2}"

if [[ "${name}" = '' ]]
then
    echo 'The package name must be specified as the first argument'
    exit 1
fi

if [[ "${version}" = '' ]]
then
    echo 'The version must be specified as the second argument'
    exit 1
fi

cd "${name}"
sed --regexp-extended --in-place --expression \
    "s/pkgver=(.+)/pkgver=${version}/g" PKGBUILD

updpkgsums PKGBUILD

if [[ -v CI ]]
then
    sudo -u build makepkg --printsrcinfo | tee .SRCINFO
else
    makepkg --printsrcinfo > .SRCINFO
fi

rm *.tar.gz
git add PKGBUILD .SRCINFO

if git commit -m "Update ${name} to v${version}"
then
    for i in {1..3}
    do
        info 'Pushing to main'
        git push origin main && break
        info "Push attempt $i failed, retrying..."
    done

    error 'Failed to push the changes'
else
    info 'Nothing to commit'
fi
