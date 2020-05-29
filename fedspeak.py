import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

import os #setwd
import time #timing
import sys
sys.setrecursionlimit(100000)
import h5py #saving large files

import nltk
from nltk.tokenize import sent_tokenize
from nltk.tokenize import word_tokenize
from nltk.corpus import stopwords

# scraping
from bs4 import BeautifulSoup
from contextlib import closing
import requests #website requests
from requests.exceptions import RequestException
from requests import get

# importing links, which were created using excel
os.chdir('C:\\Users\\darre\\Documents\\_econ\\fedspeak')
links = pd.read_csv('links.csv')
links.head(10)

####SCRAPING
# functions for scraping, with error logging
def simple_get(url):
    """
    Attempts to get the content at `url` by making an HTTP GET request.
    If the content-type of response is some kind of HTML/XML, return the
    text content, otherwise return None.
    """
    try:
        with closing(get(url, stream = True)) as resp:
            if is_good_response(resp):
                soup = BeautifulSoup(resp.content, 'html.parser')
                results = soup.find_all('p')
                return results
            else:
                return None
    except RequestException as e:
        log_error('Error during requests to {0} : {1}'.format(url, str(e)))
        return None

def is_good_response(resp):
    """
    Returns True if the response seems to be HTML, False otherwise.
    """
    content_type = resp.headers['Content-Type'].lower()
    return (resp.status_code == 200 
            and content_type is not None 
            and content_type.find('html') > -1)

def log_error(e):
    """
    log errors
    """
    print(e)

links_use = links['url'] #extract urls from links
links_use = links_use.values.tolist() #coerce to list

fed_text_raw = pd.DataFrame(columns = ['url', 'text']) #empty df

# process usually takes 1.5 - 2.5 hrs. iterates across all the urls, grabs the text as a list and adds to larger dataframe
for url in links_use:
    text = simple_get(url)
    df = pd.DataFrame({'url': url, 'text': [text]})
    fed_text_raw = fed_text_raw.append(df, ignore_index= True)

# merging with original dataframe
fed_text_all = pd.merge(links, fed_text_raw, how = 'outer', on = 'url')

# store raw data as hdf -- too large for pickle oops
fed_text_all.to_hdf('fedtext.h5', key='fed_text_all', mode='w', format='table')

pd.set_option('expand_frame_repr', False)
fed_text_all['text'].head(20)

# # reading hdf (for later use, so you don't have to keep scraping the MN Fed's website)
# fed_text_hdf = pd.read_hdf('fedtext.h5', 'fed_text_all')

#### CLEANING
start = time.time()
fed_text_token = fed_text_all.copy
fed_text_token['text'] = fed_text_token['text'].apply(lambda row: nltk.sent_tokenize(row['text']), axis=1)

fed_text_token['text'] = fed_text_all['text'].apply(nltk.word_tokenize)
fed_text_token.to_csv('fed_text_token.csv', index = False)
fed_text_token.to_pickle('fed_text_token.pkl')

end = time.time()
print(end - start)

# testing
#this all works

# urls = links.loc[0:50,:]
# urls = urls['url']
# urls = urls.values.tolist()

# start = time.time()
# fed_text_raw = pd.DataFrame(columns = ['url', 'text'])

# for url in urls:
#     text = simple_get(url)
#     df = pd.DataFrame({'url': url, 'text': [text]})
#     fed_text_raw = fed_text_raw.append(df, ignore_index= True)

# end = time.time()
# print(end - start)

# fed_text_all = pd.merge(urls, fed_text_raw, how = 'outer', on = 'url')

# not working
#  stop_sent = ['Back to Archive', 'serve the public', 'We examine economic issues',  'conduct world-class','We provide the banking community','We strive to advance policy']
#  fed_text_all[~fed_text_all['text'].str.contains('|'.join(stop_sent))]
# fed_text_raw