#!/usr/bin/env bash

set -eu


if [[ "${#}" -eq 0 ]]; then
    echo "usage: RESOLUTION IMAGE DESTINATION"
    exit 0
fi

declare -r RESOLUTION=${1?Resolution}; shift
declare -r IMAGE=${1?Image}; shift
declare -r DESTINATION=${1?Destination}; shift

if [[ "${#}" -gt 0 ]]; then
    echo Unexpected arguments: "${@}"
    exit 1
fi

convert "${IMAGE}" \
    -scale ">${RESOLUTION}^" \
    -gravity center \
    -extent ">${RESOLUTION}^" \
    -scale 5.5% \
    txt: \
| sed '1d; s/:.* /,/;' \
| sed 's/,/ /;s/,/ /' \
| awk '{printf "%d,%d,%s\n", ($1*2+$2%2)*10, $2*2*10, $3}' \
| convert "${IMAGE}" \
    -background black \
    -scale ">${RESOLUTION}^" \
    -gravity center \
    -extent ">${RESOLUTION}^" \
    -sparse-color voronoi '@-' \
    "${DESTINATION}"
