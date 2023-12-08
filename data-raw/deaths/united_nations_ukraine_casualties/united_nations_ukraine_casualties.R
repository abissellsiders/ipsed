#####
# init
#####
# remove all objects
rm(list=ls(all=TRUE))

# load packages
library("data.table")
library("stringr")

# set working directory
(wd = "C:/gdrive/rpackages/pesdint/data-raw/deaths/united_nations_ukraine_casualties")
setwd(wd)

#####
# read and clean data
#####
# read csv
ukrcas = fread("united_nations_ukraine_casualties.csv")

# recode str to date
date_format = "%d %b %Y"
ukrcas = ukrcas[type1 == "occurred", ]
ukrcas[, date_start := as.Date(date_start, date_format)]
ukrcas[, date_end := as.Date(date_end, date_format)]

# days since start of conflict
date_ukraine_start = as.Date("2022-02-24")
ukrcas[, days_since_start := date_end - date_ukraine_start]

#####
# spread fatalities evenly over each multi-day event
#####
# reset ukrcas start dates
ukrcas2 = copy(ukrcas)
ukrcas2[, deaths := civilians_killed]
ukrcas2[, postinvasion := date_start == date_ukraine_start]
ukrcas2[postinvasion == TRUE, deaths_shift := shift(deaths, n = 1)]
ukrcas2[postinvasion == TRUE, deaths_delta := deaths - deaths_shift]
ukrcas2[postinvasion == TRUE, deaths := deaths_delta]
ukrcas2[is.na(deaths), deaths := civilians_killed]
ukrcas2[postinvasion == TRUE, date_end_shift := shift(date_end, n = 1)]
ukrcas2[postinvasion == TRUE, date_start := date_end_shift]
ukrcas2[is.na(date_start), date_start := date_ukraine_start]

# empty data table
ukrcas_even = data.table(deaths = 0,
                         day = seq.Date(from=min(ukrcas[["date_start"]]),
                                        to=max(ukrcas[["date_end"]]),
                                        by="day"))

# for each event, split deaths over each day
for(i in 1:nrow(ukrcas2)) {
  # select row
  row = ukrcas2[i, ]

  # print row
  if (i %% 100 == 0) {print(i)}

  # calculate number of days
  date_start = row[["date_start"]]
  date_end = row[["date_end"]]
  date_diff = abs(date_end - date_start)
  days_n = as.numeric(date_diff) + 1

  # calculate deaths per day
  deaths_n = row[["deaths"]]
  deaths_per_day = deaths_n / days_n

  # add deaths to those days
  ukrcas_even[day >= date_start & day <= date_end, deaths := deaths + deaths_per_day]
}

# calculate days since start
ukrcas_even[, days_since_start := day - date_ukraine_start]

# calculate cumulative deaths
setorderv(ukrcas_even, c("days_since_start"))
ukrcas_even[, deaths_cumulative := cumsum(deaths)]
ukrcas_even[day >= date_ukraine_start, deaths_cumulative_sincestart := cumsum(deaths)]

# rename cols
cols_keep = c("day", "days_since_start", "deaths", "deaths_cumulative")
setcolorder(ukrcas_even, cols_keep)

# add country name
ukrcas_even[, country := "Ukraine"]

#####
# save data
#####
# rename dataset (doesn't use memory until acted upon)
united_nations_ukraine_casualties = ukrcas
usethis::use_data(united_nations_ukraine_casualties, overwrite = TRUE)

united_nations_ukraine_casualties_even = ukrcas_even
usethis::use_data(united_nations_ukraine_casualties_even, overwrite = TRUE)
