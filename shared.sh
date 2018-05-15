#!/usr/bin/env bash

OWNER=mccalluc # TODO: gehlenborglab
export IMAGE=qualimap_multiqc_refinery
export REPO=$OWNER/$IMAGE
export CONTAINER_NAME=$IMAGE-container

export PORT=8888

die() { set +v; echo "$*" 1>&2 ; exit 1; }

retry() {
    TRIES=1
    until curl --silent --fail http://localhost:$PORT/ > /tmp/response.txt; do
        echo "$TRIES: not up yet"
        if (( $TRIES > 10 )); then
            docker logs $CONTAINER_NAME
            die "HTTP requests to app never succeeded"
        fi
        (( TRIES++ ))
        sleep 1
    done
    echo 'Container responded with:'
    head -n15 /tmp/response.txt
}