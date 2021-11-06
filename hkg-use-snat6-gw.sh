#!/bin/bash

[ "$EUID" -ne 0 ] && {
    echo "need root." >&2
    exit 1
}

(ip -6 addr | grep -q 2406:4440::) && gw=2406:4440::6359
(ip -6 addr | grep -q 2406:4440:0:101:) && gw=2406:4440:0:101::6359
(ip -6 addr | grep -q 2406:4440:0:102:) && gw=2406:4440:0:102::6359
(ip -6 addr | grep -q 2406:4440:0:103:) && gw=2406:4440:0:103::6359

[ -z "$gw" ] && {
    echo "??? IPv6 disabled / not on apernet-hkg." >&2
    exit 1
}

ip -6 route add default via $gw metric 1
