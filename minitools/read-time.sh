#!/usr/bin/env bash

set -eu

declare -a TO_DEL=()
function gc() {
    rm -rf "${TO_DEL[@]}"
}
trap gc EXIT

function has() {
    which "${1}" >& /dev/null
}

function say() {
    if has pico2wave && has aplay; then
        tmp_dir=$( mktemp -d )
        TO_DEL+=( "${tmp_dir}" );
        local file="${tmp_dir}/say.wav"
        pico2wave --wave="${file}" "${*}"
        aplay --quiet "${file}"
    elif has spd-say; then
        spd-say "${*}"
    elif has say; then
        \say "${@}"
    elif has festival; then
        # Not tested
        festival <<< "${@}"
    elif has espeak; then
        # Not tested
        espeak "${@}"
    fi
}

HOUR=$( date +'%-H' -d "${1:-now}" )
MINUTE=$( date +'%-M' -d "${1:-now}" )

declare -a SAY=()

if [[ "${HOUR}" -gt 0 && "${HOUR}" -lt 10 ]]; then
    SAY+=( 0 )
fi
SAY+=( "${HOUR}" )

if [[ "${MINUTE}" -eq 0 ]]; then
    SAY+=( hundred )
elif [[ "${MINUTE}" -gt 0 && "${MINUTE}" -lt 10 ]]; then
    SAY+=( 0 "${MINUTE}" )
else
    SAY+=( "${MINUTE}" )
fi
SAY+=( hours )

say "${SAY[@]}"
