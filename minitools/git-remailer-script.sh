#!/usr/bin/env bash

export FROM=${1:?FROM}; shift
export TO=${1:?TO}; shift


git filter-branch -f --env-filter '
if [[ "${GIT_COMMITTER_EMAIL}" = "${FROM}" ]]; then
    GIT_COMMITTER_EMAIL="${TO}";
fi

if [[ "${GIT_AUTHOR_EMAIL}" = "${FROM}" ]]; then
    GIT_AUTHOR_EMAIL="${TO}";
fi
' -- "${@}"

echo 'To remove original, run'
echo 'git update-ref -d refs/original/refs/heads/master'
