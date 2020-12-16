#!/usr/bin/env bash

TERMINAL=$( realpath /proc/self/fd/0 )

if [[ "${SCRIPT_FILE+SET}" == SET ]]; then
    if [[ "${SCRIPT_TERMINAL+SET}" != SET ]]; then
        SCRIPT_TERMINAL="${TERMINAL}"
        export SCRIPT_TERMINAL
    fi
    if [[ "${SCRIPT_TERMINAL}" == "${TERMINAL}" ]]; then
        return
    else
        # SCRIPT_FILE is set -> we already have been invoked by this
        # SCRIPT_TERMINAL is set but wrong
        unset SCRIPT_TERMINAL
        true
    fi
fi


SCRIPT_DIR="${HOME}/scripts"
TERM_SUFFIX=$( sed 's/^\/[^/]*\///;s/\//-/g' <<< "${TERMINAL}" )
SCRIPT_FILE="${SCRIPT_DIR}/$( date -u +%FT%TZ )-${TERM_SUFFIX}.script.gz"

mkdir -p "${SCRIPT_DIR}"

unset SCRIPT_DIR
unset TERM_SUFFIX
unset TERMINAL
export SCRIPT_FILE

echo "Termianl recorded to ${SCRIPT_FILE}"
exec script --quiet >( exec nohup gzip > "${SCRIPT_FILE}" 2>/dev/null )
