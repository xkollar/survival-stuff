#!/usr/bin/env bash

set -eu

declare -r PROGDIR=$( dirname "$( readlink -f "${0}" )" )

declare -r HACKS_DIR=${PROGDIR}/hacks

declare -r IMAGES_DIR=${PROGDIR}/images

TARGET=${HOME}/.generated-bg.png

function die() {
    echo "${@}" >& 2
    exit 1
}

function resolutions() {
    xrandr | sed -n 's/\s\+\([0-9]\+\)x\([0-9]\+\)\s\+.*\*.*/\1 \2/p'
}

function get_resolution() {
    readonly x=$( resolutions | awk '{MAX=$1>MAX?$1:MAX}END{print MAX}' )
    readonly y=$( resolutions | awk '{MAX=$2>MAX?$2:MAX}END{print MAX}' )
    echo "${x}x${y}"
}

function get_single_image_path() {
    find "${IMAGES_DIR}" -type f | shuf -n1 | xargs realpath
}

function run_hack() {
    local -r hack=${1}; shift
    if [[ "${1}" != "usage:" ]]; then
        die "Hack does not seem to follow the protocol."
    fi
    shift 1

    local -a HACK_ARGS=( )

    while [[ "${#}" -ne 0 ]]; do
        local current=${1}; shift
        case "${current}" in
            RESOLUTION)
                HACK_ARGS+=( "$( get_resolution )" )
                ;;
            DESTINATION)
                HACK_ARGS+=( "${TARGET}" )
                ;;
            IMAGE)
                HACK_ARGS+=( "$( get_single_image_path )" )
                ;;
            *) die "Protocol error (unknown parameter): ${current}"
                ;;
        esac
    done
    "${hack}" "${HACK_ARGS[@]}"
}

main() {
    mapfile -t -d $'\0' hacks < <( find "${HACKS_DIR}" -executable -type f -print0 )

    hack=${hacks[$(( RANDOM % ${#hacks[@]} ))]}
    mapfile -t usage < <( ${hack} | tr -d '\n' | tr ' ' '\n' )
    run_hack "${hack}" "${usage[@]}"

    feh --image-bg black --bg-center "${TARGET}"
}

main "${@}"

# while :; do echo -n "$(date +'[%FT%T] Generating')... "; wallpaper-gen.sh; echo -n done; read -n 300 || echo; done
