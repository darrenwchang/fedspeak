####### sentiment analysis
### darren chang

#### SETUP
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

import os #setwd
import time #timing

from sklearn_pandas import DataFrameMapper #scikit learn for pandas

os.chdir('C:\\Users\\darre\\Documents\\_econ\\fedspeak\\sentiment analysis')
fed_text_all = pd.read_csv('C:\\Users\\darre\\Documents\\_econ\\fedspeak\\text mining\\fed_text_all.csv') # read csv
fed_text_all.head(10)

lm_dict = (pd.read_csv('loughran_mcdonald.csv', header = 0)
                .fillna('')
                .apply(lambda x: x.astype(str))
                .apply(lambda x: x.str.lower())
                # .to_dict()
                )

positive = lm_dict['positive'].tolist()
positive = (pd.DataFrame(list(filter(None, positive)), columns = ['word'])
                .assign(sentiment = 'positive'))

negative = lm_dict['negative'].tolist()
negative = (pd.DataFrame(list(filter(None, negative)), columns = ['word'])
                .assign(sentiment = 'negative'))

uncertainty = lm_dict['uncertainty'].tolist()
uncertainty = (pd.DataFrame(list(filter(None, uncertainty)), columns = ['word'])
                .assign(sentiment = 'uncertainty'))

weak_modal = lm_dict['weak_modal'].tolist()
weak_modal = (pd.DataFrame(list(filter(None, weak_modal)), columns = ['word'])
                .assign(sentiment = 'weak_modal'))

strong_modal = lm_dict['strong_modal'].tolist()
strong_modal = (pd.DataFrame(list(filter(None, strong_modal)), columns = ['word'])
                .assign(sentiment = 'strong_modal'))

constraining = lm_dict['constraining'].tolist()
constraining = (pd.DataFrame(list(filter(None, constraining)), columns = ['word'])
                .assign(sentiment = 'constraining'))

lm_dict = (positive.append(negative, ignore_index = True)
        .append(uncertainty, ignore_index = True)
        .append(weak_modal, ignore_index = True)
        .append(strong_modal, ignore_index = True)
        .append(constraining, ignore_index = True)
)

def get_sentiment(
    df, # dataframe of words
    dict # dataframe of dictionary that you want to use
):
    return (df
            .merge(dict)
            .sort_values(by = ['report'], ignore_index = True))

fed_sentiment = get_sentiment(fed_text_all, lm_dict)

fed_sentiment = (fed_sentiment
    .groupby(['report','date','url','year','month','bank','sentiment'])
    .count()
    .unstack(-1, fill_value = 0))
scaler = StandardScaler()
(fed_sentiment
    .assign(polarity = lambda x: (fed_sentiment['word']['positive']-fed_sentiment['word']['negative'])/(fed_sentiment['word']['positive']+fed_sentiment['word']['negative']))
    .groupby('bank')
)

# mapper = DataFrameMapper([(df.columns, StandardScaler())])
# scaled_features = mapper.fit_transform(df.copy(), 4)
# scaled_features_df = pd.DataFrame(scaled_features, index=df.index, columns=df.columns)