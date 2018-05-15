#!/usr/bin/env bash
set -o errexit

# xtrace turned on only within the travis folds
start() { echo travis_fold':'start:$1; echo $1; set -v; }
end() { set +v; echo travis_fold':'end:$1; echo; echo; }
cleanup() { docker stop $CONTAINER_NAME; docker rm $CONTAINER_NAME; }

test_path() {
    # Don't call it 'PATH'! That means something special.
    FIXTURE="$1"
    shift
    echo "Run with path $FIXTURE"
    ./run_path.sh $FIXTURE
    assert_grep "$@"
}

test_url() {
    URL="$1"
    shift
    echo "Run with url $URL"
    ./run_url.sh $URL
    assert_grep "$@"
}

assert_grep() {
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

start doctest
python -m doctest -v context/download_and_unzip.py
end doctest

start build
./build.sh
end build

start test_good_path
test_path fixtures/good-input.json 'General Stats' 'Bowtie 2' 'FastQC'
end test_good_path

start test_empty_path
test_path fixtures/empty-input.json 'MultiQC did not run'
end test_empty_path

start test_mixed_path
test_path fixtures/mixed-input.json 'General Stats' 'Bowtie 2'
# TODO: Add explicit error if some of the inputs were not processed?
# They might be bad URLs, or they might be be unrecognized filetypes.
end test_mixed_path

# Don't think everything needs to be repeated with URLs, but make one check:
start test_good_url
test_url https://raw.githubusercontent.com/refinery-platform/qualimap-multiqc-refinery-docker/v0.0.6/fixtures/good-input.json \
     'General Stats' 'Bowtie 2' 'FastQC'
end test_good_url