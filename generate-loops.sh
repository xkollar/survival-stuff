#!/usr/bin/env bash

set -eu

PROGDIR=$( dirname "$( readlink -f "${0}" )" )

convert \
    -size 1280x800 xc: +noise Random \
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
    +antialias -background transparent "${PROGDIR}/x.svg" -gravity center -composite \
    ~/.generated-bg.png

    # -shave 1x1 -bordercolor black -border 1x1 \

feh --image-bg black --bg-tile ~/.generated-bg.png
# while :; do echo -ne "\\n$(date +'[%FT%T] Generating')... "; bash ~/.xmonad/wallpaper/generate-loops.sh; echo -n done; sleep 300; done
