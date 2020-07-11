# BB forecasting
# darren chang

## -- SETUP
library(tidyverse)
# library(prophet)
# library(forecast)
library(vroom)
library(nowcasting)
library(tidyquant)
library(matlab)

setwd("C:\\Users\\darre\\Documents\\_econ\\fedspeak\\forecasting")

# sent_gdp <- vroom("..\\sentiment analysis\\sent_gdp.csv")

# ## -- FBPROPHET
# sent_gdp <- 
#         sent_gdp %>% 
#         rename(ds = date,
#                 y = value)

# m <- sent_gdp %>% 
#         filter(series == "polarity_ma") %>%
#         prophet::prophet()

# future <- make_future_dataframe(m, periods = 8, freq = 'quarter')
# forecast <- predict(m, future)

# plot(m, forecast)

# # clearly, this model is not very appropriate

### -- NOWCASTING

## -- data import

# import sentiments
sent_gdp_month <- vroom("..\\sentiment analysis\\sent_gdp_month.csv")
sent_gdp_month <- 
        sent_gdp_month %>% 
        rename(symbol = series,
                price = value)

# use tidyquant to get all the indicators
tickers <- c('PAYEMS', # payroll employment
                'JTSJOL', # job openings
                'CPIAUCSL', # CPI inflation urban
                'DGORDER', # durable goods orders
                'RSAFS', # advanced retail sales, retail and food
                'UNRATE', # unemployment rate
                'HOUST', # new housing starts
                'INDPRO', # industrial production index
                'DSPIC96', # real disposable personal income
                'BOPTEXP', # BOP exports
                'BOPTIMP', # BOP imports
                'TTLCONS', # total construction spending
                'IR', # import price index
                'CPILFESL', # CPI less food energy
                'PCEPILFE', # PCE less food energy
                'PCEPI', # PCE price index
                'PERMIT', # building permits
                'TCU', # capacity utilization
                'BUSINV', # business inventories
                'ULCNFB', # unit labor cost
                'IQ', # export price index
                'GACDISA066MSFRBNY', # empire state mfg index
                'GACDFSA066MSFRBPHI', # philly fed mfg index
                'PCEC96', # real consumption spending
                'GDPC1' # real GDP
                )

factors <- tq_get(tickers, get = 'economic.data', from = '1970-01-01')

# keep only moving averages
factors_pol <- factors %>% 
        bind_rows(filter(sent_gdp_month, symbol != 'polarity'))

### -- WITHOUT BB INDEX [BBPOLAR]

## -- data setup

# lag GDP properly and make wider
base <- 
        factors %>% 
        pivot_wider(
                names_from = symbol,
                values_from = price) %>%
        mutate(GDPC1 = lag(GDPC1, 2)) %>%
        select(-date)

# make times series object
base_ts <- ts(base,
        start = c(1970, 1),
        end = c(2020,6),
        frequency = 12)

# set up parameters
trans <- c(2, 2, 1, 1, 1, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 1, 6, 1, 0, 0, 1, 7)
frequency <- c(12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12,
                4, 12, 12, 12, 12, 4)

blocks <- tibble::tribble(~Global, ~Soft, ~Real, ~Labor,
                1,    0,    0,    1,
                1,    0,    0,    1,
                1,    0,    0,    0,
                1,    0,    1,    0,
                1,    0,    1,    0,
                1,    0,    0,    1,
                1,    0,    1,    0,
                1,    0,    1,    0,
                1,    0,    1,    0,
                1,    0,    1,    0,
                1,    0,    1,    0,
                1,    0,    1,    0,
                1,    0,    0,    0,
                1,    0,    0,    0,
                1,    0,    0,    0,
                1,    0,    0,    0,
                1,    0,    1,    0,
                1,    0,    1,    0,
                1,    0,    1,    0,
                1,    0,    0,    1,
                1,    0,    0,    0,
                1,    1,    0,    0,
                1,    1,    0,    0,
                1,    0,    1,    0,
                1,    0,    1,    0
)

## -- balance panels using nowcasting::Bpanel()
base_ts_balance <- Bpanel(base = base_ts,
                trans = trans, 
                NA.replace = F, 
                na.prop = 1)

## -- nowcast
gdp_nowcastEM <- nowcast(formula = GDPC1 ~ ., 
                data = base_ts_balance, 
                r = 1, 
                p = 1, 
                method = "EM", 
                blocks = blocks, 
                frequency = frequency)

## -- plotting
nowcast.plot(gdp_nowcastEM)

### -- WITH BB INDEX [BBPOLAR]

## -- data setup

# lag GDP properly and make wider
base_bb <- 
        factors_pol %>% 
        pivot_wider(
                names_from = symbol,
                values_from = price) %>%
        mutate(GDPC1 = lag(GDPC1, 2)) %>%
        rename(BBPOLAR = polarity_ma) %>% 
        select(-date)

# make times series object
base_ts_bb <- ts(base_bb,
        start = c(1970, 1),
        end = c(2020,6),
        frequency = 12)

# set up parameters
trans_bb <- c(2, 2, 1, 1, 1, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 1, 6, 1, 0, 0, 1, 7, 0)
frequency_bb <- c(12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12,
                4, 12, 12, 12, 12, 4, 12)

blocks_bb <- tibble::tribble(~Global, ~Soft, ~Real, ~Labor,
                1,    0,    0,    1,
                1,    0,    0,    1,
                1,    0,    0,    0,
                1,    0,    1,    0,
                1,    0,    1,    0,
                1,    0,    0,    1,
                1,    0,    1,    0,
                1,    0,    1,    0,
                1,    0,    1,    0,
                1,    0,    1,    0,
                1,    0,    1,    0,
                1,    0,    1,    0,
                1,    0,    0,    0,
                1,    0,    0,    0,
                1,    0,    0,    0,
                1,    0,    0,    0,
                1,    0,    1,    0,
                1,    0,    1,    0,
                1,    0,    1,    0,
                1,    0,    0,    1,
                1,    0,    0,    0,
                1,    1,    0,    0,
                1,    1,    0,    0,
                1,    0,    1,    0,
                1,    0,    1,    0,
                1,    1,    0,    0
)

## -- balance panels using nowcasting::Bpanel()
base_ts_balance_bb <- Bpanel(base = base_ts_bb,
                trans = trans_bb, 
                NA.replace = F, 
                na.prop = 1)

## -- nowcast
gdp_bb_nowcastEM <- nowcast(formula = GDPC1 ~ ., 
                data = base_ts_balance_bb, 
                r = 1, 
                p = 1, 
                method = "EM", 
                blocks = blocks_bb, 
                frequency = frequency_bb)

## -- plotting
nowcast.plot(gdp_bb_nowcastEM)