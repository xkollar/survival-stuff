#!/usr/bin/env bash

readonly MAX_MEMORY_SIZE=$((1024*1024*8))
readonly VIRTUAL_MEMORY=$((1024*1024*8))

ulimit -v "${VIRTUAL_MEMORY}" -m "${MAX_MEMORY_SIZE}"

exec "${@}"
