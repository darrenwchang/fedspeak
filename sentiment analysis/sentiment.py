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

# dict(positive)

# zipwords = dict(positive, negative, uncertainty, weak_modal, strong_modal, constraining)

# lm_dict = dict(zipwords)

# def sentiment_loughran(
#     df, # dataframe of words
#     parse_column, # column of words that you want to parse
#     result_column, # column where you want to output results to
#     dict, # dictionary that you want to use
# ):
#     df[parse_column].apply(lambda x: x in dict['positive'])

#     # if (df[parse_column].isin(dict['positive'])):
#     #     (df.assign(result_column = 'positive'))
#     # elif (df[parse_column].isin(dict['negative'])):
#     #     (df.assign(result_column = 'negative'))
#     # elif (df[parse_column].isin(dict['uncertainty'])):
#     #     (df.assign(result_column = 'uncertainty'))
#     # elif (df[parse_column].isin(dict['litigious'])):
#     #     (df.assign(result_column = 'litigious'))
#     # elif (df[parse_column].isin(dict['weak_modal'])):
#     #     (df.assign(result_column = 'weak modal'))
#     # elif (df[parse_column].isin(dict['strong_modal'])):
#     #     (df.assign(result_column = 'strong modal'))
#     # elif (df[parse_column].isin(dict['constraining'])):
#     #     (df.assign(result_column = 'constraining'))

#     return df
    


# """
# Program to provide generic parsing for all files in user-specified directory.
# The program assumes the input files have been scrubbed,
#   i.e., HTML, ASCII-encoded binary, and any other embedded document structures that are not
#   intended to be analyzed have been deleted from the file.

# Dependencies:
#     Python:  Load_MasterDictionary.py
#     Data:    LoughranMcDonald_MasterDictionary_XXXX.csv

# The program outputs:
#    1.  File name
#    2.  File size (in bytes)
#    3.  Number of words (based on LM_MasterDictionary
#    4.  Proportion of positive words (use with care - see LM, JAR 2016)
#    5.  Proportion of negative words
#    6.  Proportion of uncertainty words
#    7.  Proportion of litigious words
#    8.  Proportion of modal-weak words
#    9.  Proportion of modal-moderate words
#   10.  Proportion of modal-strong words
#   11.  Proportion of constraining words (see Bodnaruk, Loughran and McDonald, JFQA 2015)
#   12.  Number of alphanumeric characters (a-z, A-Z)
#   13.  Number of digits (0-9)
#   14.  Number of numbers (collections of digits)
#   15.  Average number of syllables
#   16.  Average word length
#   17.  Vocabulary (see Loughran-McDonald, JF, 2015)

#   ND-SRAF
#   McDonald 2016/06 : updated 2018/03
# """

# import csv
# import glob
# import re
# import string
# import sys
# import time
# sys.path.append('C:\\Users\\darre\\Documents\\_econ\\fedspeak\\sentiment analysis')  # Modify to identify path for custom modules
# import Load_MasterDictionary as LM

# # User defined directory for files to be parsed
# TARGET_FILES = r'D:/Temp/TestParse/*.*'
# # User defined file pointer to LM dictionary
# MASTER_DICTIONARY_FILE = r'C:\Users\darre\Documents\_econ\fedspeak/LoughranMcDonald_MasterDictionary_2018.csv'
# # User defined output file
# OUTPUT_FILE = r'D:/Temp/Parser.csv'
# # Setup output
# OUTPUT_FIELDS = ['file name,', 'file size,', 'number of words,', '% positive,', '% negative,',
#                  '% uncertainty,', '% litigious,', '% modal-weak,', '% modal moderate,',
#                  '% modal strong,', '% constraining,', '# of alphabetic,', '# of digits,',
#                  '# of numbers,', 'avg # of syllables per word,', 'average word length,', 'vocabulary']

# lm_dictionary = LM.load_masterdictionary(MASTER_DICTIONARY_FILE, True)

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

#     _odata[11] = len(re.findall('[A-Z]', doc))
#     _odata[12] = len(re.findall('[0-9]', doc))
#     # drop punctuation within numbers for number count
#     doc = re.sub('(?!=[0-9])(\.|,)(?=[0-9])', '', doc)
#     doc = doc.translate(str.maketrans(string.punctuation, " " * len(string.punctuation)))
#     _odata[13] = len(re.findall(r'\b[-+\(]?[$€£]?[-+(]?\d+\)?\b', doc))
#     _odata[14] = total_syllables / _odata[2]
#     _odata[15] = word_length / _odata[2]
#     _odata[16] = len(vdictionary)
    
#     # Convert counts to %
#     for i in range(3, 10 + 1):
#         _odata[i] = (_odata[i] / _odata[2]) * 100
#     # Vocabulary
        
#     return _odata