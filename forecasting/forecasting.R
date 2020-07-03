# BB forecasting
# darren chang

## -- SETUP
library(tidyverse)
library(prophet)
library(forecast)
library(vroom)

setwd("C:\\Users\\darre\\Documents\\_econ\\fedspeak\\forecasting")

sent_gdp <- vroom("..\\sentiment analysis\\sent_gdp.csv")

sent_gdp <- 
        sent_gdp %>% 
        rename(ds = date,
                y = value)

m <- sent_gdp %>% 
        filter(series == "polarity_ma") %>%
        prophet::prophet()

future <- make_future_dataframe(m, periods = 8, freq = 'quarter')
forecast <- predict(m, future)

plot(m, forecast)

# clearly, this model is not very appropriate