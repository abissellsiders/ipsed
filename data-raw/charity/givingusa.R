#####
# init
#####
# remove all objects
rm(list=ls(all=TRUE))

# load packages
library("data.table")
library("stringr")
library("sdlutils")
library("readxl")

# set working directory
(wd = "C:/gdrive/rpackages/pesdint/data-raw/charity")
setwd(wd)

#####
# read and clean data
#####
# helper function
read_gu = function(path, sheet) {
  # read xlsx
  dt = data.table(read_excel(path, sheet))

  # drop columns
  cols_drop = str_subset(colnames(dt), "(?:Pct chg)|(?:Percent change)|Check")
  dt[, (cols_drop) := NULL]

  # remove extra characters
  setnames(dt, str_replace_all(tolower(colnames(dt)), c(","="", " |-"="_", "_to"="")))

  # add source/recipient column
  dt[, type1 := "charity"]
  dt[, type2 := sheet]

  # melt data
  cols_id = c("year", "source_name", "source_loc", "notes", "type1", "type2")
  cols_measure = colnames(dt)[!(colnames(dt) %in% cols_id)]
  print(cols_measure)
  mdt = melt(dt, id.vars = cols_id, measure.vars = cols_measure,
             variable.name = "group1", value.name = "value")

  # return
  return(mdt)
}

# read and merge data
gu = rbindlist(lapply(c("source", "recipient"), function(x){read_gu(path = "givingusa.xlsx", x)}))

#####
# munge data
#####
# set units correctly
gu[, value := value * 1e9]
gu[, unit := "dollars"]

# select most recent data
gu[, source_year := as.numeric(str_replace_all(source_name, ".*([[:digit:]]{4}).*", "\\1"))]
gu[, latest := (max(source_year) == source_year), by = c("year")]
gu_latest = gu[latest == TRUE, ]
gu_latest[, source_name := "Giving USA"]
gu = rbind(gu, gu_latest)

# remove columns
cols_remove = c("latest", "source_year")
gu[, (cols_remove) := NULL]

# add columns
gu[, place1 := "USA"]

#####
# save data
#####
# rename dataset (doesn't use memory until acted upon)
charity_givingusa = gu
usethis::use_data(charity_givingusa, overwrite = TRUE)
