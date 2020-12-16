#!/usr/bin/env bash

set -eu

readonly NOTEDIR="${HOME}/notes"

what=$( { echo new; ls "${NOTEDIR}"; } | fzf +s --query="${1:-}" )

if [[ "${what}" == 'new' ]]; then
    read -rp 'Description: ' -ei 'note' description
    description=$( echo "${description}" | tr 'A-Z' 'a-z' | sed 's/[^a-z0-9]/_/g')
    file="$( date -u +%F )${description:+-}${description}.md"
else
    file="${what}"
fi

readonly file
unset what description

"${EDITOR:-vim}" "${NOTEDIR}/${file}"
( cd "${NOTEDIR}"
    git add .
    git commit -av
)
