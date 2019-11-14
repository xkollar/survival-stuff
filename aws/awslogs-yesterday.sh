#!/usr/bin/env bash
awslogs get \
    -s "$( date --iso=seconds -u -d 'yesterday 00:00:00' )" \
    -e "$( date --iso=seconds -u -d '00:00:00' )" \
    "${@}"
