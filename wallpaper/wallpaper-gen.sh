#!/usr/bin/env bash

set -eu

declare -r PROGDIR=$( dirname "$( readlink -f "${0}" )" )

declare -r HACKS_DIR=${PROGDIR}/hacks

TARGET=${HOME}/.generated-bg.png

function resolutions() {
    xrandr | sed -n 's/\s\+\([0-9]\+\)x\([0-9]\+\)\s\+.*\*.*/\1 \2/p'
}

function get_resolution() {
    readonly x=$( resolutions | awk '{MAX=$1>MAX?$1:MAX}END{print MAX}' )
    readonly y=$( resolutions | awk '{MAX=$2>MAX?$2:MAX}END{print MAX}' )
    echo "${x}x${y}"
}

main() {
    resolution=$( get_resolution )
    mapfile -t -d $'\0' hacks < <( find "${HACKS_DIR}" -executable -type f -print0 )
    hack=${hacks[$(( RANDOM % ${#hacks[@]} ))]}
    "${hack}" "${resolution}" "${TARGET}"
    feh --image-bg black --bg-center "${TARGET}"
}

main "${@}"

# while :; do echo -n "$(date +'[%FT%T] Generating')... "; wallpaper-gen.sh; echo -n done; read -n 300 || echo; done
