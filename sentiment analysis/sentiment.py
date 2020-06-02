####### sentiment analysis
### darren chang

#### SETUP
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

import os #setwd
import time #timing

import re
import sys
sys.path.append('C:\\Users\\darre\\Documents\\_econ\\fedspeak\\sentiment analysis')  # Modify to identify path for custom modules
import Load_MasterDictionary as LM

os.chdir('C:\\Users\\darre\\Documents\\_econ\\fedspeak\\sentiment analysis')
fed_text_all = pd.read_csv('C:\\Users\\darre\\Documents\\_econ\\fedspeak\\text mining\\fed_text_all.csv') # read csv
fed_text_all.head(10)

# User defined file pointer to LM dictionary
master_dictionary = r'C:\\Users\\darre\\Documents\\_econ\\fedspeak\\sentiment analysis\\LoughranMcDonald_MasterDictionary_2018.csv'

lm_dictionary = LM.load_masterdictionary(master_dictionary, True)

lm_dict = (pd.read_csv('loughran_mcdonald.csv', header = 0)
                .fillna('')
                .apply(lambda x: x.astype(str))
                .apply(lambda x: x.str.lower())
                # .to_dict()
                )

positive = lm_dict['positive'].tolist()
positive = list(filter(None, positive))

negative = lm_dict['negative'].tolist()
negative = list(filter(None, negative))

uncertainty = lm_dict['uncertainty'].tolist()
uncertainty = list(filter(None, uncertainty))

weak_modal = lm_dict['weak_modal'].tolist()
weak_modal = list(filter(None, weak_modal))

strong_modal = lm_dict['strong_modal'].tolist()
strong_modal = list(filter(None, strong_modal))

constraining = lm_dict['constraining'].tolist()
constraining = list(filter(None, constraining))

dict(positive)

zipwords = dict(positive, negative, uncertainty, weak_modal, strong_modal, constraining)

lm_dict = dict(zipwords)

def sentiment_loughran(
    df, # dataframe of words
    parse_column, # column of words that you want to parse
    result_column, # column where you want to output results to
    dict, # dictionary that you want to use
):
    df[parse_column].apply(lambda x: x in dict['positive'])

    # if (df[parse_column].isin(dict['positive'])):
    #     (df.assign(result_column = 'positive'))
    # elif (df[parse_column].isin(dict['negative'])):
    #     (df.assign(result_column = 'negative'))
    # elif (df[parse_column].isin(dict['uncertainty'])):
    #     (df.assign(result_column = 'uncertainty'))
    # elif (df[parse_column].isin(dict['litigious'])):
    #     (df.assign(result_column = 'litigious'))
    # elif (df[parse_column].isin(dict['weak_modal'])):
    #     (df.assign(result_column = 'weak modal'))
    # elif (df[parse_column].isin(dict['strong_modal'])):
    #     (df.assign(result_column = 'strong modal'))
    # elif (df[parse_column].isin(dict['constraining'])):
    #     (df.assign(result_column = 'constraining'))

    return df
    
df["B"] = df["A"].map(equiv)
fed_text_test['sentiment'] = fed_text_test['word'].map()
# test
df.loc[df['column name'] condition, 'new column name'] = 'value if condition is met'

df['new column name'] = df['column name'].apply(lambda x: 'value if condition is met' if x condition else 'value if condition is not met')

fed_text_test['word'].apply(lambda x: 'positive' if x in lm_dict['positive'])

fed_text_test = fed_text_all.loc[0:20, :]
sentiment_loughran(fed_text_test, 'word', 'sentiment', lm_dict)