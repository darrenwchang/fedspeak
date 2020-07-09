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
source("panel_balancing.R")
source("nowcast_adj.R")
source("methodEM.R")

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

## -- NOWCASTING
# sent_gdp_month <- vroom("..\\sentiment analysis\\sent_gdp_month.csv")

## use tidyquant to get all the indicators

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

# base <-
#         factors %>% 
#         pivot_wider(
#                 names_from = symbol,
#                 values_from = price) 

base_nd <- 
        factors %>% 
        pivot_wider(
                names_from = symbol,
                values_from = price) %>% 
        select(-date)

## -- PARAMETER SETUP
trans <- c(2, 2, 1, 1, 1, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 1, 6, 1, 0, 0, 1, 7)
frequency <- c(12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12,
                4, 12, 12, 12, 12, 4)

gdp_balance <- balance_panel(base = base_nd, 
                                start = c(1970, 1), 
                                end = c(2020,6), 
                                frequency = 12, 
                                trans = trans, 
                                NA.replace = F, 
                                na.prop = 1)

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

gdp_nowcastEM <- nowcast_adj(formula = GDPC1 ~ ., 
                data = gdp_balance, 
                r = 1, 
                p = 1, 
                method = "EM", 
                blocks = blocks, 
                frequency = frequency)

nowcast.plot(gdp_nowcast)
# nowcast.plot(gdp_nowcast)

# ## NYFED Nowcasting -- Dynamic Factor Example
# data(NYFED)

# blocks_ny <- NYFED$blocks$blocks
# trans <- NYFED$legend$Transformation
# frequency_ny <- NYFED$legend$Frequency
# delay_ny <- NYFED$legend$delay
# base_ny <- NYFED$base
# trans_ny <- NYFED$legend$Transformation
# data <- NYFED$base

# gdp_ny <- Bpanel(base = data, trans = trans_ny, NA.replace = F, na.prop = 1)
# nowEM <- nowcast(formula = GDPC1 ~ ., data = gdp_ny, r = 1, p = 1, 
#                 method = "EM", blocks = blocks_ny, frequency = frequency_ny)
# nowcast.plot(nowEM)

# # # forecast
# # fcst_dates <- seq.Date(from = as.Date("2013-03-01"), to = as.Date("2017-12-01"),
# #         by = "quarter")
# # fcst_results <- NULL
# # for(date in fcst_dates){
# #         vintage <- PRTDB(gdp_ny, delay = delay_ny, vintage = date)
# #         nowEM <- nowcast(formula = GDPC1~., data = vintage, r = 1, p = 1, method = "EM",
# #         blocks = blocks_ny, frequency = frequency_ny)
# #         fcst_results <- c(fcst_results,tail(nowEM$yfcst[,3],1))
# # }
# # nowcast.plot(fcst_results)