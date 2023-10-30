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
makepkg --printsrcinfo > .SRCINFO
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

# Push the changes to the AUR.
aur_clone="/tmp/aur-${name}"

git clone "ssh://aur@aur.archlinux.org/${name}.git" "${aur_clone}"
cp PKGBUILD "${aur_clone}/PKGBUILD"
cp .SRCINFO "${aur_clone}/.SRCINFO"
cd "${aur_clone}"
git add PKGBUILD .SRCINFO

aur_branch="$(git rev-parse --abbrev-ref HEAD)"

if git commit -m "Update ${name} to v${version}"
then
    for i in {1..3}
    do
        info 'Pushing to the AUR'
        git push origin "${aur_branch}" && break
        info "Push attempt $i failed, retrying..."
    done

    error 'Failed to push to the AUR'
else
    info 'Nothing to commit to the AUR'
fi
