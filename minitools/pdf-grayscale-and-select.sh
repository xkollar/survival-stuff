#!/usr/bin/env bash

set -eu

echo not ready yet
exit 1

tmp=$( mktemp -d )

gs \
    -sDEVICE=pdfwrite \
    -sProcessColorModel=DeviceGray \
    -sColorConversionStrategy=Gray \
    -dPrinted \
    -dBlackText \
    -dOverrideICC \
    -dNOPAUSE \
    -dBATCH \
    -dSAFER \
    -sPageList=216-247 \
    -sOutputFile=eff-guide.pdf \
    otp-system-documentation.pdf

pdfjam \
    --suffix nup \
    --nup 2x1 \
    --landscape \
    eff-guide.pdf
