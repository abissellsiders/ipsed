#####
# init
#####
# remove all objects
rm(list=ls(all=TRUE))

# set working directory
wd = paste0("C:/Users/", Sys.info()["effective_user"], "/google_drive/research/datasets_international/world_inequality_dataset")
setwd(wd)

# load packages
library("data.table")
library("ggplot2")
library("hrbrthemes")
library("stringr")
library("scales")
library("readxl")

#####
# read data
#####
# load list of csvs
csv_list = list.files(pattern="WID_data_...csv")

wid = rbindlist(lapply(csv_list, fread))

# split percentile into lower bound and upper bound
matches = str_match(wid[["percentile"]], pattern = "^p([[:digit:].]*)p([[:digit:].]*)$")
cols_new = c("pct_lb", "pct_ub")
wid[, (cols_new) := data.table(matches[, 2:3])]
wid[, (cols_new) := lapply(.SD, as.numeric), .SDcols = cols_new]

# split variable into subvariables
# types = c("weal", "inc")
# pattern = paste0("^(.)(.*)((?:", paste0(types, collapse = ")|(?:"), "))([[:digit:].]*)(.)$")
pattern = paste0("^(.)(.{5})([[:digit:].]*)(.)$")
matches = str_match(wid[["variable"]], pattern = pattern)
cols_new = c("var_type", "concept", "age", "pop")
wid[, (cols_new) := data.table(matches[, 2:5])]

# 
wid[, pct_dif := pct_ub - pct_lb]
sub = wid[age == 992 & pop == "j" & var_type == "s" & concept == "ptinc", ]
sub = sub[((pct_dif == 10) | (pct_lb == 90 & pct_ub == 94) | (pct_lb == 95 & pct_ub == 98) | (pct_lb == 99 & pct_ub == 99.8) | (pct_lb == 99.9 & pct_ub == 100)), ]
unique(sub[["country"]])

comb_lbs = (990:998)/10
comb_ubs = (991:999)/10
View(sub[pct_lb %in% comb_lbs & pct_ub %in% comb_ubs & year == 1978, ])

View(sub[country == "FR" & year == 1978 & pct_dif < 11, ])

c("", )

pct_lbs = c( 0, 50, 90, 99  ,  99.9)
pct_ubs = c(50, 90, 99, 99.9, 100  )


View(sub[country == "CN" & year == 1978, ])

#####
# reformat data
#####
