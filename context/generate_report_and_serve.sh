#!/usr/bin/env bash

cd $1
echo "PWD=$PWD"
PORT=$2
echo "PORT=$PORT"

python - <<EOF
import os
import json
import wget

input_json = json.loads(os.environ['INPUT_JSON'])
for url in input_json['file_relationships']:
    wget.download(url)
EOF

multiqc .
mv multiqc_report.html index.html
python -m SimpleHTTPServer $PORT
