import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import requests #website requests
from requests.exceptions import RequestException
from requests import get
import os #setwd
import time #timing

import nltk
from nltk.tokenize import sent_tokenize
from nltk.tokenize import word_tokenize
from nltk.corpus import stopwords

# scraping
from bs4 import BeautifulSoup
from contextlib import closing

os.chdir('C:\\Users\\darre\\Documents\\_econ\\fedspeak')
links = pd.read_csv('links.csv')
links.head(10)

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

links_use = links['url']
links_use = links_use.values.tolist()

start = time.time()
fed_text_raw = pd.DataFrame(columns = ['url', 'text'])

for url in links_use:
    text = simple_get(url)
    df = pd.DataFrame({'url': url, 'text': [text]})
    fed_text_raw = fed_text_raw.append(df, ignore_index= True)

fed_text_all = pd.merge(links, fed_text_raw, how = 'outer', on = 'url')

fed_text_all.to_csv('fed_text_all.csv', index = False)

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
# stop_sent = ['Back to Archive', 'serve the public', 'We examine economic issues',  'conduct world-class','We provide the banking community','We strive to advance policy']
# fed_text_all[~fed_text_all['text'].str.contains('|'.join(stop_sent))]
# fed_text_raw