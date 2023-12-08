#####
# init
#####
# clear old data
rm(list=ls(all=TRUE))

# load packages
library(data.table)
library(sdlutils)
library(stringr)
library(readxl)

# set working directory
(wd = "C:/gdrive/rpackages/pesdint/data-raw/eli")
(wd = "/Volumes/GoogleDrive/My Drive/rpackages/pesdint/data-raw/eli")
setwd(wd)

#####
# read data
#####
# read excel
eli = read_excel("economic_leftism_index.xlsx", sheet = "values")

#####
# save data
#####
# rename dataset (doesn't use memory until acted upon)
eli_economic_leftism_index = eli
usethis::use_data(eli_economic_leftism_index, overwrite = TRUE)
