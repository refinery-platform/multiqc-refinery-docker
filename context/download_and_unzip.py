import os
import json
import wget
import zipfile

def unzip_all_in_dir(parent_dir):
    # Zip files with absolute paths could clobber other directories:
    # https://docs.python.org/3/library/zipfile.html#zipfile.ZipFile.extractall
    for path in (os.path.join(parent_dir, f) for f in os.listdir(parent_dir)):
        print('{} is zip?'.format(path))
        if zipfile.is_zipfile(path):
            child_dir = path + '.unzipped'
            os.mkdir(child_dir)
            print('{} -> {}'.format(path, child_dir))
            with zipfile.ZipFile(path) as z:
                z.extractall(child_dir)  # Extract *to* child_dir
                unzip_all_in_dir(child_dir)

if __name__ == '__main__':
    if 'INPUT_JSON_URL' in os.environ:
        input_json = wget.download(os.environ['INPUT_JSON_URL'])
    else:
        input_json = os.environ['INPUT_JSON']

    for url in json.loads(input_json)['file_relationships']:
        wget.download(url)

    unzip_all_in_dir(os.getcwd())
