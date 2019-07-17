#!/usr/bin/env bash

set -eu

if [[ "${#}" -eq 0 ]]; then
    echo "usage: RESOLUTION DESTINATION"
    exit 0
fi

declare -r PROGDIR
PROGDIR=$( dirname "$( readlink -f "${0}" )" )
declare -r RESOLUTION=${1?Resolution}; shift
declare -r DESTINATION=${1?Destination}; shift

if [[ "${#}" -gt 0 ]]; then
    echo Unexpected arguments: "${@}"
    exit 1
fi

convert \
    -size "${RESOLUTION}" xc: +noise Random \
    -virtual-pixel tile \
    -modulate 100,50 \
    -blur 0x25 \
    +quantize \
    -normalize \
    -edge 25 \
    -auto-level \
    -edge 3 \
    -blur 0x1 \
    -channel l +normalize -channel all \
    -modulate $(( 100 + (RANDOM % 3) * 10 )),$(( 100 + (RANDOM % 3) * 10 )),$(( 50 + (RANDOM % 10) * 10 )) \
    -auto-level \
    -resize 50% \
    png:- \
| convert - +clone +clone +append +append +clone +clone -append -append - \
| convert - \
    +antialias \
    -background transparent \
    -size "${RESOLUTION}" \
    "${PROGDIR}/loops-data.svg" \
    -gravity center \
    -composite \
    -extent "${RESOLUTION}" \
    "${DESTINATION}"
