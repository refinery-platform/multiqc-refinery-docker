#!/usr/bin/env bash
set -o errexit

source shared.sh

# TODO: docker pull $REPO
# TODO: --cache-from $REPO
docker build \
     --tag $IMAGE \
     context