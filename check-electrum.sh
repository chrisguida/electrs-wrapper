#!/bin/bash

DURATION=$(</dev/stdin)
if (($DURATION <= 5000 )); then
    exit 60
else
    curl --silent --fail electrs.embassy:50001 &>/dev/null
    RES=$?
    if test "$RES" != 0; then
        echo "Electrum interface is unreachable" >&2
        exit 1
    fi
fi
