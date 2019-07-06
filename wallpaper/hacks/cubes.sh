#!/usr/bin/env bash

set -eu

if [[ "${#}" -eq 0 ]]; then
    echo "usage: RESOLUTION DESTINATION"
    exit 0
fi

declare -r PROGDIR=$( dirname "$( readlink -f "${0}" )" )
declare -r RESOLUTION=${1?Resolution}; shift
declare -r DESTINATION=${1?Destination}; shift

if [[ "${#}" -gt 0 ]]; then
    echo Unexpected arguments: "${@}"
    exit 1
fi

convert \
    -size "${RESOLUTION}" \
    -virtual-pixel tile \
    xc: \
    +noise Random \
    -blur 0x10 \
    -paint 3 \
    -auto-level \
    -modulate 100,150 \
    "${PROGDIR}/cubes-data.svg" \
    -compose Darken \
    -composite \
    \( +clone -blur 0x3 -normalize -alpha on -channel a -evaluate set 25% \) \
    -compose Over \
    -composite \
    "${DESTINATION}"
