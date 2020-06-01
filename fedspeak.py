####### fedspeak
### darren chang

#### SETUP
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

# nlp
import re
import nltk
from nltk.tokenize import sent_tokenize
from nltk.tokenize import word_tokenize
from nltk.stem.snowball import SnowballStemmer
from nltk.stem import WordNetLemmatizer
from nltk.corpus import stopwords

# importing links, which were created using excel
os.chdir('C:\\Users\\darre\\Documents\\_econ\\fedspeak')
links = pd.read_csv('links.csv')
links.head(10)

#### SCRAPING
# functions for getting URLs, with error logging
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

# scraping a set of links
def scrape(links, #dataframe of urls and other info
):
    """
    function for scraping set of links to dataframe. returns data frame of raw text in lists of lists
    """
    links_use = links['url'].values.tolist() #extract urls as list
    fed_text_raw = pd.DataFrame() #empty df

    # this process usually takes 1.5 - 2.5 hrs. 
    # iterates across all the urls
    # grabs the text as a list and adds to larger dataframe
    for url in links_use:
        text = simple_get(url)
        df = pd.DataFrame({'url': url, 'text': [text]})
        fed_text_raw = fed_text_raw.append(df, ignore_index= True)
    fed_text_raw = pd.DataFrame(fed_text_raw)
    fed_text_raw.columns = fed_text_raw.columns.str.strip() #strip column names 

    return fed_text_raw

start = time.time()

fed_text_raw = scrape(links)
# linklist = pd.DataFrame(links.loc[0:20,:]) # for testing
# fed_text_raw = scrape(linklist) # test run

end = time.time() # log time for this process
print(end - start)

#### CLEANING

# stripping html tags and numbers
# this function for preprocessing can be finnicky - because of string types and series interactions
def preprocess(df, 
 text_field, # field that has text
 new_text_field_name # name of field that has normalized text
 ):
    """
    normalizes dataframes by converting it to lowercase and 
    removing characters that do not contribute to natural text meaning
    """
    # df[new_text_field_name] = df[text_field].str.lower()
    df[new_text_field_name] = (df[text_field]
        .apply(lambda elem: re.sub(r"(@[A-Za-z0-9]+)|([^0-9A-Za-z \t])|(\w+:\/\/\S+)|^rt|http.+?", 
            "", str(elem)))
        .apply(lambda elem: re.sub("<.*?>","", str(elem))) # strips out tags
        .apply(lambda elem: re.sub(r"\d+", "", str(elem)))
        )
    
    return df

# word tokenization
def unnest(df, # line-based dataframe
                  column_to_tokenize, # name of the column with the text
                  new_token_column_name, # what you want the column of words to be called
                  tokenizer_function, # what tokenizer to use = (nltk.word_tokenize)
                  original_list): # original list of data
    """
    unnests words from html and returns dataframe in long format merged with original list.
    word tokenization in tidy text format.
    """

    return (df[column_to_tokenize]
                .apply(str)
                .apply(tokenizer_function)
                .apply(pd.Series)
                .stack()
                .reset_index(level=0)
                .set_index('level_0')
                .rename(columns={0: new_token_column_name})
                .join(df.drop(column_to_tokenize, 1), how='left')
                .reset_index(drop=True)
                .merge(original_list, how = 'outer', on = 'url')
              )

fed_text_raw = preprocess(fed_text_raw, 'text', 'text')
fed_text_all = unnest(fed_text_raw, 'text', 'word', nltk.word_tokenize, links)
fed_text_all['word'] = fed_text_all['word'].str.lower() # convert to lowercase
fed_text_all.to_csv('fed_text_all.csv', index = False) # save as csv
# fed_text_all = pd.read_csv('fex_test_all.csv') # read csv

# stemming, if you decide to stem.
# snowball = SnowballStemmer(language = 'english')
# def stemming(df,
#             column_to_stem,
#             stem_function, # what stemming function to use = snowball
#             ):
#     """
#     returns stem of words in a dataframe
#     """
    
#     return (df[column_to_stem]
#                 .apply(stem_function)
#                 )
#
# stemming(fed_text_all, 'word', snowball.stem)

# lemmatization
wordnet_lemmatizer = WordNetLemmatizer()
def lemmatize(df,
            column_to_lemmatize,
            lemmatize_func, # lemmatizing function to use = wordnet
            ):
    """
    returns root words by matching with the lemmatizing function
    """
    
    return (df[column_to_lemmatize]
                .apply(lambda word: lemmatize_func.lemmatize(word, pos = "v"))
                )

# fed_text_test['word'] = lemmatize(fed_text_test, 'word', word_net_lemmatizer) # test code
fed_text_all['word'] = lemmatize(fed_text_all, 'word', wordnet_lemmatizer) # lemmatize

# stopwords
# make custom stop words list
stop_words = stopwords.words("english")
stop_words_html = ['ppwe', 'uspp', 'pwe', 'usp', 'pp', 'usbrp'] # leftover stopwords from converting html to text with 'p' tags
stop_words_econ = ['debt', 'gross', 'crude', 'well', 'maturity', 'work', 'marginally', 'leverage'] # stop words for economic usage

stop_words.extend(stop_words_html)
stop_words.extend(stop_words_econ)

# delete stopwords
def remove_stops(df,
                column_to_process,
                stop_words_list, # list of stop words = stop_words
                index_reset = True # whether you want to reset index or not
                ):
    """
    function remove stopwords if data is a pandas dataframe and in tidy format e.g. long.
    different from typical pandas format which is lists of words in wide format.
    """
    if index_reset == True:
        return (df[~df[column_to_process].isin(stop_words_list)]
                .reset_index(drop = True)) # this line resets index
    else:
        return df[~df[column_to_process].isin(stop_words_list)]

# remove_stops(fed_text_test, 'word', stop_words) # test code

fed_text_all = remove_stops(fed_text_all, 'word', stop_words)
fed_text_all.to_csv('fed_text_all.csv', index = False) # save as csv

### testing
# fed_text_test = fed_text_all.loc[0:20,:]

end = time.time()
print(end - start)