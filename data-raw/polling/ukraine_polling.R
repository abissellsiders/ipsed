#####
# init
#####
# remove all objects
rm(list=ls(all=TRUE))

# load packages
library("data.table")
library("stringr")

# set working directory
(wd = "C:/gdrive/rpackages/pesdint/data-raw/ukraine_polling")
setwd(wd)

#####
# read data
#####
# read csv
ukr = fread("ukraine_polling.csv")

#####
# save data
#####
# rename dataset (doesn't use memory until acted upon)
ukraine_polling = ukr
usethis::use_data(ukraine_polling, overwrite = TRUE)
