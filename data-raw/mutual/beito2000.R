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
beito = fread("beito2000.csv", header = TRUE)

# melt data
cols_id = c("source_name", "source_loc", "place1", "place2", "notes", "type1", "type2", "group1",  "group2", "unit")
cols_measure = colnames(beito)[!(colnames(beito) %in% cols_id)]
print(cols_measure)
mbeito = melt(beito, id.vars = cols_id, measure.vars = cols_measure,
                variable.name = "year", value.name = "value")

# update unit
mbeito[, value := value * 1e6]
mbeito[, unit := "dollars"]

#####
# save data
#####
# rename dataset (doesn't use memory until acted upon)
mutual_beito2000 = mbeito
usethis::use_data(mutual_beito2000, overwrite = TRUE)
