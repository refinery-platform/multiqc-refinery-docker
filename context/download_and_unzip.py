#!/usr/bin/env python
import os
import json
import urllib2
import wget
import zipfile

def unzip_all_in_dir(top):
    '''
    >>> fixtures = os.path.dirname(os.path.realpath(__file__)) + '/../fixtures'
    >>> d = fixtures + '/d'
    >>> os.listdir(d)
    ['c.zip']
    >>> unzip_all_in_dir(d)
    >>> os.listdir(d)
    ['c.zip', 'c.zip.unzipped']
    >>> os.listdir(d + '/c.zip.unzipped/c/b.zip.unzipped/b/a.zip.unzipped/a/')
    ['abc.txt']
    >>> import shutil
    >>> shutil.rmtree(d + '/c.zip.unzipped')
    >>> os.listdir(d)
    ['c.zip']
    '''
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
        input_json = urllib2.urlopen(os.environ['INPUT_JSON_URL']).read()
    else:
        input_json = os.environ['INPUT_JSON']

    for url in json.loads(input_json)['file_relationships']:
        wget.download(url)

    unzip_all_in_dir(os.getcwd())
