if [[ "${-}" =~ i ]]; then
    PS1='\D{%H:%M:%S %Z}${WINDOW:+" {${WINDOW}}"} \u@\[\033[31m\]\h\[\033[m\]:\[\033[36m\]$( a=$(readlink -f .); echo ${a#$(git rev-parse --show-toplevel)} | sed '\''s/\([^/]\)[^/]*\//\1_\//g;s/^$/\//'\'' )\[\033[m\]\n\$ '
fi
