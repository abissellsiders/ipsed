#####
# init
#####
# clear old data
rm(list=ls(all=TRUE))

# load packages
library("data.table")
library("sdlutils")
library("ggrepel")
library("stringr")
library("googlesheets4")

# set working directory
(wd = "C:/gdrive/rpackages/pesdint/data-raw/death_counts")
setwd(wd)

#####
# helper functions
#####
read_gsheet_if_older = function(path, sheet, ss, mins = 5) {
  goog = TRUE
  d = as.difftime(mins, units = "mins")
  if (file.exists(path)) {
    if ((Sys.time() - file.mtime(path)) < d) {
      goog = FALSE
    }
  }
  if (goog) {
    dt = read_sheet(sheet = sheet, ss = ss)
    dt = data.table(dt)
    fwrite(dt, path)
  } else {
    print("reading local csv")
    dt = fread(path)
  }
  return(dt)
}
# path = "death_counts.csv"
# sheet = "death_counts"
# ss = "1B_MnzcJ9M1OgPpCle4NhLMFEHHuCfs-D6yvDY8pxwnk"
# mins = 5

rep_maker_interpolate = function(subs, y, Best_ = NA) {
  # create initial rep data
  reps = subs[rep(1, length(y) - nrow(subs)), ]
  # years which should exist
  y_inv = y[!(y %in% subs[["year1"]])]
  # delete cols
  cols_del = c("date1", "date2", "Index")
  reps[, (cols_del) := NULL]
  # year cols
  cols_year = c("year1", "year2")
  reps[, (cols_year) := y_inv]
  # source update
  reps[, source_loc := "death_counts.R"]
  # best
  reps[, Best := Best_]
  # interpolate values
  vals = as.data.table(approx(x = subs[["year1"]], y = subs[["value"]], xout = y))
  reps[, value := vals[x %in% y_inv, y]]
  # return
  return(reps)
}

#####
# read data
#####
# read gsheet
dc = read_gsheet_if_older("death_counts.csv", "death_counts", "1B_MnzcJ9M1OgPpCle4NhLMFEHHuCfs-D6yvDY8pxwnk")

# easy viewing
cols_view = c("source_name", "group1", "group2", "type1", "type2", "type3", "details", "date1", "date2", "value")
# dc[, cols_view, with = FALSE]

#####
# munge data
#####
# remove excess year column
cols_del = c("year")
dc[, (cols_del) := NULL]

# reformat values
cols_numeric = c("value")
dc[, (cols_numeric) := lapply(.SD, as.numeric), .SDcols = cols_numeric]

# reformat dates
cols_date = c("date1", "date2")
dc[, (cols_date) := lapply(.SD, as.Date, format = "%Y %b %d"), .SDcols = cols_date]
cols_year = paste0("year", 1:2)
dc[, (cols_year) := lapply(.SD, year), .SDcols = cols_date]

#####
#
# calculate new data
#
#####

#####
# us age-specific mortality: simple average 15-34
#####
dc[, Index := 1:nrow(.SD)]

# subset
ag = dc[str_detect(group2, "yos") & type2 == "Rate" & place == "US", ]
ag[, Index := NULL]

# calculate
ag[, value := mean(value), by = year1]
ag[, group2 := "15-34yos"]
ag[, details := paste0("Crude death rate of ", group2)]
ag[, source_loc := "death_counts.R"]

# rejoin
ag[year1 == 1930, ]
ag = unique(ag)
nrow(ag)
dc = rbind(dc, ag)

#####
# identify best data: us executions
#####
dc[, Index := 1:nrow(.SD)]

# subset
ex = dc[type3 == "Abs" & details == "Executions" & place == "US", ]
ex[, Best := 0]

# dpic
s_name = "DPIC Execution Database"
s = ex[source_name == s_name, ][["year1"]]
s_ran = range(s)
ex[year1 %between% s_ran & source_name == s_name & Best == 0, Best := 1]
ex[year1 %between% s_ran & Best == 0, Best := -1]

# epsy
s_name = "Epsy and Smykla 2016"
s = ex[source_name == s_name, ][["year1"]]
s_ran = range(s)
ex[year1 %between% s_ran & source_name == s_name & Best == 0, Best := 1]
ex[year1 %between% s_ran & Best == 0, Best := -1]

# qa
# sort(table(ex[Best == 1, ][["year1"]]))
y = 1900:2000
y[!(y %in% ex[["year1"]])]
y[!(y %in% ex[Best == 1, ][["year1"]])]

# subset overall data
ind_best = ex[Best == 1, ][["Index"]]
dc[(Index %in% ind_best), Best := 1]

#####
# interpolate early us prisoner deaths
#####
dc[, Index := 1:nrow(.SD)]

# subset
subs = dc[source_name == "Cahalan and Parsons 1986" & type1 == "Death" & type3 == "Adj" & place == "US", ]
y = seq(min(subs[["year1"]]), max(subs[["year1"]]))
# subset overall data
ind_best = subs[["Index"]]
dc[(Index %in% ind_best), Best := 1]
# create interpolated rows
reps = rep_maker_interpolate(subs = subs, y = y, Best_ = 1)
# rejoin
nrow(reps)
dc = rbind(dc, reps, fill = TRUE)

#####
# interpolate early total us prisoner population
#####
dc[, Index := 1:nrow(.SD)]

# subset
subs = dc[source_name == "Cahalan and Parsons 1986" & type1 == "Pop" & place == "US", ]
y = seq(min(subs[["year1"]]), max(subs[["year1"]]))
# subset overall data
ind_best = subs[["Index"]]
dc[(Index %in% ind_best), Best := 1]
# create interpolated rows
reps1 = rep_maker_interpolate(subs = subs[group2 == "All", ], y = y, Best_ = 1)
nrow(reps1)
reps2 = rep_maker_interpolate(subs = subs[group2 == "Federal", ], y = y, Best_ = 0)
nrow(reps2)
reps3 = rep_maker_interpolate(subs = subs[group2 == "State", ], y = y, Best_ = 0)
nrow(reps3)
# rejoin
dc = rbindlist(list(dc, reps1, reps2, reps3), fill = TRUE)

#####
# extrapolate later total us prisoner population from sentenced population
#####
# list of possible sources
sources_poss = unique(dc[group1 == "Sentenced prisoners", ][["source_name"]])
subs1 = dc[source_name %in% sources_poss & group2 == "All", with = FALSE]

#####
# identify best prisoner population
#####

#####
# extrapolate overall early us prison death rates
#####


#####
#
# dcast data
#
#####
# set formula
f = as.formula("year1 + group1 + group2 + type3 + source_name + Best ~ type1 + type2")

# remove index
dc[, Index := NULL]

#####
# test if duplicates
#####
# dcast
mdc = dcast(data = dc, formula = f, value.var = "value", fun.aggregate = length)
dups = mdc[(Death_Count > 1) | (Death_Rate > 1) | (Pop_Count > 1), ]
nrow(dups)
# # fixed #1
# dc[year == 2016 & group1 == "Sentenced prisoners" & group2 == "All" & source_name == "ICPSR 38555", ]
# # fixed #2
# dc[year == 1926 & group1 == "Prisoners" & group2 == "All" & source_name == "ICPSR 08912", ]

#####
# examine dcast
#####
# merge values and best
mdc = dcast(data = dc, formula = f, value.var = "value")
