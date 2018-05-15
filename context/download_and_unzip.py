import os
import json
import wget
import zipfile

def unzip_all_in_dir(top):
    '''
    >>> fixtures = os.path.dirname(os.path.realpath(__file__)) + '/../fixtures'
    >>> d = fixtures + '/d'
    >>> assert os.listdir(d) == ['c.zip']
    >>> unzip_all_in_dir(fixtures + '/d')
    >>> os.listdir(d)
    
    '''
    # Note that zip files with absolute paths could clobber other directories:
    # https://docs.python.org/3/library/zipfile.html#zipfile.ZipFile.extractall
    for root, dirs, files in os.walk(top):
        for dir in dirs:
            abs_dir = os.path.join(top, dir)
            unzip_all_in_dir(abs_dir)
        for file in files:
            abs_file = os.path.join(top, file)
            if zipfile.is_zipfile(abs_file):
                new_dir = abs_file + '.unzipped'
                os.mkdir(new_dir)
                with zipfile.ZipFile(abs_file) as z:
                    z.extractall(new_dir)  # Extract *to* new_dir
                    unzip_all_in_dir(new_dir)

if __name__ == '__main__':
    if 'INPUT_JSON_URL' in os.environ:
        input_json = wget.download(os.environ['INPUT_JSON_URL'])
    else:
        input_json = os.environ['INPUT_JSON']

    for url in json.loads(input_json)['file_relationships']:
        wget.download(url)

    unzip_all_in_dir(os.getcwd())
