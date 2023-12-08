#####
# init
#####
# clear old data
rm(list=ls(all=TRUE))

# load packages
library("data.table")
library("readxl")
library("sdlutils")
library("stringr")
library("lubridate")

# set working directory
(wd_lab = "C:/gdrive/rpackages/pesdint/data-raw/labor")
(wd_data = "C:/gdrive/rpackages/pesdint/data-raw/labor/bls_work_stoppages")

#####
# read and munge annual data
#####
setwd(wd_data)

# read data
cols_annual = c("year", "stoppages_beginning", "stoppages_effect", "workers_beginning", "workers_effect", "days_idle", "percent_total_working_time")
ann = read_excel("annual-listing.xlsx", col_types = "text", col_names = cols_annual, skip = 3)
ann = data.table(ann)

# max row
ann = ann[1:(min(str_which(ann[["year"]], "\\[")) - 1), ]

# year
ann[, year := str_replace_all(year, c("\\r|\\n"=""))]

# back to numeric
ann[, (cols_annual) := lapply(.SD, as.numeric), .SDcols = cols_annual]

#####
# read and munge monthly data
#####
setwd(wd_data)

# read data
cols_monthly = c("organizations_involved", "states", "areas", "ownership", "industry_code", "union_name", "union_acronym", "union_local", "bargaining_unit", "work_stoppage_date_beginning", "work_stoppage_date_ending", "number_workers", "days_idle_cumulative", "note")
mon = read_excel("monthly-listing.xlsx", col_types = "text", col_names = cols_monthly, skip = 2)
mon = data.table(mon)

# max row
mon = mon[1:(min(str_which(mon[["organizations_involved"]], "Footnotes")) - 1), ]

# back to numeric
cols_date = c("work_stoppage_date_beginning", "work_stoppage_date_ending")
cols_num = c("number_workers", "days_idle_cumulative")
cols_tonum = c(cols_num, cols_date)
mon[, (cols_tonum) := lapply(.SD, as.numeric), .SDcols = cols_tonum]

# dates
mon[, (cols_date) := lapply(.SD, as.Date, origin = "1899-12-30"), .SDcols = cols_date]

#####
# read most recent year data
#####
setwd(wd_data)

# read data
cols_monthly = c("organizations_involved", "states", "areas", "ownership", "industry_code", "union_name", "union_acronym", "union_local", "work_stoppage_date_beginning", "work_stoppage_date_ending", "number_workers", "number_workdays", "days_idle_cumulative", "note")
mon23 = read_excel("work-stoppages-2023.xlsx", sheet = "Table_1", col_types = "text", col_names = cols_monthly, skip = 2)
mon23 = data.table(mon23)

# max row
mon23 = mon23[1:(min(str_which(mon23[["organizations_involved"]], "Footnotes")) - 1), ]

# back to numeric
cols_date = c("work_stoppage_date_beginning", "work_stoppage_date_ending")
cols_num = c("number_workers", "days_idle_cumulative")
cols_tonum = c(cols_num, cols_date)
mon23[, (cols_tonum) := lapply(.SD, as.numeric), .SDcols = cols_tonum]

# dates
mon23[, (cols_date) := lapply(.SD, as.Date, origin = "1899-12-30"), .SDcols = cols_date]

#####
# merge monthly data
#####
# add
mon23a = mon23[1, ]
mon23a[, number_workers := 350000]
mon23a[, number_workers := 350000]
mon23a[, work_stoppage_date_beginning := as.Date("2023/08/01")]
mon23a[, work_stoppage_date_ending := as.Date("2023/09/01")]

# merge
mon = rbindlist(list(mon, mon23, mon23a), use.names = TRUE, fill = TRUE)

#####
# split monthly data by day
#####
# iterate numeric columns over each day
# from = min(mon[["work_stoppage_date_beginning"]])
from = as.Date("1993/01/01")
# to = max(mon[["work_stoppage_date_ending"]])
# to = today() %m+% months(1)
to = as.Date("2023/09/01")
# empty data table
mon_even = data.table(day = seq.Date(from=from, to=to, by="day"))
mon_even[, (cols_num) := 0]

# for each event, add stoppages to each day
# todo make this into two helper functions
cols_num = c("number_workers")
for(i in 1:nrow(mon)) {
  # select row
  row = mon[i, ]

  # print row
  if (i %% 1000 == 0) {print(i)}
  date_start = row[["work_stoppage_date_beginning"]]
  date_end = row[["work_stoppage_date_ending"]]

  # what to do with na dates -- make this an option
  if (is.na(date_end)) {
    date_end = to
  }

  # add deaths to those days
  for (col in cols_num) {
    value = row[[col]]
    mon_even[day >= date_start & day <= date_end, (col) := get(col) + value]
    if (i == 641) {
      print("test")
      print(value)
      print(row)
      print(tail(mon_even))
    }
  }
}

# annual
# # iterate numeric columns over each day
# # from = min(mon[["work_stoppage_date_beginning"]])
# from = as.Date("1993/01/01")
# # to = max(mon[["work_stoppage_date_ending"]])
# # to = today() %m+% months(1)
# to = as.Date("2024/09/01")
# # empty data table
# mon_even = data.table(year_ = seq(from=year(from), to=year(to)))
# mon_even[, (cols_num) := 0]
#
# # for each event, add stoppages to each day
# # todo make this into two helper functions
# cols_num = c("number_workers")
# for(i in 1:nrow(mon)) {
#   # select row
#   row = mon[i, ]
#
#   # print row
#   if (i %% 1000 == 0) {print(i)}
#   date_start = row[["work_stoppage_date_beginning"]]
#   date_end = row[["work_stoppage_date_ending"]]
#
#   # what to do with na dates -- make this an option
#   if (is.na(date_end)) {
#     date_end = to
#   }
#
#   # add deaths to those days
#   for (col in cols_num) {
#     value = row[[col]]
#     mon_even[year_ >= year(date_start) & year_ <= year(date_end), (col) := get(col) + value]
#   }
# }

#####
# graph data
#####
library("ggplot2")
library("scales")
cols_roll = paste0(cols_num, "_roll31")
mon_even[, (cols_roll) := lapply(.SD, function(x){frollmean(x = x, n = 180, align = "center")}), .SDcols = cols_num]
cols_smooth = paste0(cols_num, "_smooth")
mon_even[, (cols_smooth) := lapply(.SD, function(x){ksmooth(x = 1:length(x), y = x, kernel = "normal", bandwidth = 90)$y}), .SDcols = cols_num]

mon_even[, year_ := year(day)]
mon_even[, (number_workers = sum(number_workers)), by = c("year_")]
ggplot(mon_even, aes(x = day, y = number_workers)) +
  geom_area(stat = "identity", color = NA) +
  geom_line(mapping = aes(y = number_workers_smooth), color = "white") +
  scale_x_date(expand = c(0.01, 0), date_breaks = "years", date_labels = "%Y", limits = as.Date(c("1992/01/01", "2023/12/31"))) +
  scale_y_continuous(expand = c(0, 0), limits = c(0, 4e5), breaks = seq(0, 4e5, 5e4), labels = comma) +
  theme_sdl() +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 0.5)) +
  labs(x = NULL,
       y = "number of workers in work stoppages",
       title = "Number of workers in striking workers, by day, USA, 1993-2023",
       subtitle = "the UPS Teamsters strike, starting August 1st, will be the largest since Reagan\nBLS data only includes strikes of 1,000 or more workers",
       caption = c("@socdoneleft", "Sources:\nBureau of Labor Statistics, Detailed Monthly Listing, 2023\nBureau of Labor Statistics, Detailed Monthly Listing, 1993-Present\nGraph assumes that Teamsters strike lasts 1 month"))
