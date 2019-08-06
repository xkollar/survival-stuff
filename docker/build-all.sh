#!/usr/bin/env bash

readonly PROG_DIR=$( dirname "$( realpath "${0}" )" )
readonly DOCKERFILES_DIR="${PROG_DIR}"/dockerfiles

find "${DOCKERFILES_DIR}" -type f -name Dockerfile -print0 \
| xargs -0 dirname \
| while read -r; do
    DIR=${REPLY}
    TAG="${DIR#${DOCKERFILES_DIR}/}"
    (
        cd "${DIR}" || exit 1
        docker build "${@}" -t "${TAG}" .
    )
done
