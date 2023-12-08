#####
# init
#####
# clear old data
rm(list=ls(all=TRUE))

# load packages
library("data.table")
library("sdlutils")
library("stringr")

# set working directory
(wd = "C:/gdrive/rpackages/pesdint/data-raw/countries")
setwd(wd)

#####
# read countries data
#####
countries = fread("countries.csv")

#####
# save data
#####
# rename dataset (doesn't use memory until acted upon)
countries = countries
usethis::use_data(countries, overwrite = TRUE)
