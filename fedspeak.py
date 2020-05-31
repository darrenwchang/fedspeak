#######fedspeak
###darren chang

####SETUP
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

import os #setwd
import time #timing
import sys
sys.setrecursionlimit(100000)
import h5py #saving large files

# scraping
from bs4 import BeautifulSoup
from contextlib import closing
import requests #website requests
from requests.exceptions import RequestException
from requests import get

#nlp
import re
import nltk
from nltk.tokenize import sent_tokenize
from nltk.tokenize import word_tokenize
from nltk.corpus import stopwords

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

def scrape(links, #dataframe of urls and other informaiton
h5name #name of h5 file):
    """
    function for scraping set of links to dataframe
    """
    links_use = links['url'].values.tolist() #extract urls as list
    fed_text_raw = pd.DataFrame(columns = ['url', 'text']) #empty df

    # process usually takes 1.5 - 2.5 hrs. 
    # iterates across all the urls
    # grabs the text as a list and adds to larger dataframe
    for url in links_use:
        text = simple_get(url)
        df = pd.DataFrame({'url': url, 'text': [text]})
        fed_text_raw = fed_text_raw.append(df, ignore_index= True)
    fed_text_raw = pd.DataFrame(fed_text_raw)
    fed_text_raw.columns = fed_text_raw.columns.str.strip() #strip column names 
    
    # merging with original dataframe
    fed_text_all = pd.merge(links, fed_text_raw, how = 'outer', on = 'url')

    return fed_text_all

# store raw data as hdf -- too large for pickle oops
fed_text_all.to_hdf('fedtext.h5', key='fed_text_all', mode='w', format='table')


#### TESTING

def preprocess(text):
    clean_data = []
#    for x in (text[:][0]): #this is Df_pd for Df_np (text[:])
    for x in text:
        new_text = re.sub('<.*?>', '', x)   # remove HTML tags
        new_text = re.sub(r'[^\w\s]', '', new_text) # remove punc.
        new_text = re.sub(r'\d+','',new_text)# remove numbers
        new_text = new_text.lower() # lower case, .upper() for upper          
        if new_text != '':
            clean_data.append(new_text)
    return clean_data

def preprocess(df, 
 text_field, # field that has text
 new_text_field_name # name of field that has normalized text
 ):
    """
    normalizes text by converting it to lowercase and removing characters that do not contribute to natural text meaning
    """
    df[new_text_field_name] = df[text_field].str.lower()
    df[new_text_field_name] = df[new_text_field_name].apply(
        lambda elem: re.sub(r"(@[A-Za-z0-9]+)|([^0-9A-Za-z \t])|(\w+:\/\/\S+)|^rt|http.+?", "", elem)
        ) # strips out numbers
    # df[new_text_field_name] = df[new_text_field_name].apply(
    #     lambda elem: re.sub(r'<.*?>',"",elem) 
    #     ) # strips out tags
    df[new_text_field_name] = df[new_text_field_name].apply(
        lambda elem: re.sub(r"\d+", "", elem)
        )
    
    return df

def  preprocess(df, text_field, new_text_field_name):
    df[new_text_field_name] = df[text_field].str.lower()
    df[new_text_field_name] = df[new_text_field_name].apply(lambda elem: re.sub(r"(@[A-Za-z0-9]+)|([^0-9A-Za-z \t])|(\w+:\/\/\S+)|^rt|http.+?", "", elem))  
    # remove numbers
    df[new_text_field_name] = df[new_text_field_name].apply(lambda elem: re.sub(r"\d+", "", elem))
    
    return df

linklist = pd.DataFrame(links.loc[0:20,:])
urls = linklist['url'].values.tolist()

start = time.time()

fed_text_raw_test = pd.DataFrame()

# this works
for url in urls:
    text = simple_get(url)
    df = pd.DataFrame({'url': url, 'text': [text]})
    fed_text_raw_test = fed_text_raw_test.append(df, ignore_index = True)
# fed_text_raw = pd.concat(fed_text_raw)

fed_text_raw_test.columns = fed_text_raw_test.columns.str.strip()

fed_text_test = fed_text_raw_test.copy()

fed_text_test['text'] = fed_text_test['text'].apply(str)

preprocess(fed_text_test, 'text', 'text')

(fed_text_test['text']
    .apply(str)
    .apply(nltk.word_tokenize)
    .apply(pd.Series)
    .stack()
    .apply(preprocess)
    .reset_index(level=0)
    .set_index('level_0')
    .rename(columns={0: 'word'})
    .join(fed_text_test.drop('text', 1), how = 'left')
    .reset_index(drop = True)
    .merge(linklist, how = 'outer', on = 'url')
    )

# # reading hdf (for later use, so you don't have to keep scraping the MN Fed's website)
# fed_text_hdf = pd.read_hdf('fedtext.h5', 'fed_text_all')

#### CLEANING
start = time.time()
fed_text_token = fed_text_all.copy
fed_text_token['text'] = fed_text_token['text'].apply(lambda row: nltk.sent_tokenize(row['text']), axis=1)

fed_text_token['text'] = fed_text_all['text'].apply(nltk.word_tokenize)
fed_text_token.to_csv('fed_text_token.csv', index = False)

end = time.time()
print(end - start)

# not working
#  stop_sent = ['Back to Archive', 'serve the public', 'We examine economic issues',  'conduct world-class','We provide the banking community','We strive to advance policy']
#  fed_text_all[~fed_text_all['text'].str.contains('|'.join(stop_sent))]
# fed_text_raw