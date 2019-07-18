if [[ "${-}" =~ i ]]; then
    PS1='\u@\h:$( a=$(readlink -f .); echo ${a#$(git rev-parse --show-toplevel)/} | sed '\''s/[^/]*\//_/g;s/^\(_*\)/\1\//'\'' )\$ '
fi
