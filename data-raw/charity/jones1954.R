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
jones = fread("jones1954.csv")

#####
# save data
#####
# rename dataset (doesn't use memory until acted upon)
charity_jones1954 = jones
usethis::use_data(charity_jones1954, overwrite = TRUE)
