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
andrews = fread("andrews1950.csv")

# calculate total
tot = andrews[, .(value = sum(value),
                  group1 = "total",
                  group2 = "total",
                  unit = "dollars"), by = c("year", "place1","type1", "type2", "source_name", "source_loc")]
andrews = rbind(andrews, tot, fill = TRUE)

# value to numeric
# TODO consider standardizing this
andrews[, value := as.numeric(value)]

#####
# save data
#####
# rename dataset (doesn't use memory until acted upon)
charity_andrews1950 = andrews
usethis::use_data(charity_andrews1950, overwrite = TRUE)
