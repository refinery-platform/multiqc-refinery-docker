#!/usr/bin/env bash
set -o errexit
set -o xtrace

cd $1
echo "PWD=$PWD"
PORT=$2
echo "PORT=$PORT"

python - <<EOF
import os
import json
import wget

if 'INPUT_JSON_URL' in os.environ:
    input_json = wget.download(os.environ['INPUT_JSON_URL'])
else:
    input_json = os.environ['INPUT_JSON']

for url in json.loads(input_json)['file_relationships']:
    wget.download(url)
EOF

multiqc .
mv multiqc_report.html index.html || \
cat <<EOF > index.html
<html><body>
Sorry: MultiQC did not run. Check the logs for more information.
</body></html>
EOF
python -m SimpleHTTPServer $PORT
