#!/usr/bin/env bash

CMD="$@"
[[ -z $CMD ]] && echo "usage: EXPIRY=600 cache cmd arg1 ... argN" && exit 1

gnudate() {
    if hash gdate 2>/dev/null; then
        gdate "$@"
    else
        date "$@"
    fi
}


gnumd5sum() {
    if hash gdate 2>/dev/null; then
        gmd5sum "$@"
    else
        md5sum "$@"
    fi
}

# set -e -x

VERBOSE=false
PROG="$(basename $0)"

EXPIRY=${EXPIRY:-600}  # default to 10 minutes, can be overriden
EXPIRE_DATE=$(gnudate -Is -d "-$EXPIRY seconds")

[[ $VERBOSE = true ]] && echo "Using expiration $EXPIRY seconds"

HASH=$(echo "$CMD" | gnumd5sum | awk '{print $1}')
CACHEDIR="${HOME}/.cache/${PROG}"
mkdir -p "${CACHEDIR}"
CACHEFILE="$CACHEDIR/$HASH"

if [[ -e $CACHEFILE ]] && [[ $(gnudate -Is -r "$CACHEFILE") > $EXPIRE_DATE ]]; then
    cat "$CACHEFILE"
    #echo "Ho $CACHEFILE"
else
    script -F -q /dev/null "$CMD" | tee "$CACHEFILE"
fi