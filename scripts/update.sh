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
    info 'Skipping version update for Git package'
else
    sed --regexp-extended --in-place --expression \
        "s/pkgver=(.+)/pkgver=${version}/g" PKGBUILD
fi

info 'Updating checksum and .SRCINFO'

if [[ -v CI ]]
then
    sudo -u build updpkgsums PKGBUILD
    sudo -u build makepkg --printsrcinfo | tee .SRCINFO
    chown root:root PKGBUILD .SRCINFO

    # Git packages don't produce source archives
    if [[ "${name}" != *-git ]]
    then
        chown root:root *.tar.gz
    fi
else
    updpkgsums PKGBUILD
    makepkg --printsrcinfo > .SRCINFO
fi

# info 'Running test build'
#
# if [[ -v CI ]]
# then
#     sudo -u build makepkg --cleanbuild --force --noconfirm --clean --syncdeps \
#         --noconfirm --noprogressbar
# else
#     makepkg --cleanbuild --force --noconfirm --clean --syncdeps --noconfirm \
#         --noprogressbar
# fi
#
# rm -f *.tar.gz
# rm -f *.zst

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
