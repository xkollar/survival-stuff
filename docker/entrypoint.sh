#!/usr/bin/env bash

set -eu

readonly PROG_DIR=$( cd "$( dirname "${0}" )" && pwd -P )

groupadd \
    --gid "${LOCAL_USER_GROUP:-1000}" dev \
&> /dev/null \
|| true

if getent passwd "${LOCAL_USER_ID}" >/dev/null; then
    usermod \
        --login "${LOCAL_USER_NAME}" \
        "$( getent passwd "${LOCAL_USER_ID}" | sed 's/:.*//' )"
fi

if ! getent passwd "${LOCAL_USER_NAME}" >/dev/null; then
    useradd \
        --gid "${LOCAL_USER_GROUP}" \
        --uid "${LOCAL_USER_ID}" \
        --shell "$( grep --line-regexp "$( command -v bash )" /etc/shells )" \
        "${LOCAL_USER_NAME}"
else
    usermod \
        --uid "${LOCAL_USER_ID:-1000}" \
        --gid "${LOCAL_USER_GROUP:-1000}" \
        --home "/home/${LOCAL_USER_NAME}" \
        "${LOCAL_USER_NAME}" \
    &> /dev/null

    groupmod \
        -g "${LOCAL_USER_GROUP:-1000}" \
        "${LOCAL_USER_NAME}" \
    &> /dev/null || true
fi

if [[ ${HOST_DOCKER_GID+set} == set && -e /var/run/docker.sock ]]; then
    groupadd --non-unique --gid "${HOST_DOCKER_GID}" host-docker
    usermod --gid host-docker "${LOCAL_USER_NAME}" &> /dev/null || true
    # when we figure out how to not drop supplemental group
    # usermod --append --groups host-docker "${LOCAL_USER_NAME}"
fi

## Do some superuser stuff here before dropping priviledges

chown "${LOCAL_USER_NAME}:${LOCAL_USER_GROUP}" "/home/${LOCAL_USER_NAME}"

# So we can use screen
chown "${LOCAL_USER_NAME}:${LOCAL_USER_GROUP}" "$( tty )"

## Remove control variables to keep environmnent reasonably clean
export -n LOCAL_USER_NAME LOCAL_USER_GROUP LOCAL_USER_ID HOST_DOCKER_GID

if type -t setuidgid >/dev/null; then
    ## And now play nice (mostly for file permissions)
    HOME="/home/${LOCAL_USER_NAME}" setuidgid "${LOCAL_USER_NAME}" "${@-bash}"
else
    echo 'Command setuidgid not found in the docker image.'
    if [[ ${#} -eq 0 ]]; then
        echo 'Using '"'su'"' ... not ideal but *might* work.'
        su "${LOCAL_USER_NAME}"
    else
        "Exiting..."
    fi
fi
