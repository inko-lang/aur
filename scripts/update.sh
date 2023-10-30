#!/usr/bin/env bash

set -e
source ./scripts/setup.sh

name="${1}"
version="${2}"

if [[ "${name}" = '' ]]
then
    error 'The package name must be specified as the first argument'
fi

if [[ "${version}" = '' ]]
then
    error 'The version must be specified as the second argument'
fi

cd "${name}"

info 'Updating package version'

if [[ "${name}" == *-git ]]
then
    error 'Git packages must be updated manually'
fi

sed --regexp-extended --in-place --expression \
    "s/pkgver=(.+)/pkgver=${version}/g" PKGBUILD

info 'Updating checksum and .SRCINFO'

if [[ -v CI ]]
then
    sudo -u build updpkgsums PKGBUILD
    sudo -u build makepkg --printsrcinfo | tee .SRCINFO
    chown root:root PKGBUILD .SRCINFO *.tar.gz
else
    updpkgsums PKGBUILD
    makepkg --printsrcinfo > .SRCINFO
fi

rm *.tar.gz

info 'Pushing changes'
git add PKGBUILD .SRCINFO

if git commit -m "Update ${name} to v${version}"
then
    for i in {1..3}
    do
        info 'Pushing to main'
        git push origin main && exit 0
        info "Push attempt $i failed, retrying..."
    done

    error 'Failed to push the changes'
else
    info 'Nothing to commit'
fi
