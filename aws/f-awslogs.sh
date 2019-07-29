#!/usr/bin/env bash

set -eu

log=$( awslogs groups | fzf )
echo "${log}"

while true; do
    seq 10
    awslogs get "${@:--w}" "${log}"
    echo -n "Again ${log}? "
    read -r
done
