import os
import json
import wget

if 'INPUT_JSON_URL' in os.environ:
    input_json = wget.download(os.environ['INPUT_JSON_URL'])
else:
    input_json = os.environ['INPUT_JSON']

for url in json.loads(input_json)['file_relationships']:
    wget.download(url)
