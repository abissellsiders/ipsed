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
lindert = fread("lindert2021_how_was_life_vol_ii.csv", header = TRUE)

# melt data
cols_id = c("place1", "type1", "group1", "source_name", "source_loc")
cols_measure = paste0(10*(182:201))
mlindert = melt(lindert, id.vars = cols_id, measure.vars = cols_measure,
                value.name = "orig", variable.name = "year")

# recode notes
mlindert[, value := as.numeric(orig)]
recode = c("0?"="probably zero or below 0.1%",
           "?"="no estimate yet, though true value > 0")
mlindert[orig %in% names(recode), notes := recode[orig]]
recode = c("0?"=0,
           "?"=NA)
mlindert[orig %in% names(recode), value := recode[orig]]

# remove columns
cols_remove = c("orig")
mlindert[, (cols_remove) := NULL]

# additional columns
mlindert[, unit := "percent of GDP"]

# percent to proportion
mlindert[, value := value / 100]

#####
# save data
#####
# rename dataset (doesn't use memory until acted upon)
social_lindert2021_how_was_life_vol_ii = mlindert
usethis::use_data(social_lindert2021_how_was_life_vol_ii, overwrite = TRUE)
