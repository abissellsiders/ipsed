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
hsus = fread("hsus1970_H398-411.csv")

# change unit
hsus[, value := value * 1e6]
hsus[, unit := "dollars"]

#####
# save data
#####
# rename dataset (doesn't use memory until acted upon)
charity_hsus1970 = hsus
usethis::use_data(charity_hsus1970, overwrite = TRUE)
