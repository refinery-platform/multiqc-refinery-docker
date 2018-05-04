#!/usr/bin/env bash
set -o errexit

# xtrace turned on only within the travis folds
start() { echo travis_fold':'start:$1; echo $1; set -v; }
end() { set +v; echo travis_fold':'end:$1; echo; echo; }
cleanup() { docker stop $CONTAINER_NAME; docker rm $CONTAINER_NAME; }

test() {
    FIXTURE=$1
    shift
    echo "Run with $FIXTURE"
    ./run.sh $FIXTURE
    OUTPUT=/tmp/multiqc.html
    curl http://localhost:$PORT/ > $OUTPUT
    while (( "$#" )); do
        PATTERN=$1
        shift
        echo "Looking for '$PATTERN'..."
        grep --only-matching "$PATTERN" "$OUTPUT" \
            || die "Didn't find '$PATTERN' in '$OUTPUT'"
    done
    echo 'Cleaning up...'
    cleanup
}

source shared.sh


start build
./build.sh
end build

start test_good
test fixtures/good-input.json 'General Stats' 'Bowtie 2' 'FastQC'
end test_good

start test_empty
test fixtures/empty-input.json 'MultiQC did not run'
end test_empty