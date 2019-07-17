#!/usr/bin/env bash

set -eu

readonly PROG_DIR=$( cd "$( dirname "${0}" )" && pwd )

groupadd \
    --gid "${LOCAL_USER_GROUP:-1000}" dev \
        &> /dev/null || true
usermod \
    --uid "${LOCAL_USER_ID:-1000}" \
    --gid "${LOCAL_USER_GROUP:-1000}" \
    "${LOCAL_USER_NAME}" \
    &> /dev/null
groupmod \
    -g "${LOCAL_USER_GROUP:-1000}" \
    "${LOCAL_USER_NAME}" \
    &> /dev/null || true

## Do some superuser stuff here before dropping priviledges

true

## Remove control variables to keep environmnent reasonably clean
export -n LOCAL_USER_NAME LOCAL_USER_GROUP LOCAL_USER_ID

## And now play nice (mostly for file permissions)
HOME="/home/${LOCAL_USER_NAME}" setuidgid "${LOCAL_USER_NAME}" "${@-bash}"
