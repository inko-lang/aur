#!/usr/bin/env bash

set -e
source ./scripts/setup.sh

name="${1}"
version="${2}"
ssh_key="${3}"
aur_clone="/tmp/aur-${name}"

if [[ "${name}" = '' ]]
then
    error 'The package name must be specified as the first argument'
fi

if [[ "${version}" = '' ]]
then
    error 'The version must be specified as the second argument'
fi

if [[ "${ssh_key}" = '' ]]
then
    error 'The SSH private key must be specified as the third argument'
fi

if [[ -v CI ]]
then
    info 'Configuring SSH'
    export SSH_AUTH_SOCK="/tmp/ssh_agent.sock"
    ssh-agent -a $SSH_AUTH_SOCK >/dev/null
    ssh-add - <<< "${ssh_key}"
fi

export GIT_SSH_COMMAND="ssh -o StrictHostKeyChecking=accept-new"

info 'Updating AUR'

cd "${name}"
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
