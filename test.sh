#!/usr/bin/env bash
set -o errexit

# xtrace turned on only within the travis folds
start() { echo travis_fold':'start:$1; echo $1; set -v; }
end() { set +v; echo travis_fold':'end:$1; echo; echo; }

source shared.sh


start docker_build
./build.sh
end docker_build


start docker_start
./run.sh fixtures/fake-input.json
end docker_start


start test
ACTUAL_FILE=/tmp/multiqc.html
curl http://localhost:$PORT/ > $ACTUAL_FILE
for TOOL in 'General Stats' 'Bowtie 2' 'FastQC'; do
    echo "Looking for '$TOOL'..."
    grep --only-matching "$TOOL" "$ACTUAL_FILE" \
    || die "Didn't find '$TOOL' in '$ACTUAL_FILE'"
done
docker stop $CONTAINER_NAME
docker rm $CONTAINER_NAME
echo "container cleaned up"
end test