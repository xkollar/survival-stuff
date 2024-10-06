#!/usr/bin/env bash

set -eu

# Implemented sub-part of
# <https://github.com/zxing/zxing/wiki/Barcode-Contents#wi-fi-network-config-android-ios-11>
#
# * nopass
# * WPA-PSK

function escape() {
    echo -n "${1}" \
    | sed 's/\([\;,:"]\)/\\\1/g;s/^\([0-9A-Fa-f]*\)$/"\1"/'
}

function connenction_show() {
    local -r FIELDS=${1}; shift
    nmcli --mode tabular --terse --fields "${FIELDS}" connection show "${@}"
}

function connenction_show_secrets() {
    local -r FIELDS=${1}; shift
    nmcli --show-secrets --mode tabular --terse --fields "${FIELDS}" connection show "${@}"
}

function share_saved() {
    local UUID
    if [[ "${#}" -lt 1 ]]; then
        UUID=$( connenction_show TYPE,UUID --active | sed -n 's/^802-11-wireless://p' )
    else
        UUID=$( connenction_show connection.uuid "${1}" )
    fi
    readonly UUID

    if [[ -z "${UUID}" ]]; then
        echo "No such network. Here are some ideas:"
        connenction_show TYPE,NAME \
        | sed -n 's/^802-11-wireless://p'
        exit 1
    fi

    local CONNECT_STRING="WIFI:"

    local SSID
    SSID=$( connenction_show 802-11-wireless.ssid "${UUID}" )
    readonly SSID

    CONNECT_STRING+="S:$( escape "${SSID}" );"

    local PSK
    PSK=$( connenction_show_secrets 802-11-wireless-security.psk "${UUID}" )
    readonly PSK

    if [[ -n "${PSK}" ]]; then
        CONNECT_STRING+="T:WPA;"
        CONNECT_STRING+="P:$( escape "${PSK}" );"
    fi

    local HIDDEN
    HIDDEN=$( connenction_show 802-11-wireless.hidden "${UUID}" )
    readonly HIDDEN

    if [[ "${HIDDEN}" != "no" ]]; then
        CONNECT_STRING+="H:true;"
    fi

    CONNECT_STRING+=';'

    echo -n "${CONNECT_STRING}" | qr
    echo "${SSID}:${PSK}"
}

function main() {
    if [[ "${#}" -eq 2 ]]; then
        local SSID=${1}; shift
        local PSK=${1}; shift
        local CONNECT_STRING="WIFI:"
        CONNECT_STRING+="S:$( escape "${SSID}" );"
        CONNECT_STRING+="T:WPA;"
        CONNECT_STRING+="P:$( escape "${PSK}" );"
        CONNECT_STRING+=';'
        echo -n "${CONNECT_STRING}" | qr
    else
        share_saved "${@}"
    fi
}

main "${@}"
