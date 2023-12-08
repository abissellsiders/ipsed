#####
# init
#####
# clear old data
rm(list=ls(all=TRUE))

# load packages
library("data.table")
library("sdlutils")
library("stringr")
library("readxl")

# set working directory
(wd = "C:/gdrive/rpackages/pesdint/data-raw/charity/wgi")
setwd(wd)

#####
# read data
#####
# csvs
csvs = list.files(pattern = "caf_wgi.*csv")

# helper function
read_caf = function(path) {
  dt = fread(path)
  year = str_replace_all(path, c(".*_([[:digit:]]{4})_.*"="\\1"))
  dt[, year := year]
}

# read and combine
wgi = rbindlist(lapply(csvs, read_caf), fill=TRUE)

#####
# clean data
#####
# remove columns
cols_del = c("del1", "del2", "overall_rank", "money_rank", "time_rank", "stranger_rank")
wgi[, (cols_del) := NULL]

# reorder columns
cols_keep = c("place1", "year", "overall_score", "money_score", "time_score", "stranger_score")
setcolorder(wgi, cols_keep)
cols_new = str_replace_all(cols_keep, c("_score"=""))
setnames(wgi, cols_keep, cols_new)

# convert to numeric
cols_num = colnames(wgi)[-1]
wgi[, (cols_num) := lapply(.SD, as.numeric), .SDcols = cols_num]

# adjust year and add notes
wgi[, year := year - 1] # report year leads data year by 1
wgi[, source_name := paste0("CAF World Giving Index ", year + 1)]
wgi[, source_loc := "Full Table"]

# convert percentiles to proportions
wgi[overall > 1, `:=`(overall = overall/100,
                      money = money/100,
                      time = time/100,
                      stranger = stranger/100)]

# remove utf characters from country names
wgi[, place1 := str_replace_all(place1, c("\n|'"=" ", " {2,}"=" "))]

# get number of appearances of country name
recode = c(".*Ivoire.*"="Ivoire",
           ".*Taiwan.*"="Taiwan",
           ".*Bolivia.*"="Bolivia",
           ".*Kinshasa.*"="Congo Kinshasa",
           ".*Macedonia.*"="Macedonia",
           ".*Brazzaville.*"="Congo Brazzaville",
           ".*Libya.*"="Libya",
           ".*Palestin.*"="Palestine",
           ".*United.*States.*America.*"="USA",
           ".*Venezuela.*"="Venezuela",
           ".*Gambia.*"="Gambia",
           ".*Dem.*Rep.*Congo.*"="Congo",
           ".*Iran.*"="Iran",
           ".*Lao.*Dem.*"="Laos",
           ".*Moldova.*"="Moldova",
           ".*Tanzania.*"="Tanzania",
           ".*Somaliland.*"="Somaliland",
           ".*Col.mbia.*"="Colombia",
           ".*Bosnia.*Herzegovina.*"="Bosnia and Herzegovina",
           ".*Central.*Afric.*Republic.*"="Central African Republic",
           ".*Nagorno.*Karabakh.*"="Nagorno-Karabakh")
wgi[, place1 := str_replace_all(place1, recode)]
x = table(wgi[["place1"]])
x[x < 6]

# todo use these for country regex unit tests

# add columns
wgi[, type1 := "charity"]
wgi[, unit := "percent of population"]

#####
# melt data
#####
cols_id = c("year", "place1", "source_name", "source_loc", "unit", "type1")
cols_measure = colnames(wgi)[!(colnames(wgi) %in% cols_id)]
print(cols_measure)
mwgi = melt(wgi, id.vars = cols_id, measure.vars = cols_measure,
           variable.name = "type2", value.name = "value")

# add notes
recode = c("overall"="simple mean of money, time, stranger",
           "money"='proportion of respondents answering yes to: "Have you done any of the following in the past month? Donated money to a charity?"',
           "time"='proportion of respondents answering yes to: "Have you done any of the following in the past month? Volunteered your time to an organisation?"',
           "stranger"='proportion of respondents answering yes to: "Have you done any of the following in the past month? Helped a stranger, or someone you didn\'t know who needed help."')
mwgi[, notes := recode[type2]]

#####
# save data
#####
# rename dataset (doesn't use memory until acted upon)
charity_wgi = mwgi
usethis::use_data(charity_wgi, overwrite = TRUE)
