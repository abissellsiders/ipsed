library("data.table")
library("fredr")

fredr_prep = function(series_id, ...) {
  dt = data.table(fredr(
    series_id = series_id,
    ... = ...
  ))
  dt[, year := year(date)]
  dt[, month := month(date)]
  dt[, quarter := ceiling(month/3)]
  dt[, day_mn := mday(date)]
  dt[, day_yr := yday(date)]
  setnames(dt, "value", tolower(series_id))
  cols_remove = c("series_id", "realtime_start", "realtime_end")
  dt[, (cols_remove) := NULL]
  return(dt)
}

fredr_prep_mult = function(series_ids, ...) {
  dts = lapply(series_ids, fredr_prep)
  dt = mergelist(dts, by = c("date", "year", "quarter", "month", "day_mn", "day_yr"), all = TRUE)
  return(dt)
}

fredr_prep_mult_all = function(series_ids,
                               observation_start = as.Date("1900-01-01"),
                               observation_end = as.Date("2030-01-01"),
                               frequency = "a",
                               units = "",
                               ...) {
  dt = fredr_prep_mult(series_ids = series_ids,
                       observation_start = as.Date("1900-01-01"),
                       observation_end = as.Date("2030-01-01"),
                       frequency = "a",
                       units = "",
                       ... = ...)
  return(dt)
}
