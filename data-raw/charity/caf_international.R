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
caf_int = fread("caf_international.csv")

#####
# save data
#####
# rename dataset (doesn't use memory until acted upon)
charity_caf_international = caf_int
usethis::use_data(charity_caf_international, overwrite = TRUE)
