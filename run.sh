#!/usr/bin/env bash
set -o errexit

source shared.sh

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

if [ "$#" -ne 1 ]; then
    die 'Expects a single argument, input.json'
fi

docker run --env INPUT_JSON="$(cat $1)" \
           --name $CONTAINER_NAME \
           --detach \
           --publish $PORT:80 \
           $IMAGE
retry

echo "Visit http://localhost:$PORT/"
