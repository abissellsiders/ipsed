require("readxl")
require("data.table")

get_countries = function() {
  url = "https://github.com/abissellsiders/ipsed/raw/master/data-raw/countries/countries.csv"
  countries = fread(url, encoding = "UTF-8")
  return(countries)
}