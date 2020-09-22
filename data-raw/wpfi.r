#####
# 2009-1997
#####
urlFunc = function(year) {
  return(paste0("https://github.com/abissellsiders/ipsed/raw/master/data-raw/wpfi/wpfi_", year, ".csv"))
}
download_fread_csv = function(year) {
  # obtain url
  url = urlFunc(year)
  # download file
  path = tempfile()
  download.file(url, path, mode="wb")
  # read csv
  dt = fread(path)
  # standard column names
  colnames(dt) = c("wpfi_rank", "country_name", "wpfi_score")[1:dim(dt)[2]]
  # year
  dt[, year := year]
  # return
  return(dt)
}
list_09 = lapply(c(2002:2010, 2012:2015), download_fread_csv)