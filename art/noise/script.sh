#!/usr/bin/env bash

set -eu

function mkName() {
    local -r prefix=${1?-Prefix}; shift
    local -r number=${1?-Number}; shift
    printf '%s-%03d.png' "${prefix}" "${number}"
}

function min() {
    if [[ "${1}" -le "${2}" ]]; then
        echo "${1}"
    else
        echo "${2}"
    fi
}

convert -depth 8 -colorspace RGB -size 800x600 xc: +noise Random base-000.png
# convert -size 800x600 xc: base-000.png
num=0
while [[ "${num}" -le 500 ]]; do
    echo "${num}"
    in_name=$( mkName base "${num}" )
    next_name=$( mkName base "$(( num+1 ))" )

    # convert "${in_name}" -virtual-pixel tile -blur 0x10 -paint 3 -auto-level -modulate 100,150 -blur 0x1 -edge 2 -equalize -normalize $( printf 'x-%03d.png' "$((num))" ) &
    # convert "${in_name}" -virtual-pixel tile -blur 0x10 -edge 10 -edge 1 -equalize -normalize $( printf 'x-%03d.png' "$((num))" ) &
    # convert "${in_name}" -virtual-pixel tile -blur 0x10 -equalize -edge 10 -edge 1 $( mkName x "${num}" ) &
    convert "${in_name}" -depth 8 -colorspace RGB -virtual-pixel tile -blur 0x10 -emboss 4 -blur 0x1 -edge 2 -normalize -modulate "$( min "${num}" 100 )" "$( mkName x "${num}" )" &
    if [[ -f "${next_name}" ]]; then
        if [[ "$( jobs -p | wc -l )" -gt 6 ]]; then
            wait -n
        fi
    else
        convert "${in_name}" -depth 32 -colorspace RGB -attenuate 0.02 +noise Impulse "${next_name}"
    fi
    let num+=1
done

wait

# convert -size 1920x1200 -virtual-pixel tile xc: +noise Random -paint 10 -equalize -blur 0x10 -auto-level -emboss 4 -edge 2 -normalize -modulate 150 x:
