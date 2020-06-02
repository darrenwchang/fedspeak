# sentiment analysis (and visualization) with tidytext
# darren chang

library(tidyverse)
library(tidytext)
library(vroom)
library(ggthemes)

setwd("C:\\Users\\darre\\Documents\\_econ\\fedspeak\\sentiment analysis")
fed_text_all <- vroom('C:\\Users\\darre\\Documents\\_econ\\fedspeak\\text mining\\fed_text_all.csv') # read csv

fed_sentiment <- 
    fed_text_all %>% 
    inner_join(get_sentiments("loughran")) %>% 
    count(report, year, date, sentiment) %>% 
    spread(sentiment, n, fill = 0) %>% 
    mutate(sentiment = (positive - negative)/(positive+negative)) %>% 
    mutate(date = as.Date(date, format = "%m/%d/%Y")) %>% 
    filter(sentiment != 1) # this data is not available on the Minneapolis Fed website

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
    aes(x = date, y = sentiment)) +
    geom_line(color = 'blue') +
    theme_fivethirtyeight() +
    scale_x_date(breaks = "5 years", 
    limits = as.Date(c("1970-01-01","2020-01-01")),
    date_labels = "%Y") +
    labs(x = "Beige Book Report (~8/year)",
        y = "polarity",
        title = "Sentiment in Federal Reserve Beige Book",
        subtitle = "customized Loughran lexicon\npolarity = (positive-negative)/(positive+negative)",
        caption = "@darrenwchang\nSource: Federal Reserve Bank of Minneapolis")

g1

ggsave("sentiment_base.png", plot = g1, device = png())

# use fredr for this
# https://fred.stlouisfed.org/categories/32071