#!/usr/bin/env bash

set -eu

log=$( awslogs groups | fzf )

while true; do
    seq 10
    awslogs get "${@:--w}" "${log}"
    echo -n "Again ${log}? "
    read -r
done
