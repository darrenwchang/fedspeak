library(tidyverse)
#install.packages("tidytext")
library(tidytext)
library(rvest)
library(purrr)
library(curl)

setwd("C:\\Users\\darre\\Documents\\_econ\\fedspeak")

links <- read.csv("links.csv") %>%
    as_tibble() %>% 
    rename(year = ï..year) %>%
    select(year, url, report, date) %>%
    mutate(date = as.Date(date)) %>% 
    mutate(url = toString(url))
head(links)
branch <- list("at", "bo", "ch", "cl", "da", "kc", "mi", "ny", "ph", "ri", "sf", "st", "su")

# list1 <- mapply(function(x, y) paste0("https://www.minneapolisfed.org/beige-book-reports/", x, "/", x, "-"), linkyr)
# list1

# list2 <- mapply(function(x, y) paste0(x, "-", y), months1, rep(branch, each = length(months1)))
# list2

# url_list <- as_tibble(mapply(function(x, y) paste0(x, y), rep(list1, each = length(months1)*length(branch)), list2))
# url_list
# url_list <-
#     url_list %>%
#     rename(url = value)

read_html_possibly <- possibly(read_html, otherwise = "This page could not be reached")

read_html()

links2 <- 
    links[2:4,] %>% 
    mutate(url = curl(url))

View(links2)

links2 %>% 
    map(url, read_html)

links2 <- 
    links2 %>% 
    mutate(url = url(url, "rb"))
link1 <- curl("https://www.minneapolisfed.org/beige-book-reports/2020/2020-04-sl")
    read_html(link1)


links2text <- 
    links2 %>% 
        mutate(text = map(url, read_html)) %>%
        html_nodes(".offset-lg-1 p") %>%
        html_text() %>%
        unnest(text) %>%
        group_by(date) %>%
        ungroup()

links2text <- 
    links2 %>% 
        mutate(text = map(url, curl))

links2 %>% 
    read_html(url)

    View(links2)

read_html("https://www.minneapolisfed.org/beige-book-reports/2003/2003-10-at") %>% 
    html_nodes(".offset-lg-1 p") %>%
    html_text() 
    
    
    %>%
    unnest(text) 
    
    %>%
    group_by(date) %>%
    ungroup()

View(links2text)

ptm <- proc.time()
fed_text_raw <-
    links %>%
        mutate(text= purrr::map(url, read_html_possibly)) %>%
        html_nodes(".offset-lg-1 p") %>%
        html_text() %>%
        unnest(text) %>%
        group_by(date) %>%
        ungroup()
proc.time() - ptm

fed_text_raw <-
    tibble(text = unlist(strsplit(pg_text, "\r"))) %>%
    mutate(report = "stljan20",
    line = row_number(),
    text=gsub("\n", "", text)
    )

head(fed_text_raw)

fed_text <-
    fed_text_raw %>%
    as_tibble() %>%
    unnest_tokens(word, text)

fed_text <-
    fed_text %>%
    anti_join(stop_words) %>%
    mutate(word = gsub("[^A-Za-z ]","",word)) %>%
    filter(word != "")

sentiment <-
    fed_text %>%
        inner_join(get_sentiments("loughran")) %>%
        count(word, sentiment, sort = T)
sentiment <-
    fed_text %>%
        inner_join(get_sentiments("loughran")) %>%
    count(report, index = line %/% 10, sentiment) %>%
    spread(sentiment, n, fill = 0) %>%
    mutate(sentiment = positive - negative)

ggplot(sentiment,
    aes(index, sentiment, fill = sentiment >0)) +
    geom_col(show.legend = F) 


######LEN KIEFER's CODE######
# load libraries ----
suppressPackageStartupMessages({
# library(extrafont)
# library(ggraph)
# library(ggridges)
library(pdftools)
library(tidyverse)
library(tidytext)
library(forcats)
library(reshape2)
library(tidyr)
library(igraph)
library(widyr)
library(lubridate)})
# library(ggrepel)
# library(viridis)}


# get all data ----
# links to pdf ----
beige.links.all<-
  tibble::tribble(
    ~url,   ~report, ~report.date,
    "https://www.federalreserve.gov/monetarypolicy/files/BeigeBook_20180117.pdf", 20180117L, "2018-01-17",
    "https://www.federalreserve.gov/monetarypolicy/files/BeigeBook_20180307.pdf", 20180307L, "2018-03-07",
    "https://www.federalreserve.gov/monetarypolicy/files/BeigeBook_20180418.pdf", 20180418L, "2018-04-18",
    "https://www.federalreserve.gov/monetarypolicy/files/BeigeBook_20180530.pdf", 20180530L, "2018-05-30",
    "https://www.federalreserve.gov/monetarypolicy/files/BeigeBook_20180718.pdf", 20180718L, "2018-07-18",
    "https://www.federalreserve.gov/monetarypolicy/beigebook/files/Beigebook_20170118.pdf", 20170118L, "2017-01-18",
    "https://www.federalreserve.gov/monetarypolicy/files/Beigebook_20170301.pdf", 20170301L, "2017-03-01",
    "https://www.federalreserve.gov/monetarypolicy/files/Beigebook_20170419.pdf", 20170419L, "2017-04-19",
    "https://www.federalreserve.gov/monetarypolicy/files/BeigeBook_20170531.pdf", 20170531L, "2017-05-31",
    "https://www.federalreserve.gov/monetarypolicy/files/BeigeBook_20170712.pdf", 20170712L, "2017-07-12",
    "https://www.federalreserve.gov/monetarypolicy/files/Beigebook_20170906.pdf", 20170906L, "2017-09-06",
    "https://www.federalreserve.gov/monetarypolicy/files/BeigeBook_20171018.pdf", 20171018L, "2017-10-18",
    "https://www.federalreserve.gov/monetarypolicy/files/BeigeBook_20171129.pdf", 20171129L, "2017-11-29"
  )

ptm <- proc.time()
# get data ----
fed_text_raw <-
  beige.links.all %>%
  mutate(text= map(url,pdf_text))  %>% 
  unnest(text) %>% 
  group_by(report) %>%
  # create a page number indicator
  mutate(page=row_number()) %>% 
  ungroup() 
proc.time() - ptm

# View(fed_text_raw)