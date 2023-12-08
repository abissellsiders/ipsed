# todo

# download and fread file
downloadFread = function(year, colnames_) {
  # obtain url
  url = urlFunc(year)
  # download file
  path = tempfile()
  download.file(url, path, mode="wb")
  # read csv
  dt = fread(path)
  # standard column names
  print(c(year, length(colnames(dt))))
  colnames(dt) = colnames_[1:dim(dt)[2]]
  # year
  dt[, year := year]
  # return
  return(dt)
}

# no wpfi was conducted in 2011
colnames_15 = c("wpfi_rank", "country_name", "wpfi_score", "dup1")
list_15 = lapply(c(2002:2010, 2012:2015), downloadFread, colnames_ = colnames_15)
# wpfi changed column format and added a 2nd score column in 2016
colnames_20 = c("country_code", "wpfi_rank", "dup1", "country_name", "dup2", "wpfi_score_situation", "wpfi_score_abuse", "wpfi_score", "dup3", "dup4", "dup5", "dup6", "dup7", "dup8", "dup9")
list_20 = lapply(c(2016:2020), downloadFread, colnames_ = colnames_20)

#####
# combine data
#####
# combine datasets
wpfi = rbindlist(c(list_15, list_20), fill=TRUE)

# subset columns
wpfi = wpfi[, c("country_name", "year", "wpfi_rank", "wpfi_score", "wpfi_score_situation", "wpfi_score_abuse")]

#####
# clean data
#####
# from 2002-2012, ties were reported with rank "-"
repeatDownwardFunc = function(vec, ignore) {
  vec_new = vector(mode = typeof(vec[1]))
  val_prev = ""
  for (val in vec) {
    if (!(val %in% ignore)) {
      if (val != val_prev) {
        val_prev = val
      }
    }
    vec_new = c(vec_new, val_prev)
  }
  return(vec_new)
}
wpfi[year %in% 2002:2012, wpfi_rank := repeatDownwardFunc(wpfi[year %in% 2002:2012, ][["wpfi_rank"]], "-")]

# convert string to numeric
cols = c("wpfi_score", "wpfi_score_situation", "wpfi_score_abuse")
wpfi[, (cols) := lapply(.SD, function(x){gsub(",", ".", x)}), .SDcols = cols]
cols = c("wpfi_rank", "wpfi_score", "wpfi_score_situation", "wpfi_score_abuse")
wpfi[, (cols) := lapply(.SD, as.numeric), .SDcols = cols]

# character conversions
country_names = wpfi[["country_name"]]
country_names = gsub("&", "and", country_names)
country_names = gsub("´|’", "'", country_names)
country_names = gsub("\\.|,|\\(|\\)", "", country_names)
country_names = tolower(country_names)
country_names = gsub(" the | of | of the ", " ", country_names)
country_names = gsub(" {2,}", " ", country_names)
country_names = gsub("^the | of$| the$", "", country_names)

# assign
wpfi[, country_name := country_names]

sort(unique(wpfi[["country_name"]]))

# cã'te dâ€™ivoire
# câ„¢te d'ivoire
# cote d'ivoire
wpfi[grep("voire", country_name), country_name := "cote d'ivoire"]

grep("voire", unique(wpfi[["country_name"]]), value = TRUE)


#####
# save data
#####
# rename dataset (doesn't use memory until acted upon)
social_oecd1985 = oecd
usethis::use_data(social_oecd1985, overwrite = TRUE)
