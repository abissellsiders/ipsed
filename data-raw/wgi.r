#####
# documentation
#####
# xlsx files were prepared manually
# [1] downloaded pdfs of the 2010-19 reports (n=10)
# [2] subset pdfs to "Full Table" pages (in filename "##-##")
# [3] use Adobe Acrobat DC to export to XLSX
# [4] clean XLSX of repeat/garbage rows
# [5] R code below

#####
# init
#####
require("data.table")
require("readxl")

get_wgi = function() {
  #####
  # read data
  #####
  wgi_wd = paste0("C:/Users/", Sys.info()["effective_user"], "/google_drive/research/_packages/ipsed/data-raw/wgi")
  setwd(wgi_wd)

  # 2010
  # read + standard column names
  dt_2010 = data.table(read_xlsx("caf_wgi_2010_34-38.xlsx",
                                 skip = 1,
                                 col_names = c("country_name", "wgi_overall_rank", "wgi_overall", "wgi_money", "wgi_time", "wgi_stranger", "wellbeing")))
  # wellbeing index not in other years; drop column
  dt_2010[, wellbeing := NULL]
  # add year
  dt_2010[, year := 2010]

  # 2011
  # read + standard column names
  dt_2011 = data.table(read_xlsx("caf_wgi_2011_42-47.xlsx",
                                 skip = 1,
                                 col_names = c("country_name", "wgi_overall_rank", "wgi_overall", "wgi_money", "wgi_time", "wgi_stranger", "wgi_2010_rank", "wgi_2010_score")))
  # 2010 score & rank unnecessary; drop columns
  dt_2011[, c("wgi_2010_rank", "wgi_2010_score") := NULL]
  # Asterisk* indicates country hasn't been updated since 2010; drop rows
  dt_2011 = dt_2011[!grep("\\*", country_name), ]
  # add year
  dt_2011[, year := 2011]

  # 2012
  # read + standard column names
  dt_2012 = data.table(read_xlsx("caf_wgi_2012_62-66.xlsx",
                                 skip = 1,
                                 col_names = c("country_name", "wgi_overall_rank", "wgi_overall", "wgi_money", "wgi_money_rank", "wgi_time", "wgi_time_rank", "wgi_stranger", "wgi_stranger_rank")))
  # add year
  dt_2012[, year := 2012]

  # 2013
  # read + standard column names
  dt_2013 = data.table(read_xlsx("caf_wgi_2013_28-30.xlsx",
                                 skip = 1,
                                 col_names = c("country_name", "wgi_overall_rank", "wgi_overall", "wgi_money_rank", "wgi_money", "wgi_time_rank", "wgi_time", "wgi_stranger_rank", "wgi_stranger")))
  # add year
  dt_2013[, year := 2013]

  # 2014
  # read + standard column names
  dt_2014 = data.table(read_xlsx("caf_wgi_2014_33-35.xlsx",
                                 skip = 1,
                                 col_names = c("country_name", "wgi_overall_rank", "wgi_overall", "wgi_money_rank", "wgi_money", "wgi_time_rank", "wgi_time", "wgi_stranger_rank", "wgi_stranger")))
  # add year
  dt_2014[, year := 2014]

  # 2015
  # read + standard column names
  dt_2015 = data.table(read_xlsx("caf_wgi_2015_17-18.xlsx",
                                 skip = 1,
                                 col_names = c("country_name", "wgi_overall_rank", "wgi_overall", "wgi_money_rank", "wgi_money", "wgi_time_rank", "wgi_time", "wgi_stranger_rank", "wgi_stranger")))
  # add year
  dt_2015[, year := 2015]

  # 2016
  # read + standard column names
  dt_2016 = data.table(read_xlsx("caf_wgi_2016_36-38.xlsx",
                                 skip = 1,
                                 col_names = c("country_name", "wgi_overall_rank", "wgi_overall", "wgi_money_rank", "wgi_money", "wgi_time_rank", "wgi_time", "wgi_stranger_rank", "wgi_stranger")))
  # add year
  dt_2016[, year := 2016]

  # 2017
  # read + standard column names
  dt_2017 = data.table(read_xlsx("caf_wgi_2017_35-37.xlsx",
                                 skip = 1,
                                 col_names = c("country_name", "wgi_overall_rank", "wgi_overall", "wgi_money_rank", "wgi_money", "wgi_time_rank", "wgi_time", "wgi_stranger_rank", "wgi_stranger")))
  # add year
  dt_2017[, year := 2017]

  # 2018
  # read + standard column names
  dt_2018 = data.table(read_xlsx("caf_wgi_2018_32-34.xlsx",
                                 skip = 1,
                                 col_names = c("country_name", "wgi_overall_rank", "wgi_overall", "wgi_money_rank", "wgi_money", "wgi_time_rank", "wgi_time", "wgi_stranger_rank", "wgi_stranger")))
  # Lithuania is missing money value; drop row
  dt_2018 = dt_2018[country_name != "Lithuania", ]
  # coerce wgi_money to numeric
  dt_2018[, wgi_money := as.numeric(wgi_money)]
  # add year
  dt_2018[, year := 2018]

  # 2019
  # read + standard column names
  dt_2019 = data.table(read_xlsx("caf_wgi_2019_23-25.xlsx",
                                 skip = 1,
                                 col_names = c("country_name", "wgi_overall_rank", "wgi_overall", "wgi_money_rank", "wgi_money", "wgi_time_rank", "wgi_time", "wgi_stranger_rank", "wgi_stranger")))
  # add year
  dt_2019[, year := 2019]

  #####
  # merge data
  #####
  dt_list = list(dt_2010, dt_2011, dt_2012, dt_2013, dt_2014, dt_2015, dt_2016, dt_2017, dt_2018, dt_2019)
  wgi_dt = rbindlist(dt_list, fill=TRUE)

  #####
  # clean data
  #####
  # convert percentiles to proportions
  wgi_dt[wgi_overall > 1, `:=`(wgi_overall = wgi_overall/100,
                               wgi_money = wgi_money/100,
                               wgi_time = wgi_time/100,
                               wgi_stranger = wgi_stranger/100)]
  # remove utf characters from country names
  wgi_dt[, country_name := gsub("\\n", " ", country_name)]
  wgi_dt[, country_name := gsub("'", "'", country_name)]
  # countries = ipsed::countries
  # create country codes
  short_convert = setNames(countries[["master_short"]], tolower(countries[["wgi_country"]]))
  wgi_dt[, country_code := short_convert[tolower(country_name)]]
  # convert country names
  long_convert = setNames(countries[["master_long"]], tolower(countries[["wgi_country"]]))
  wgi_dt[, country_name := long_convert[tolower(country_name)]]
  # reorder columns
  setcolorder(wgi_dt, c("country_code", "country_name", "year", "wgi_overall", "wgi_overall_rank", "wgi_money", "wgi_money_rank", "wgi_time", "wgi_time_rank", "wgi_stranger", "wgi_stranger_rank"))
  # return
  return(wgi_dt)
}
