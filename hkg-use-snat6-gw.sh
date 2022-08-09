#!/bin/bash

[ "$EUID" -ne 0 ] && {
    echo "needs root." >&2
    exit 1
}

(ip -6 addr | grep -q 2406:4440::) && gw=2406:4440::6359
(ip -6 addr | grep -q 2406:4440:0:101:) && gw=2406:4440:0:101::6359
(ip -6 addr | grep -q 2406:4440:0:102:) && gw=2406:4440:0:102::6359
(ip -6 addr | grep -q 2406:4440:0:103:) && gw=2406:4440:0:103::6359
(ip -6 addr | grep -q 2406:4440:0:104:) && gw=2406:4440:0:104::6359
(ip -6 addr | grep -q 2406:4440:0:105:) && gw=2406:4440:0:105::6359
(ip -6 addr | grep -q 2406:4440:0:106:) && gw=2406:4440:0:106::6359
(ip -6 addr | grep -q 2406:4440:0:107:) && gw=2406:4440:0:107::6359

[ -z "$gw" ] && {
    echo "??? IPv6 disabled / not on apernet-hkg." >&2
    exit 1
}

ip -6 route change default via $gw onlink       # in case the user is using static gw
ip -6 route add default via $gw metric 1 onlink # in case the user is using slaac
