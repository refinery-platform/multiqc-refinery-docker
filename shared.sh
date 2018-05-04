#!/usr/bin/env bash

OWNER=mccalluc # TODO: gehlenborglab
export IMAGE=qualimap_multiqc_refinery
export REPO=$OWNER/$IMAGE
export CONTAINER_NAME=$IMAGE-container

export PORT=8888

die() { set +v; echo "$*" 1>&2 ; exit 1; }