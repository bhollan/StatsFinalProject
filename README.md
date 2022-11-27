# StatsFinalProject
PPOL 560 Final Project for Group 1


To obtain data directly from the Census, you'll need to add your API key.
Request one from the census, (it only takes a few seconds).
Then run:

``` r
install.packages("keyring")
keyring::key_set("census_api_key")
```

and a modal will pop up in RStudio and you can paste in your API key.

Data Sources:
  census.gov