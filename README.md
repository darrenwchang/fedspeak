# [fedspeak](https://github.com/darrenwchang/fedspeak)
Fedspeak is a personal project to quantify and analyze Federal Reserve Beige Book material. The goal is to use text mining and NLP techniques and think of qualitative information as a segway into quantitative indexes for regional economics and/or forecasting.

The [Beige Book](https://www.federalreserve.gov/monetarypolicy/beige-book-default.htm) is a report published by the Federal Reserve 8 times a year and describes economic conditions across the United States for each of the 12 regional banks.

## Overview
This respository contains:

- [Documentation](fedspeak.pdf) for how the code works and analysis of the project results. There's also a to-do here.
- [Python code](text%20mining/text_mining.py) for text mining the Beige Book from the Minneapolis Federal Reserve website
- [R code](sentiment%20analysis/sentiment.R) for finding sentiment of Beige Book reports by bank and as a time series to compare to regional economic indicators

## Visualization

![Beige book vs GDP Growth](https://github.com/darrenwchang/fedspeak/blob/master/sentiment%20analysis/sentiment_gdp.png)

![Beige book polarity over time](https://github.com/darrenwchang/fedspeak/blob/master/sentiment%20analysis/sentiment_base.png)