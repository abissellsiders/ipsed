get_fipsed = function(countries, ...) {
  dt_list = list(...)
  # merge all data by code, name, year
  merge_codenameyear = function(...) {
    merge(..., by = c("country_code", "country_name", "year"), all = TRUE)
  }
  fipsed = Reduce(merge_codenameyear, dt_list)

  # add oecd column
  convert = setNames(!is.na(countries[["oecd"]]), countries[["master_long"]])
  fipsed[, oecd := convert[country_name]]
  # add continent column
  convert = setNames(countries[["continent"]], countries[["master_long"]])
  maddison[, continent := convert[country_name]]

  # # add NA rows for years 1 to 2018
  # for (country_var in unique(polity_dt[["country"]])) {
  #   years = c(1:2020)[!(1:2020 %in% polity_dt[country == country_var, ][["year"]])]
  #   dt = data.table(year = years, country = country_var)
  #   polity_dt = rbind(polity_dt, dt, fill=TRUE)
  # }
  # # reorder
  # maddison_dt = maddison_dt[order(country_name, year)]

  return(fipsed)
}


# # old:   # if arguments, merge given datasets; else merge all datasets
# if (...length() > 0) {
#   dt_list = list(...)
# } else {
#   maddison = get_maddison()
#   polity = get_polity()
#   wgi = get_wgi()
#   dt_list = list(maddison, polity, wgi)
# }
