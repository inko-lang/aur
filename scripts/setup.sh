#!/usr/bin/env bash

function info() {
    echo -e "\\033[1m\\033[32m>>>\\033[0m\\033[0m ${1}"
}

function error() {
    echo -e "\\033[1m\\033[31m!!!\\033[0m\\033[0m ${1}"
    exit 1
}

if [[ -v CI ]]
then
    info 'Configuring Git'
    git config --global user.email noreply@inko-lang.org
    git config --global user.name 'Inko bot'
    git config --global --add safe.directory '*'
fi
