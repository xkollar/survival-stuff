#!/usr/bin/env bash

readonly PROG_DIR=$( dirname "$( realpath "${0}" )" )
readonly DOCKERFILES_DIR="${PROG_DIR}"/dockerfiles

find "${DOCKERFILES_DIR}" -type f -name Dockerfile \
| xargs dirname \
| while read -r; do
    DIR=${REPLY}
    TAG="test-${DIR#${DOCKERFILES_DIR}/}"
    (
        cd "${DIR}"
        docker build -t "${TAG}" .
    )
done
