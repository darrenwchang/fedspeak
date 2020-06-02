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
    count(report, sentiment, date) %>% 
    spread(sentiment, n, fill = 0) %>% 
    mutate(sentiment = (positive - negative)/(positive+negative)) %>% 
    mutate(date = as.Date(date, format = "%m/%d/%Y"))

ggplot(fed_sentiment,
    aes(date, sentiment, fill = sentiment>0)) +
    geom_col(show.legend = FALSE) +
    scale_fill_manual(values=c("red","#27408b")) +
    #facet_wrap(~report, ncol = 8, scales = "free_x")+
    theme_fivethirtyeight() +
    labs(x="report (~8 per year)",
        y="sentiment",
        title="Sentiment in Federal Reserve Beige Book",
        subtitle="customized bing lexicon\nsentiment = (positive-negative)/(positive+negative)",
        caption="@thedarrenchang\nSource: Beige Book")