#####
# init
#####
# clear old data
rm(list=ls(all=TRUE))

# load packages
library("data.table")
library("sdlutils")
library("stringr")

# set working directory
(wd = "C:/gdrive/rpackages/pesdint/data-raw/inequality/world_inequality_database")
setwd(wd)

#####
# read data
#####
# read csv
wid = rbindlist(lapply(list.files(pattern = "WID_data.*.csv"), fread), fill = TRUE)
meta = rbindlist(lapply(list.files(pattern = "WID_metadata.*.csv"), fread), fill = TRUE)
wid_countries = fread("WID_countries.csv")

# separate subconcepts
cols_new = c("type", "owner", "concept", "DEL1", "DEL2")
wid[, (cols_new) := as.data.table(str_match(variable, "(.{1})(.{1})(.{4})(.{3})(.{1})")[,2:(length(cols_new)+1)])]
cols_del = c("DEL1", "DEL2")
wid[, (cols_del) := NULL]
wid[, variable := str_sub(variable, end = -5L)]
meta[, variable := str_sub(variable, end = -5L)]

# merge wid data with meta data
cols_merge = c("country", "variable", "age", "pop")
wid = merge(wid, meta, by = cols_merge, all.x = TRUE)
cols_rm = c("simpledes", "technicaldes", "longtype", "longpop", "longage", "source", "method", "extrapolation", "data_points", "unit")
wid[, (cols_rm) := NULL]

# searching for variables
(x = unique(wid[str_detect(shortname, "Net public")]))
(x = unique(wid[str_detect(concept, "weal")]))
unique(x[["owner"]])

# create percentile columns
cols_pct = c("pct_1", "pct_2")
wid[, (cols_pct) := data.table(str_match(percentile, "p(.*)p(.*)")[,2:3])]
wid[, (cols_pct) := lapply(.SD, as.numeric), .SDcols = cols_pct]
wid[, pct_diff := pct_2 - pct_1]

# recalculate useful proportions
wid[, share_1pct := type == "s" & pct_diff == 1]
breaks_ = c(-1, 50, 90, 98, 101)
labels_ = c("p0p50", "p51p90", "p91p98", "p99p100")
wid[share_1pct == TRUE, pct_cut := cut(pct_1, breaks = breaks_, labels = labels_, right = TRUE)]
cols_by = c("variable", "age", "pop", "country", "year", "pct_cut")
wid[share_1pct == TRUE, value_sum := sum(value), by = cols_by]
# get first calculation by cut percentile
wid[, variable_i := 1:nrow(.SD), by = c("variable", "country", "year", "pct_cut")]
wid[, variable_1st := variable_i == 1]

wid[varname == "rptinc", ]

# merge in country names
wid = merge(wid, wid_countries, by.x = "country", by.y = "alpha2")

unique(wid[varname == "rptinc" & country != "US", ][["variable"]])

#####
# graph data NEW
#####
library("ggplot2")
library("scales")

#####
# graph income shares
#####
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
gdt = wid[owner == "p" & concept == "tinc" & pct_cut %in% pct_subset & variable_1st == TRUE, ]
gdt[, pct_cut := factor(pct_cut, levels = pct_subset, labels = pct_labels)]

# need to construct a better custom calculation -- relying on 1% jumps does not work
wid[country == "DE" & year == 1934 & type == "s" & concept == "tinc", ]
gdt = wid[country == "DE" & year %in% 1900:1950 & type == "s" & concept == "tinc", ]

gdt = gdt[percentile == "p99p100", ]
ggplot(gdt, aes(x = year, y = value, fill = pct_cut)) + theme_shares +
  labs(title = "Shares of pre-tax national income: Top 1%, Germany") +
  geom_vline(xintercept = 1933)

ggplot(gdt[country == "RU", ], aes(x = year, y = sum, fill = pct_cut)) + theme_shares +
  labs(title = "Shares of pre-tax national income: Soviet Union")

ggplot(gdt[country %in% c("RU", "VN") & year %between% c(1980, 2015), ], aes(x = year, y = sum, fill = pct_cut)) + theme_shares +
  facet_grid(~ country)
labs(title = "Shares of pre-tax national income: Vietnam")


#####
# graph wealth
#####
gdt = wid[type == "m" & owner %in% c("g", "p") & concept == "weal", ]
cols_by = c("age", "pop", "type", "concept", "country", "year")
gdt[, total := sum(value), by = cols_by]
gdt[, prop := value / total]
gdt[, owner_lab := c("g"="public", "p"="private")[owner]]

f1 = list(facet_wrap(~ countryname, scales = "free_y", ncol = 3),
          scale_x_continuous(limits = c(1950, 2020), expand = c(0,0), oob = censor),
          theme_sdl(),
          theme(axis.ticks.x = element_blank(),
                axis.ticks.y = element_blank()),
          scale_fill_brewer(palette = "Reds"),
          labs(fill = "Owner",
               caption = c("@socdoneleft", "Sources:\nWorld Inequality Database, wid.world")))

gdt[country == "NO" & year == 2018, ]
ggplot(gdt, aes(x = year, y = value, fill = owner_lab)) + f1 +
  geom_bar(stat = "identity", position = "stack", width = 1, color = NA) +
  labs(title = "Net wealth owned by country and by sector (inflation-adjusted local currency)")
ggsave_sdl("wealth_sector_abs.png")
ggplot(gdt, aes(x = year, y = prop, fill = owner_lab)) + f1 +
  geom_area(position = "stack") +
  scale_y_continuous(limits = c(0, 1), expand = c(0, 0), oob = squish, labels = percent) +
  labs(title = "Net wealth owned by country and by sector (proportion)")
ggsave_sdl("wealth_sector_prop.png")

# TODO: combine shweal (share household wealth) with mpweal (total private wealth) to break down private wealth by class
gdt = wid[type %in% c("m", "s") & concept == "weal" & country == "US", ]
gdt[["type"]]

gdt = wid[type == "m" & concept == "weal", ]
gdt = wid[type == "s" & concept == "weal" & pct_diff == 1, ]
