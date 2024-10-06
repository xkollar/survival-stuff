#!/usr/bin/env bash

time=${1?TIME}

targetseconds=$( date --date="${time}" +%s )

while true; do
    remains=$(( ${targetseconds} - $( date +%s ) ))
    
