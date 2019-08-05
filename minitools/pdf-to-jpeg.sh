#!/usr/bin/env bash

gs \
    -dSAFER -dBATCH -dNOPAUSE \
    -sDEVICE=jpeg \
    -sOutputFile='print-%03d.jpg' \
    -r300 \
    -dTextAlphaBits=4 \
    -dGraphicsAlphaBits=4 \
`   "${1?:PDF to convert}"
