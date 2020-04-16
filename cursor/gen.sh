#!/usr/bin/env bash

set -eu

declare -a SIZES=( 32 64 128 256 )
target=${1:-theme}
mkdir "${target}"

for source in *.svg; do
    base=${source%.svg}
    tmpdir=$( mktemp -d )
    conf="${tmpdir}/${base}.conf"
    for size in "${SIZES[@]}"; do
        sized=${base}-${size}.png
        convert \
            +antialias \
            -size "${size}" \
            -background transparent \
            "${source}" \
            "${tmpdir}/${sized}"
        awk \
            --assign "size=${size}" \
            --assign "name=${sized}" \
            '{printf "%.f %.f %.f %s\n", size, size / $1 * $2, size / $1 * $3, name}' \
            "${base}.txt" \
        >> "${conf}"
    done
    xcursorgen --prefix "${tmpdir}" "${conf}" "${target}/${base}"
    rm -rf "${tmpdir}"
done
