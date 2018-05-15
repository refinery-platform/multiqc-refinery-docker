#!/usr/bin/env bash
set -o errexit

source shared.sh

if [ "$#" -ne 1 ]; then
    die 'Expects a single argument, path of input.json'
fi

docker run --env INPUT_JSON="$(cat $1)" \
           --name $CONTAINER_NAME \
           --detach \
           --publish $PORT:80 \
           $IMAGE
retry

echo "Visit http://localhost:$PORT/"
