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
(wd = "C:/gdrive/rpackages/pesdint/data-raw/social")
setwd(wd)

#####
# read data
#####
oecd = fread("oecd1985_wide.csv", header = TRUE)

# melt data
cols_id = c("place1", "type1", "group1", "source_name", "source_loc")
cols_measure = paste0(1960:1981)
moecd = melt(oecd, id.vars = cols_id, measure.vars = cols_measure,
             value.name = "value", variable.name = "year")
moecd[, value := as.numeric(value)]

#####
# save data
#####
# rename dataset (doesn't use memory until acted upon)
social_oecd1985 = moecd
usethis::use_data(social_oecd1985, overwrite = TRUE)
