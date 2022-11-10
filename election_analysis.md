Election analysis
================
2022-11-05

## R Markdown

This is an R Markdown document. Markdown is a simple formatting syntax
for authoring HTML, PDF, and MS Word documents. For more details on
using R Markdown see <http://rmarkdown.rstudio.com>.

When you click the **Knit** button a document will be generated that
includes both content as well as the output of any embedded R code
chunks within the document. You can embed an R code chunk like this:

``` r
df <- read.csv("/Users/Chuyuan/Downloads/1976-2020-house.csv", stringsAsFactors = FALSE)
df$GEOID <- paste(df$state_fips, df$district, sep = "")
df <- select(df, -runoff, -special, -candidate, -unofficial, -version, -writein, -mode, -fusion_ticket)
df$state<- tolower(df$state)
df$state<-capitalize(df$state)
```

``` r
summary(df)
```

    ##       year         state             state_po           state_fips   
    ##  Min.   :1976   Length:31103       Length:31103       Min.   : 1.00  
    ##  1st Qu.:1988   Class :character   Class :character   1st Qu.:17.00  
    ##  Median :2000   Mode  :character   Mode  :character   Median :31.00  
    ##  Mean   :1999                                         Mean   :28.76  
    ##  3rd Qu.:2010                                         3rd Qu.:40.00  
    ##  Max.   :2020                                         Max.   :56.00  
    ##    state_cen        state_ic        office             district     
    ##  Min.   :11.00   Min.   : 1.00   Length:31103       Min.   : 0.000  
    ##  1st Qu.:23.00   1st Qu.:14.00   Class :character   1st Qu.: 3.000  
    ##  Median :51.00   Median :37.00   Mode  :character   Median : 6.000  
    ##  Mean   :50.89   Mean   :37.05                      Mean   : 9.877  
    ##  3rd Qu.:74.00   3rd Qu.:52.00                      3rd Qu.:13.000  
    ##  Max.   :95.00   Max.   :82.00                      Max.   :53.000  
    ##     stage              party           candidatevotes     totalvotes    
    ##  Length:31103       Length:31103       Min.   :    -1   Min.   :    -1  
    ##  Class :character   Class :character   1st Qu.:  4316   1st Qu.:160713  
    ##  Mode  :character   Mode  :character   Median : 56455   Median :205055  
    ##                                        Mean   : 66173   Mean   :213197  
    ##                                        3rd Qu.:110829   3rd Qu.:260660  
    ##                                        Max.   :387109   Max.   :601509  
    ##     GEOID          
    ##  Length:31103      
    ##  Class :character  
    ##  Mode  :character  
    ##                    
    ##                    
    ## 

``` r
# Country level, partisan turnout from 1976-2020

dem <- df %>%
  filter(party== "DEMOCRAT")
rep <- df %>%
  filter(party== "REPUBLICAN")
total <- df[!duplicated(df$totalvotes), ]
dv <- aggregate(candidatevotes ~ year, dem, sum)
rv <- aggregate(candidatevotes ~ year, rep, sum)
tv <- aggregate(totalvotes ~ year, total, sum)
rep_dem_total<- dv %>%
  left_join(rv, by='year') %>% 
  left_join(tv, by='year')
df2 <- pivot_longer(rep_dem_total, candidatevotes.y:candidatevotes.x, names_to = "party", values_to = "candidatevotes")
df3 <- data.frame(arrange(df2, party))
df3 %>%
  mutate(vote_pct = candidatevotes/totalvotes) %>%
  ggplot(aes(x=year, y = vote_pct, colour = party)) + 
  geom_line(size = 0.5) + 
  labs(title = "Dem and Rep voter turnout from 1976-2020", x = "year", y = "percentage of vote by party") + 
  scale_colour_manual(values = c("#56B4E9", "#FF9999"),
                    guide = guide_legend(reverse = TRUE),
                    labels=c("dem_pct","rep_pct")) +
  theme(plot.title = element_text(hjust = 0.5)) 
```

![](election_analysis_files/figure-gfm/unnamed-chunk-4-1.png)<!-- -->

``` r
# State level, all states
rep_dem <- dplyr::filter(df, grepl('^DEMOCRAT$|^REPUBLICAN$', party)) %>%
  mutate(vote_pct=candidatevotes/totalvotes)

ggplot(rep_dem, aes(x=year, y=vote_pct, colour=party))+
  geom_point(size=0.5) +
  labs(x="year", y="vote_pct")+
  geom_line() +
  facet_wrap( ~ state) +
  labs(title = "Voter turnout change across states from 1976-2020", x = "year", y = "percentage of vote by party") + 
  scale_colour_manual(values = c("#56B4E9", "#FF9999"),
                    guide = guide_legend(reverse = TRUE),
                    labels=c("dem_pct","rep_pct")) +
  theme(plot.title = element_text(hjust = 0.5),
        strip.text = element_text(size = 7))
```

    ## Warning: Removed 1 rows containing missing values (geom_point).

![](election_analysis_files/figure-gfm/unnamed-chunk-5-1.png)<!-- -->

``` r
# District level within state, Alabama 
# calculate the percentage of party in total votes by candidatevotes/totalvotes

ALABAMA <- dplyr::filter(df, grepl('Alabama', state))
AL <- dplyr::filter(ALABAMA, grepl('^REPUBLICAN$|^DEMOCRAT$', party)) %>%
  mutate(vote_pct=candidatevotes/totalvotes)

ggplot(AL, aes(x=year, y=vote_pct, colour = party)) +
  geom_point(size=1)+
  labs(x="year", y="vote_pct")+
  geom_line() +
  facet_wrap(~district, nrow = 3, scales = "free_x") +
  labs(title = "Voter turnout change across years in each district in Alabama", x = "year", y = "percentage of vote by party") +
  scale_colour_manual(values = c("#56B4E9", "#FF9999"),
                    guide = guide_legend(reverse = TRUE),
                    labels=c("dem_pct","rep_pct")) +
  theme(plot.title = element_text(hjust = 0.5)) 
```

![](election_analysis_files/figure-gfm/unnamed-chunk-6-1.png)<!-- -->

``` r
# District level within state, TEXAS 

TEXAS <- dplyr::filter(df, grepl('Texas', state))
TX <- dplyr::filter(TEXAS, grepl('^DEMOCRAT$|^REPUBLICAN$', party)) %>%
  mutate(vote_pct=candidatevotes/totalvotes)

ggplot(TX, aes(x=year, y=vote_pct, colour=party))+
  geom_point(size=0.5) +
  labs(x="year", y="vote_pct")+
  geom_line() +
  facet_wrap( ~ district) +
  labs(title = "Voter turnout change across years in each district in Texas", x = "year", y = "percentage of vote by party") + 
  scale_colour_manual(values = c("#56B4E9", "#FF9999"),
                    guide = guide_legend(reverse = TRUE),
                    labels=c("dem_pct","rep_pct")) +
  theme(plot.title = element_text(hjust = 0.5)) 
```

![](election_analysis_files/figure-gfm/unnamed-chunk-7-1.png)<!-- -->
