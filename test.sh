#!/usr/bin/env bash
set -o errexit
set -o xtrace

# xtrace turned on only within the travis folds
start() { echo travis_fold':'start:$1; echo $1; set -v; }
end() { set +v; echo travis_fold':'end:$1; echo; echo; }
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
source define_repo.sh


start docker_build
# TODO: docker pull $REPO
# TODO: --cache-from $REPO
docker build \
     --tag $IMAGE \
     context
end docker_build


start docker_run
JSON=`cat fixtures/fake-input.json`
docker run --env INPUT_JSON="$JSON" \
           --name $CONTAINER_NAME \
           --detach \
           --publish 8888:80 \
           $IMAGE
retry
echo "docker is responsive"
ACTUAL_FILE='/tmp/actual-index.html'
curl http://localhost:8888/ > $ACTUAL_FILE
for TOOL in 'General Stats' 'Bowtie 2' 'FastQC'; do
    echo "Looking for '$TOOL'..."
    grep --only-matching "$TOOL" "$ACTUAL_FILE" \
    || die "Didn't find '$TOOL' in '$ACTUAL_FILE'"
done
docker stop $CONTAINER_NAME
docker rm $CONTAINER_NAME
echo "container cleaned up"
end docker_run