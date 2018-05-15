#!/usr/bin/env bash
set -o errexit
set -o xtrace

export PATH=$PATH:$(pwd)

DATA_DIR=$1
cd $DATA_DIR
echo "DATA_DIR=$DATA_DIR"

PORT=$2
echo "PORT=$PORT"

download_and_unzip.py
multiqc .
mv multiqc_report.html index.html || \
cat <<EOF > index.html
<html><body>
Sorry: MultiQC did not run. Check the logs for more information.
</body></html>
EOF
python -m SimpleHTTPServer $PORT
