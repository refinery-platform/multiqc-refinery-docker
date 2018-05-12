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
import urllib2

input_json = None

if 'INPUT_JSON' in os.environ:
    input_json = json.loads(os.environ["INPUT_JSON"])
elif 'INPUT_JSON_URL' in os.environ:
	response = urllib2.urlopen(os.environ["INPUT_JSON_URL"])
	input_json = json.loads(response.read())
else:
    raise Exception('Did not find expected environment variable')

for url in input_json['file_relationships']:
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