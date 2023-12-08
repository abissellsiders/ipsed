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
(wd = "C:/gdrive/rpackages/pesdint/data-raw/mutual")
setwd(wd)

#####
# read data
#####
# read csv
statfrat = fread("statistics_fraternal.csv", header = TRUE)

# melt data
cols_id = c("source_name", "source_loc", "year", "place1", "place2", "notes", "type1", "group1", "group2", "unit")
cols_measure = colnames(statfrat)[!(colnames(statfrat) %in% cols_id)]
print(cols_measure)
mstatfrat = melt(statfrat, id.vars = cols_id, measure.vars = cols_measure,
                variable.name = "type2", value.name = "value")

#####
# save data
#####
# rename dataset (doesn't use memory until acted upon)
mutual_statistics_fraternal = mstatfrat
usethis::use_data(mutual_statistics_fraternal, overwrite = TRUE)
