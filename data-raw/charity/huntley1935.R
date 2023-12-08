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
huntley = fread("huntley1935.csv")

# melt data
cols_id = c("year", "source_name", "source_loc", "place1", "place2", "notes", "type1", "type2", "group1", "unit")
cols_measure = colnames(huntley)[!(colnames(huntley) %in% cols_id)]
print(cols_measure)
mhuntley = melt(huntley, id.vars = cols_id, measure.vars = cols_measure,
                variable.name = "group2", value.name = "value")

# update unit
mhuntley[, value := value * 1000]
mhuntley[, unit := "dollars"]

#####
# save data
#####
# rename dataset (doesn't use memory until acted upon)
charity_huntley1935 = mhuntley
usethis::use_data(charity_huntley1935, overwrite = TRUE)
