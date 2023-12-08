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
lindert = fread("lindert_oecd_1960-2019.csv", header = TRUE)

# melt data
cols_id = c("place1", "type1", "group1", "source_name", "source_loc")
cols_measure = paste0(1960:2019)
mlindert = melt(lindert, id.vars = cols_id, measure.vars = cols_measure,
             value.name = "value", variable.name = "year")

# additional columns
mlindert[, unit := "percent of GDP"]

# percent to proportion
mlindert[, value := value / 100]

#####
# save data
#####
# rename dataset (doesn't use memory until acted upon)
social_lindert_1960_2019 = mlindert
usethis::use_data(social_lindert_1960_2019, overwrite = TRUE)
