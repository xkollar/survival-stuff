#!/usr/bin/env bash

set -eu

PROGDIR=$( dirname "$( readlink -f "${0}" )" )

convert \
    -size 1920x1200 \
    -virtual-pixel tile \
    xc: \
    +noise Random \
    -blur 0x10 \
    -paint 3 \
    -auto-level \
    -modulate 100,150 \
    "${PROGDIR}/generate-cubes-data.svg" \
    -compose Darken \
    -composite \
    ~/.generated-bg.png

feh --image-bg black --bg-tile ~/.generated-bg.png
# while :; do echo -ne "\\n$(date +'[%FT%T] Generating')... "; bash ~/.xmonad/wallpaper/generate-loops.sh; echo -n done; sleep 300; done
