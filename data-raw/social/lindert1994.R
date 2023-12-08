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
lindert = fread("lindert1994.csv", header = TRUE)

# melt data
cols_id = c("place1", "type1", "group1", "source_name", "source_loc", "notes")
cols_measure = paste0(10*(188:193))
mlindert = melt(lindert, id.vars = cols_id, measure.vars = cols_measure,
                value.name = "orig", variable.name = "year")

# recode notes
mlindert[, value := as.numeric(orig)]
cols_new = c("value", "notes")
recode = c("ns"="not a sovereign state or state in chaos",
           "+"="public spending existed but amount is unknown",
           "(+)"="public spending existed but key independent variable is unknown",
           "zero"="public spending was zero and key independent variable is unknown")
mlindert[orig %in% names(recode), (cols_new) := list(NA, recode[orig])]
mlindert[orig == "zero", value := 0]

# recode indirect estimates
mlindert[str_detect(orig, "i"), (cols_new) := list(as.numeric(str_replace_all(orig, c("i"=""))), "indirect estimate")]

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
social_lindert1994 = mlindert
usethis::use_data(social_lindert1994, overwrite = TRUE)
