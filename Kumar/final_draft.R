


library(tidyverse)
library(lubridate)
library(dplyr)

# load two datasets - elecction results, and redistricting

elec <- read.csv("D:/Work/Georgetown/acad/acel stats/proj/election data/state/1976-2020-house.csv", stringsAsFactors = FALSE)


ger <- read.csv("D:/Work/Georgetown/acad/acel stats/proj/StatesAndCyclesData_production-220823c.csv", stringsAsFactors = FALSE)


# single_dists <- c("AK", "DE", "MT", "ND", "SD", "VT", "WY")


# Redistricting data (ger)


    # Drop States that only have 1 district 
    
    
    #IN the ger data, they have "n/a" for "institution"
    
    ger <- ger %>% filter(Cycle.Year>=2000) %>%
      filter(Institution != "n/a") %>%
      filter(Level=='Congress')


# Election data
    
# Keep only for required span - 2000 to 2020
  # drop  single dist states  
 single_dists <- c("AK", "DE", "MT", "ND", "SD", "VT", "WY")

elec <- elec %>%
  filter(year >= 2000) %>%
  filter(!state_po %in% single_dists)




############################################################
# Aggregation

# Gen new party2 variable

elec <- elec %>%
  mutate(party2 = case_when(
    party =="DEMOCRAT" ~ 'DEMOCRAT',
    party=="REPUBLICAN" ~ "REPUBLICAN",
    TRUE ~ as.character('OTHER'))) 


# Pivot wide - column for party totals
votes <- elec %>% pivot_wider(names_from = party2, values_from = candidatevotes) %>%
  mutate(across(c(DEMOCRAT, REPUBLICAN, OTHER), ~case_when(.== "NULL" ~ 0, 
                                  TRUE ~as.numeric(as.character(.)))))

# total turnout column
votes$turnout <- votes$DEMOCRAT+votes$REPUBLICAN+votes$OTHER

# Data now is at State-Year-Many districts - 
# aggregate statistics for all districts to one obsdrvation for state

votes <- votes %>%  group_by(state_po, year) %>% 
  summarize(demv = sum(DEMOCRAT), repv = sum(REPUBLICAN), othv = sum(OTHER), turnout = sum(turnout)) 



# create new "map_year" column in elec df as year-1 rounded to 10s
# the year in which the map for that election was drawn
votes <- votes %>%
  mutate(map_year = case_when(
    year <= 2010 ~ 2000,
   year>2010 ~ 2010))


##################################################################


# Merge

fnl<- votes %>%
  left_join(ger, by = c("state_po" = "State", "map_year" = "Cycle.Year"))

write.csv(fnl, "D:/Work/Georgetown/acad/acel stats/proj/merged.csv", row.names=TRUE)



