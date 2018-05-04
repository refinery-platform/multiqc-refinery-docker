#!/usr/bin/env bash
set -o errexit

# xtrace turned on only within the travis folds
start() { echo travis_fold':'start:$1; echo $1; set -v; }
end() { set +v; echo travis_fold':'end:$1; echo; echo; }
cleanup() { docker stop $CONTAINER_NAME; docker rm $CONTAINER_NAME; }

source shared.sh


start docker_build
./build.sh
end docker_build


OUTPUT=/tmp/multiqc.html


start test_good
./run.sh fixtures/good-input.json
curl http://localhost:$PORT/ > $OUTPUT
for TOOL in 'General Stats' 'Bowtie 2' 'FastQC'; do
    echo "Looking for '$TOOL'..."
    grep --only-matching "$TOOL" "$OUTPUT" \
    || die "Didn't find '$TOOL' in '$OUTPUT'"
done
cleanup
end test_good


start test_empty
./run.sh fixtures/empty-input.json
curl http://localhost:$PORT/ > $OUTPUT
for TOOL in 'MultiQC did not run'; do
    echo "Looking for '$TOOL'..."
    grep --only-matching "$TOOL" "$OUTPUT" \
    || die "Didn't find '$TOOL' in '$OUTPUT'"
done
cleanup
end test_empty