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
# User defined output file
OUTPUT_FILE = r'D:/Temp/Parser.csv'
# Setup output
OUTPUT_FIELDS = ['file name,', 'file size,', 'number of words,', '% positive,', '% negative,',
                 '% uncertainty,', '% litigious,', '% modal-weak,', '% modal moderate,',
                 '% modal strong,', '% constraining,', '# of alphabetic,', '# of digits,',
                 '# of numbers,', 'avg # of syllables per word,', 'average word length,', 'vocabulary']

lm_dictionary = LM.load_masterdictionary(master_dictionary, True)

# lm_dictionary_pd = pd.DataFrame(lm_dictionary, index = )

# def sentiment_loughran(
#     df, # dataframe of words
#     parse_column, # column of words that you want to parse
#     result_column, # column where you want to output results to 
# ):

#     if lm_dictionary

# def get_data(doc):

#     vdictionary = {}
#     _odata = [0] * 17
#     total_syllables = 0
#     word_length = 0
    
#     tokens = re.findall('\w+', doc)  # Note that \w+ splits hyphenated words
#     for token in tokens:
#         if not token.isdigit() and len(token) > 1 and token in lm_dictionary:
#             _odata[2] += 1  # word count
#             word_length += len(token)
#             if token not in vdictionary:
#                 vdictionary[token] = 1
#             if lm_dictionary[token].positive: _odata[3] += 1
#             if lm_dictionary[token].negative: _odata[4] += 1
#             if lm_dictionary[token].uncertainty: _odata[5] += 1
#             if lm_dictionary[token].litigious: _odata[6] += 1
#             if lm_dictionary[token].weak_modal: _odata[7] += 1
#             if lm_dictionary[token].moderate_modal: _odata[8] += 1
#             if lm_dictionary[token].strong_modal: _odata[9] += 1
#             if lm_dictionary[token].constraining: _odata[10] += 1
#             total_syllables += lm_dictionary[token].syllables
