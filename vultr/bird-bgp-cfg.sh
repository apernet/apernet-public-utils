#!/bin/bash

usage() {
    me="$0"
    [ "$0" = "bash" ] && {
        # assume piped
        me="curl ... | bash -s --"
    }
    echo "usage: $me [-h] [-4 INET_PREFIXES] [-6 INET6_PREFIXES,...] BGP_PASSWORD"
    echo "where: INET_PREFIXES  := INET_PREFIX[,INET_PREFIXES]"
    echo "       INET6_PREFIXES := INET6_PREFIX[,INET6_PREFIXES]"
    echo "       BGP_PASSWORD   := (vultr BGP password)"
}

for req in jq curl sed tr; do {
    (! command -v "$req" &> /dev/null) && {
        echo '`'"$req' required but missing."
        exit 1
    }
}; done

OPTIND=1

while getopts "4:6:h" opt; do {
    case "$opt" in
        h) usage; exit 0;;
        4) prefixes4="$OPTARG";;
        6) prefixes6="$OPTARG";;
        *) usage; exit 1;;
    esac
}; done

shift $((OPTIND-1))

bgp_password="$1"

[ -z "$bgp_password" ] && {
    usage
    exit 1
}

metadata="`curl -s http://169.254.169.254/v1.json`"

my_inet="`<<< "$metadata" jq -cr '.bgp .ipv4 ."my-address"'`"
my_inet6="`<<< "$metadata" jq -cr '.bgp .ipv6 ."my-address"'`"
my_as="`<<< "$metadata" jq -cr '.bgp .ipv4 ."my-asn"'`"
neigh_inet="`<<< "$metadata" jq -cr '.bgp .ipv4 ."peer-address"'`"
neigh_inet6="`<<< "$metadata" jq -cr '.bgp .ipv6 ."peer-address"'`"
neigh_as="`<<< "$metadata" jq -cr '.bgp .ipv4 ."peer-asn"'`"

cat << BIRDCFG
router id $my_inet;

protocol device {
}

protocol static s4 {
    ipv4;
`[ ! -z "$prefixes4" ] && <<< "$prefixes4" tr , '\n' | sed 's/^/    route /; s/$/ blackhole;/'`
}

protocol static s6 {
    ipv6;
`[ ! -z "$prefixes6" ] && <<< "$prefixes6" tr , '\n' | sed 's/^/    route /; s/$/ blackhole;/'`
}

protocol bgp v4 {
    ipv4 {
        import none;
        export where proto = "s4";
    };

    multihop 2;
    password "$bgp_password";

    local $my_inet as $my_as;
    neighbor $neigh_inet as $neigh_as;
}

protocol bgp v6 {
    ipv6 {
        import none;
        export where proto = "s6";
    };

    multihop 2;
    password "$bgp_password";

    local $my_inet6 as $my_as;
    neighbor $neigh_inet6 as $neigh_as;
}
BIRDCFG
