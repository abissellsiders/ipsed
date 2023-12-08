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
(wd = "C:/gdrive/rpackages/pesdint/data-raw/charity")
setwd(wd)

#####
# read data
#####
# read csv
geddes = fread("geddes1937.csv")

#####
# save data
#####
# rename dataset (doesn't use memory until acted upon)
charity_geddes1937 = geddes
usethis::use_data(charity_geddes1937, overwrite = TRUE)
