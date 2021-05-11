#!/usr/bin/env bash

exec awk -f <( tail -n+5 "${0}" )

NR==1{
    MIN=MAX=$1
}
{
    SUM+=$1;
    COUNT+=1;
    if ($1>MAX) MAX=$1;
    if ($1<MIN) MIN=$1;
}
END{
    print MIN, SUM/COUNT, MAX
}
