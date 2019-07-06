#!/usr/bin/env bash

set -eu

if [[ "${#}" -eq 0 ]]; then
    echo "usage: RESOLUTION IMAGE DESTINATION"
    exit 0
fi

declare -r PROGDIR=$( dirname "$( readlink -f "${0}" )" )
declare -r RESOLUTION=${1?Resolution}; shift
declare -r IMAGE=${1?Image}; shift
declare -r DESTINATION=${1?Destination}; shift

convert "${IMAGE}" \
    -scale ">${RESOLUTION}" -scale 12.5% -scale 800% \
    \( -size 8x8 canvas:black +antialias -fill white -draw 'circle 3,3 0,3' -write mpr:tile +delete \) \
    \( +clone -fill mpr:tile  -draw 'color 0,0 reset' \) \
    -compose darken -composite \
    "${DESTINATION}"

