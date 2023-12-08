#####
# init
#####
# remove all objects
rm(list=ls(all=TRUE))

# load packages
library("data.table")
library("stringr")

# set working directory
(wd = "C:/gdrive/rpackages/pesdint/data-raw/iraq_body_count")
setwd(wd)

#####
# read data
#####
# read incidents data
ibc = fread("ibc-incidents.csv")

# rename columns
setnames(ibc, str_replace_all(tolower(colnames(ibc)), c(" "="_")))

# recode date column
date_format = "%d %b %Y"
ibc[, date_start := as.Date(start_date, date_format)]
ibc[, date_end := as.Date(end_date, date_format)]

# date iraq, ukraine started and duration since then
date_iraq_start = as.Date("2003-03-20")
ibc[, days_since_start := date_end - date_iraq_start]

# #####
# # summarize by day (old method)
# #####
# # summarize by day
# ibc = ibc[, .(reported_min = sum(reported_minimum),
#               reported_max = sum(reported_maximum)), by = c("days_since_start")]
# setorderv(ibc, c("days_since_start"))
# ibc[, reported_max_cum := cumsum(reported_max)]
#
# # melt iraq data
# cols_keep = c("reported_max_cum", "days_since_start")
# ibc_melt = ibc[, cols_keep, with = FALSE]
# ibc_melt[, country := "Iraq"]
# setnames(ibc_melt, "reported_max_cum", "civilians_killed")


#####
# iraq: spread fatalities evenly over each multi-day event
#####
# empty data table
ibc_even = data.table(deaths = 0,
                      day = seq.Date(from=min(ibc[["date_start"]]),
                                     to=max(ibc[["date_start"]]),
                                     by="day"))

# for each event, split deaths over each day
for(i in 1:nrow(ibc)) {
  # select row
  row = ibc[i, ]

  # print row
  if (i %% 100 == 0) {print(i)}

  # calculate number of days
  date_start = row[["date_start"]]
  date_end = row[["date_end"]]
  date_diff = date_end - date_start
  days_n = as.numeric(date_diff) + 1

  # calculate deaths per day
  deaths_n = row[["reported_maximum"]]
  deaths_per_day = deaths_n / days_n

  # add deaths to those days
  ibc_even[day >= date_start & day <= date_end, deaths := deaths + deaths_per_day]
}

# calculate days since start
ibc_even[, days_since_start := day - date_iraq_start]

# calculate cumulative deaths
setorderv(ibc_even, c("days_since_start"))
ibc_even[, deaths_cumulative := cumsum(deaths)]
ibc_even[day >= date_iraq_start, deaths_cumulative_sincestart := cumsum(deaths)]

# rename cols
cols_keep = c("day", "days_since_start", "deaths", "deaths_cumulative")
setcolorder(ibc_even, cols_keep)

# add country name
ibc_even[, country := "Iraq"]

#####
# save data
#####
# rename dataset (doesn't use memory until acted upon)
iraq_body_count = ibc
usethis::use_data(iraq_body_count, overwrite = TRUE)

iraq_body_count_even = ibc_even
usethis::use_data(iraq_body_count_even, overwrite = TRUE)
