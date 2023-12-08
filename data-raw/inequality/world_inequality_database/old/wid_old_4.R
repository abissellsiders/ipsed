#####
# init
#####
# clear old data
rm(list=ls(all=TRUE))

# load packages
library("data.table")
library("sdlutils")
library("stringr")
library("ggplot2")

# set working directory
(wd = "C:/gdrive/rpackages/pesdint/data-raw/world_inequality_database")
setwd(wd)

#####
# read data
#####
# read csv
wid = rbindlist(lapply(list.files(pattern = "WID_data.*.csv"), fread), fill = TRUE)
wid_countries = fread("WID_countries.csv")

# subset data
vars_subset = c("rcainc" = "posttax_disposable_income",
                "rdiinc" = "posttax_national_income",
                "rhweal" = "net_personal_wealth",
                "rptinc" = "pretax_national_income",
                "scainc" = "posttax_disposable_income",
                "sdiinc" = "posttax_national_income",
                "sfiinc" = "fiscal_income",
                "shweal" = "net_personal_wealth",
                "sptinc" = "pretax_national_income")
vars_regex = paste0(names(vars_subset), collapse = "|")
wid = wid[str_which(variable, vars_regex), ]

# create shorter variable column
wid[, varname := str_sub(variable, start = 1L, end = -5L)]

# create percentile columns
cols_pct = c("pct1", "pct2")
wid[, (cols_pct) := data.table(str_match(percentile, "p(.*)p(.*)")[,2:3])]
wid[, (cols_pct) := lapply(.SD, as.numeric), .SDcols = cols_pct]
wid[, pctD := pct2 - pct1]

# calculate useful proportions
vars_subset_share = vars_subset[str_sub(names(vars_subset), 1, 1) == "s"]
wid[, share_1pct := varname %in% names(vars_subset_share) & pctD == 1]
wid[share_1pct == TRUE, pct_cut := cut(pct1, c(-1, 50, 90, 98, 101), labels = c("p0p50", "p51p90", "p91p98", "p99p100"), right = TRUE)]
wid[share_1pct == TRUE, sum := sum(value), by = c("varname", "age", "pop", "country", "year", "pct_cut")]

# get first calculation by cut percentile
wid[, variable_i := 1:.N, by = c("variable", "country", "year", "pct_cut")]
wid[, variable_1st := variable_i == 1]

wid[varname == "rptinc", ]

# merge in country names
wid = merge(wid, wid_countries, by.x = "country", by.y = "alpha2")

unique(wid[varname == "rptinc" & country != "US", ][["variable"]])

#####
# graph data
#####
t_ratio = list(scale_x_continuous(expand = c(0.05, 0.05)),
               scale_y_continuous(expand = c(0, 0), limits = c(0, 20), oob = scales::squish))

ggplot(wid[variable == "rptinc992j" & country != "SU" & year %between% c(1980, 2021), ], aes(x = year, y = value)) + t_ratio +
  geom_area() + geom_line() + geom_point() +
  facet_wrap(. ~ titlename) +
  theme_sdl() +
  labs(x = NULL, y = "Ratio of pre-tax income: Top 10% / Bottom 50%",
       title = "Pre-tax income ratio",
       subtitle = "How many times more the top 10% makes than the bottom 50%",
       caption = c("@socdoneleft", "Source:\nWorld Inequality Database"))

ggplot(wid[variable == "rptinc992j" & country == "SU", ], aes(x = year, y = value)) + t_ratio +
  geom_area() + geom_line() + geom_point() +
  facet_wrap(. ~ titlename) +
  theme_sdl() +
  labs(x = NULL, y = "Ratio of pre-tax income: Top 10% / Bottom 50%",
       title = "Pre-tax income ratio",
       subtitle = "How many times more the top 10% makes than the bottom 50%",
       caption = c("@socdoneleft", "Source:\nWorld Inequality Database"))


pct_subset = c("p0p50", "p50p90", "p90p100")
gdt = wid[variable == "sptinc992j" & country == "RU" & percentile %in% pct_subset, ]
ggplot(gdt, aes(x = year, y = value, fill = percentile)) +
  geom_area(position = "stack", stat = "identity") +
  theme_sdl()
gdt[year == 1905, ]

theme_shares = list(geom_area(position = "stack"),
                    geom_point(position = "stack", color = "black"),
                    theme_sdl(),
                    scale_y_continuous(expand = c(0, 0), labels = scales::percent),
                    scale_fill_brewer(palette = "Reds"),
                    labs(title = "Shares of pre-tax national income: Soviet Union",
                         x = NULL,
                         y = "share of pre-tax national income",
                         fill = "Income Group",
                         caption = c("@socdoneleft", "Source:\nWorld Inequality Database")))

pct_subset = c("p99p100", "p91p98", "p51p90", "p0p50")
pct_labels = c("Top 1% (p99-p100)", "Next 9% (p90-p99)", "Middle 40% (p50-p90)", "Bottom 50% (p0-p50)")
gdt = wid[variable == "sptinc992j" & pct_cut %in% pct_subset & variable_1st == TRUE, ]
gdt[, pct_cut := factor(pct_cut, levels = pct_subset, labels = pct_labels)]

ggplot(gdt[country == "RU", ], aes(x = year, y = sum, fill = pct_cut)) + theme_shares +
  labs(title = "Shares of pre-tax national income: Soviet Union")

ggplot(gdt[country %in% c("RU", "VN") & year %between% c(1980, 2015), ], aes(x = year, y = sum, fill = pct_cut)) + theme_shares +
  facet_grid(~ country)
  labs(title = "Shares of pre-tax national income: Vietnam")

