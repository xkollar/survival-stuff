#!/usr/bin/env bash

set -eu

if [[ "${#}" -eq 0 ]]; then
    echo "usage: RESOLUTION IMAGE DESTINATION"
    exit 0
fi

declare -r RESOLUTION=${1?Resolution}; shift
declare -r IMAGE=${1?Image}; shift
declare -r DESTINATION=${1?Destination}; shift

let N=RANDOM%5*2+4
IFS=x read WIDTH HEIGHT <<< "${RESOLUTION}"
let WIDTH/=N
let HEIGHT/=N

convert "${IMAGE}" \
    -scale ">${WIDTH}x${HEIGHT}" \
    -auto-level -depth 8 -remap netscape: \
    -scale "${N}00%" \
    -gravity Center \
    -background black \
    -extent "${RESOLUTION}" \
    "${DESTINATION}"
