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

fed_sentiment <- 
    fed_text_all %>% 
    inner_join(get_sentiments("loughran")) %>% # or bing
    # inner_join(get_sentiments("bing")) %>% 
    # count(report, year, date, sentiment) %>% 
    count(date, sentiment) %>% 
    spread(sentiment, n, fill = 0) %>% 
    mutate(sentiment = (positive - negative)/(positive + negative)) %>%
    mutate(date = as.Date(date, format = "%m/%d/%Y")) %>% 
    filter(sentiment != 1) %>%  # this data is not available on the Minneapolis Fed website
    filter(date != "2015-07-01") %>% 
    mutate(sent_ma = rollmean(sentiment, k = 3, fill = NA))

fed_sentiment_bank <- 
    fed_text_all %>% 
    inner_join(get_sentiments("loughran")) %>% # or bing
    # inner_join(get_sentiments("bing")) %>%
    count(report, year, date, bank, sentiment) %>% 
    spread(sentiment, n, fill = 0) %>% 
    mutate(sentiment = (positive - negative)/(positive+negative)) %>%
    group_by(bank) %>% 
    mutate(sent_norm = scale(sentiment)) %>% 
    ungroup() %>%
    mutate(date = as.Date(date, format = "%m/%d/%Y")) %>% 
    filter(sentiment != 1) %>%
    filter(date != "2015-07-01") %>% 
    select(date, bank, sent_norm, sentiment) %>% 
    pivot_longer(-c(date, bank), names_to = "transformation", values_to = "value") %>% 
    mutate(transformation = as_factor(transformation))

fed_sentiment_scale <- 
    fed_text_all %>% 
    inner_join(get_sentiments("loughran")) %>% # or bing
    # inner_join(get_sentiments("bing")) %>%
    count(report, year, date, bank, sentiment) %>% 
    spread(sentiment, n, fill = 0) %>% 
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
                # norm_sum = sum(sent_norm), 
                # sent_sum = sum(sentiment),
                sent_mean = mean(sentiment)) %>% 
    mutate(sent_norm_mean_ma = rollmean(norm_mean, k = 3, fill = NA)) %>%
    # mutate(sent_norm_sum_ma = rollmean(norm_sum, k = 3, fill = NA)) %>%
    mutate(sent_mean_ma = rollmean(sent_mean, k = 3, fill = NA)) %>%
    # mutate(sent_sum_ma = rollmean(sent_sum, k = 3, fill = NA))  %>% 
    pivot_longer(-date, names_to = "transformation", values_to = "value") %>% 
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
        caption = "@darrenwchang\nSource: Federal Reserve Bank of Minneapolis")

g1

ggsave("sentiment_base.png", plot = g1, device = png())

g2 <- ggplot(fed_sentiment_bank,
    aes(x = date, y = value, color = transformation)) +
    geom_line() +
    theme_fivethirtyeight() +
    # scale_x_date(limits = as.Date(c("1970-01-01","2020-01-01")),
    # date_labels = "%Y") +
    labs(x = "Beige Book Report (~8/year)",
        y = "polarity",
        title = "Sentiment in Federal Reserve Beige Book",
        subtitle = "customized Loughran lexicon\npolarity = (positive-negative)/(positive+negative)",
        caption = "@darrenwchang\nSource: Federal Reserve Bank of Minneapolis") +
    facet_wrap(~bank, scales = 'free_x', ncol = 5)

g2

ggsave("sentiment_base_bank.png", plot = g2, device = png())

g3 <- ggplot(filter(fed_sentiment_scale, transformation == "sent_norm_mean_ma" | transformation == "norm_mean"),
    aes(x = date, y = value, color = transformation)) +
    geom_line() +
    #scale_color_viridis() +
    theme_fivethirtyeight() +
    # scale_x_date(limits = as.Date(c("1970-01-01","2020-01-01")),
    # date_labels = "%Y") +
    labs(x = "Beige Book Report (~8/year)",
        y = "polarity",
        title = "Sentiment in Federal Reserve Beige Book",
        subtitle = "customized Loughran lexicon\npolarity = (positive-negative)/(positive+negative)",
        caption = "@darrenwchang\nSource: Federal Reserve Bank of Minneapolis")

g3

ggsave("sentiment_norm_ma.png", plot = g3, device = png())

# use fredr for this
# https://fred.stlouisfed.org/categories/32071