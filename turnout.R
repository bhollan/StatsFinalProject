library(tidyverse)
library(lubridate)
library(dplyr)

ger <- read.csv("StatesAndCyclesData.csv")
elec <- read.csv("1976-2020-house.csv")# States with only one district
# single_dists <- c("AK", "DE", "MT", "ND", "SD", "VT", "WY")


# Ger data
# States that only have 1 district have "n/a" for "institution"
ger <- ger %>%
  filter(Institution != "n/a")

single_dists <- c("AK", "DE", "MT", "ND", "SD", "VT", "WY")

# Election data
elec <- elec %>%
  filter(year >= 2000) %>%
  filter(!state_po %in% single_dists)

# Aggregation
# sum(totalvotes)
votes <- elec %>%
  group_by(state_po, year) %>%
  summarize(mean <- mean(totalvotes))


# create new "map_year" column in elec df as year-1 rounded to 10s
# the year in which the map for that election was drawn
votes <- votes %>%
  mutate(map_year = floor((year-1), digits = -2))

# Merge

# join on state/map_year combinations


# Analysis