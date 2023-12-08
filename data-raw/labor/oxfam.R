#####
# init
#####
# clear old data
rm(list=ls(all=TRUE))

# load packages
library(data.table)
library(sdlutils)
library(stringr)
library(readxl)
library(zoo)

# set working directory
(wd = "C:/gdrive/rpackages/pesdint/data-raw/labor")
(wd = "/Volumes/GoogleDrive/My Drive/rpackages/pesdint/data-raw/labor")
setwd(wd)

# helper function
clean_oxbsw = function(dt_) {
  # rename colnames
  setnames(dt_, tolower)
  setnames_regex(dt_, c(" "="_", "\\(.*\\)|:"="", "\\."="", ","="__", "_$"=""))
  setnames_regex(dt_, c("__"="_"))

  # overall score
  cols_sd = c("wage_dimension_score", "worker_protection_dimension_score", "right_to_organize_dimension_score")
  dt_[, overall_index_score := rowMeans(.SD), .SDcols = cols_sd]

  # prepend all columns
  cols_old = colnames(dt_)[-(1:2)]
  cols_new = str_replace_all(colnames(dt_)[-(1:2)], c("^"="bsw_"))
  setnames(dt_, cols_old, cols_new)

  # return
  return(dt_)
}

#####
# read data
#####
# read xlsx
sheets = c("Wage Dimension", "Worker Protection Dimension", "Right to Organize")
skips = c(1, 2, 3)

# 2020
read20 = function(...) { read_excel_multiheader(type = "merge", path = "oxfam2020.xlsx", n_max = 52, ...) }
cols_by = c("State", "Abbrev.")
l = lapply(1:3, function(i){read20(sheet = sheets[i], skip = skips[i])})
oxbsw20 = data.table(mergelist(l, by = cols_by))
oxbsw20 = clean_oxbsw(oxbsw20)
oxbsw20[, year := 2020]

# 2018
read18 = function(...) { read_excel_multiheader(type = "merge", path = "oxfam2018.xlsx", n_max = 51, ...) }
cols_by = c("State", "Abbreviation")
l = lapply(1:3, function(i){read18(sheet = sheets[i], skip = skips[i])})
oxbsw18 = data.table(mergelist(l, by = cols_by))
oxbsw18 = clean_oxbsw(oxbsw18)
oxbsw18[, year := 2018]

# merge
oxbsw = rbind(oxbsw20, oxbsw18, fill=TRUE)

# qa
oxbsw[["bsw_overall_index_score"]]
oxbsw[["bsw_1_wage_ratio_indicator__wage_ratio"]]
oxbsw[["bsw_1_right_to_work_indicator__status_quo_right_to_work_law"]]
oxbsw[["bsw_4_paid_sick_leave_indicator__law_in_place"]]

#####
# save data
#####
# rename dataset (doesn't use memory until acted upon)
labor_oxfam_best_state_work = oxbsw
usethis::use_data(labor_oxfam_best_state_work, overwrite = TRUE)
