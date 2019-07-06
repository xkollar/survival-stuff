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

convert -size ${RESOLUTION} xc: +noise Random \
    -virtual-pixel Tile \
    -resize '200%' \
    -blur 0x15 \
    -equalize \
    -edge 15 \
    -edge 1 \
    -resize '50%' \
    \( +clone -blur 0x3 -normalize -alpha on -channel a -evaluate set 25% \) \
    -composite \
    -normalize \
    "${DESTINATION}"
