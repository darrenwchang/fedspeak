# sentiment analysis (and visualization) with tidytext
# darren chang

library(tidyverse)
library(tidytext)
library(vroom)
library(ggthemes)
library(zoo)
library(viridis)

setwd("C:\\Users\\darre\\Documents\\_econ\\fedspeak\\sentiment analysis")
# setwd("C:\\Users\\darre\\Documents\\_econ\\fedspeak")
fed_text_all <- vroom('C:\\Users\\darre\\Documents\\_econ\\fedspeak\\text mining\\fed_text_all.csv') # read csv

recessions.df <- read.table(textConnection(
    "Peak, Trough
    1948-11-01, 1949-10-01
    1953-07-01, 1954-05-01
    1957-08-01, 1958-04-01
    1960-04-01, 1961-02-01
    1969-12-01, 1970-11-01
    1973-11-01, 1975-03-01
    1980-01-01, 1980-07-01
    1981-07-01, 1982-11-01
    1990-07-01, 1991-03-01
    2001-03-01, 2001-11-01
    2007-12-01, 2009-06-01"), 
    sep=',',
    colClasses = c('Date', 'Date'), 
    header = TRUE)

fed_sentiment <- 
    fed_text_all %>% 
    inner_join(get_sentiments("loughran")) %>% # or bing
    # inner_join(get_sentiments("bing")) %>% 
    count(date, sentiment) %>% 
    pivot_wider(names_from = sentiment, 
                values_from = n, 
                values_fill = 0) %>% 
    mutate(sentiment = (positive - negative)/(positive + negative)) %>%
    mutate(date = as.Date(date, format = "%m/%d/%Y")) %>% 
    filter(sentiment != 1) %>% 
    filter(date != "2015-07-01") %>% 
    mutate(sent_ma = rollmean(sentiment, k = 3, fill = NA))

fed_sentiment_bank <- 
    fed_text_all %>% 
    inner_join(get_sentiments("loughran")) %>% # or bing
    # inner_join(get_sentiments("bing")) %>%
    count(report, year, date, bank, sentiment) %>% 
    pivot_wider(names_from = sentiment, 
                values_from = n, 
                values_fill = 0) %>% 
    mutate(sentiment = (positive - negative)/(positive+negative)) %>%
    group_by(bank) %>% 
    mutate(sent_norm = scale(sentiment)) %>% 
    ungroup() %>%
    mutate(date = as.Date(date, format = "%m/%d/%Y")) %>% 
    filter(sentiment != 1) %>%
    filter(date != "2015-07-01") %>% 
    select(date, bank, sent_norm, sentiment) %>% 
    pivot_longer(-c(date, bank), 
                names_to = "transformation", 
                values_to = "value") %>% 
    mutate(transformation = as_factor(transformation))

fed_sentiment_scale <- 
    fed_text_all %>% 
    inner_join(get_sentiments("loughran")) %>% # or bing
    # inner_join(get_sentiments("bing")) %>%
    count(report, year, date, bank, sentiment) %>% 
    pivot_wider(names_from = sentiment, 
                values_from = n, 
                values_fill = 0) %>%     
    mutate(sentiment = (positive - negative)/(positive+negative)) %>%
    group_by(bank) %>% 
    mutate(sent_norm = scale(sentiment)) %>% 
    ungroup() %>%
    mutate(date = as.Date(date, format = "%m/%d/%Y")) %>% 
    filter(sentiment != 1) %>%
    filter(date != "2015-07-01") %>% 
    select(date, sent_norm, bank, sentiment) %>% 
    group_by(date) %>% 
    summarize(norm_mean = mean(sent_norm),
            sent_mean = mean(sentiment)) %>% 
    mutate(sent_norm_mean_ma = rollmean(norm_mean, 
            k = 3, 
            fill = NA)) %>%
    mutate(sent_mean_ma = rollmean(sent_mean, 
            k = 3, 
            fill = NA)) %>%
    pivot_longer(-date, 
                names_to = "transformation", 
                values_to = "value") %>% 
    mutate(transformation = as_factor(transformation))

# bar plot
# ggplot(fed_sentiment,
#     aes(date, sentiment, fill = sentiment > 0)) +
#     geom_col(show.legend = FALSE) +
#     scale_fill_manual(values=c("red","#27408b")) +
#     #facet_wrap(~report, ncol = 8, scales = "free_x")+
#     theme_fivethirtyeight() +
#     labs(x="report (~8 per year)",
#         y="sentiment",
#         title="Sentiment in Federal Reserve Beige Book",
#         subtitle="customized Loughran lexicon\npolarity = (positive-negative)/(positive+negative)",
#         caption="@darrenwchang\nSource: Beige Book")

# line plot
g1 <- ggplot(fed_sentiment,
    aes(x = date)) +
    geom_line(aes(y = sentiment), color = 'blue') +
    geom_line(aes(y = sent_ma), color = 'red') +
    theme_fivethirtyeight() +
    scale_x_date(
        #breaks = "5 years", 
    limits = as.Date(c("1970-01-01","2020-06-01")),
    date_labels = "%Y") +
    labs(x = "Beige Book Report (~8/year)",
        y = "polarity",
        title = "Sentiment in Federal Reserve Beige Book",
        subtitle = "customized Loughran lexicon\npolarity = (positive-negative)/(positive+negative)",
        caption = "@darrenwchang\nSource: Federal Reserve Bank of Minneapolis\nShaded areas NBER recessions") +
    geom_rect(data=recessions.df, 
                    inherit.aes = F, 
                aes(xmin = Peak, 
                    xmax = Trough, 
                    ymin = -Inf, 
                    ymax = +Inf), 
                    fill='darkgray', 
                    alpha=0.5)

g1

ggsave("sentiment_base.png", plot = g1, device = png())

g2 <- ggplot(fed_sentiment_bank,
    aes(x = date, y = value, color = transformation)) +
    geom_line() +
    theme_fivethirtyeight() +
    scale_x_date(
        limits = as.Date(c("1970-01-01","2020-06-01")),
        date_labels = "%Y") +
    scale_color_manual(
        name = "Transformation",
        labels = c('Scaled Polarity', 'Raw Polarity'),
        values = c('blue', 'red')) +
    labs(x = "Beige Book Report (~8/year)",
        y = "polarity",
        title = "Sentiment in Federal Reserve Beige Book",
        subtitle = "customized Loughran lexicon\npolarity = (positive-negative)/(positive+negative)",
        caption = "@darrenwchang\nSource: Federal Reserve Bank of Minneapolis\nShaded areas NBER recessions") +
    facet_wrap(~bank, scales = 'free_x', ncol = 5,
    labeller = as_labeller(c('at' = 'Atlanta', 'bo' = 'Boston',
                    'ch' = 'Chicago', 'cl' = 'Cleveland',
                    'da' = 'Dallas', 'kc' = 'Kansas City',
                    'mi' = 'Minneapolis', 'ny' = 'New York',
                    'ph' = 'Philadelphia', 'ri' = 'Richmond',
                    'sf' = 'San Francisco', 'sl' = 'St. Louis',
                    'su' = 'National Summary'))) +
    geom_rect(data = recessions.df, 
                    inherit.aes = F, 
                aes(xmin = Peak, 
                    xmax = Trough, 
                    ymin = -Inf, 
                    ymax = +Inf), 
                    fill='darkgray', 
                    alpha=0.5)

g2

ggsave("sentiment_base_bank.png", plot = g2, device = png())

g3 <- ggplot(filter(fed_sentiment_scale, 
transformation == "sent_norm_mean_ma" | transformation == "norm_mean" | transformation == 'sent_mean'),
    aes(x = date, y = value, color = transformation)) +
    geom_line() +
    theme_fivethirtyeight() +
    scale_x_date(limits = as.Date(c("1970-01-01","2020-06-01")),
                date_labels = "%Y") +
    scale_color_manual(
        name = "Transformation",
        labels = c('Scaled Polarity', 'Raw Polarity', 'Scaled Polarity (3 mo. mvg avg)'),
        values = c('red', 'green', 'navy')) +
    labs(x = "Beige Book Report (~8/year)",
        y = "polarity",
        title = "Sentiment in Federal Reserve Beige Book",
        subtitle = "customized Loughran lexicon\npolarity = (positive-negative)/(positive+negative)",
        caption = "@darrenwchang\nSource: Federal Reserve Bank of Minneapolis\nShaded areas NBER recessions") +
    geom_rect(data = recessions.df, 
                    inherit.aes = F, 
                aes(xmin = Peak, 
                    xmax = Trough, 
                    ymin = -Inf, 
                    ymax = +Inf), 
                    fill='darkgray', 
                    alpha=0.5)

g3

ggsave("sentiment_norm_ma.png", plot = g3, device = png())

# use fredr for this
# https://fred.stlouisfed.org/categories/32071