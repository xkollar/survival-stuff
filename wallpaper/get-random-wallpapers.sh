#!/usr/bin/env bash

url=${1:-https://www.reddit.com/r/wallpaper/hot.json}

curl -s \
    -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:61.0) Gecko/20100101 Firefox/61.0' \
    -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8' \
    -H 'Accept-Language: en-US,en;q=0.5' \
    --compressed \
    "${url}" \
| jq -r '.data.children[].data.url' \
| grep '^https://i\.redd\.it/' \
| xargs --no-run-if-empty wget -c
