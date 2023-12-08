library(data.table)
library(wid)
library(ggplot2)
library(readxl)

conv = read_excel("C:/Users/desk/google_drive/datafiles/common/countries.xlsx")

pcts = list("p0p50"="0-50%",
            "p50p90"="50-90%",
            "p90p99"="90-99%",
            "p99p100"="99%-100%")

percentage_labeller = function(x) {
  x = unique(x)
  r = sapply(x, function(x){sub("^p([[:digit:].]*)p([[:digit:].]*)$", "\\1%-\\2%", x)})
  return(r)
}

# ussr & eastern bloc
dt <- download_wid(
  indicators = c("sptinc"), # ?wid_series_type , ?wid_concepts
  areas = c("CZ", "FR", "HR", "IN", "RU", "US"), # ?wid_area_codes
  years = c(1880:2020),
  perc = c("p0p50", "p50p90", "p90p99", "p99p100"),
  ages = c(992), # ?wid_age_codes
  pop = c("j"), # ?wid_population_codes
  metadata = FALSE,
  verbose = FALSE
)
dt = data.table(dt)
ptt = "p([^p]*)p([^p]*)"
dt[, pct := .01 * (as.numeric(gsub(ptt, "\\2", percentile)) - as.numeric(gsub(ptt, "\\1", percentile)))]
pct_labeller = function(variable, value) {return(pcts[value])}
dt[, country_full := conv[["clio_infra"]][which(conv[["wid_world"]] == country)]]
ggplot(dt, aes(x = year, y = value, color = country)) +
  geom_line(size = 1) + geom_point() +
  facet_grid(percentile ~ ., labeller = pct_labeller) +
  scale_color_brewer(palette = "Paired", labeller = country_labeller) +
  labs(y = "Share of pre-tax national income")
ggplot(dt, aes(x = year, y = value/pct, color = country)) +
  geom_line(size = 1) + geom_point() +
  facet_grid(percentile ~ ., scales = 'free_y') +
  scale_color_brewer(palette = "Paired")

# nazis socialist
dt <- download_wid(
  indicators = c("sfiinc"), # ?wid_series_type , ?wid_concepts
  areas = c("US", "DE"), # ?wid_area_codes
  years = c(1900:1945),
  perc = c("p90p95", "p95p99", "p99p100"),
  ages = c(992), # ?wid_age_codes
  pop = c("t", "j", "i"), # ?wid_population_codes
  metadata = FALSE,
  verbose = FALSE
)
pcts = percentage_labeller(dt[["percentile"]])
dt = data.table(dt)
ptt = "p([^p]*)p([^p]*)"
dt[, pct := .01 * (as.numeric(gsub(ptt, "\\2", percentile)) - as.numeric(gsub(ptt, "\\1", percentile)))]
pct_labeller = function(variable, value) {return(pcts[value])}
ggplot(dt, aes(x = year, y = value, color = country)) +
  geom_line(size = 1) + geom_point() +
  facet_grid(percentile ~ ., labeller = as_labeller(pcts)) +
  scale_color_brewer(palette = "Paired") +
  labs(y = "Share of fiscal income") +
  geom_vline(xintercept = 1929) +
  geom_vline(xintercept = 1933)

