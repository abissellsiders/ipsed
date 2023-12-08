#####
# init
#####
# clear old data
rm(list=ls(all=TRUE))

# set working directory
(wd = "C:/gdrive/rpackages/pesdint/vignettes/")
setwd(wd)

# load packages
library("data.table")
library("ggplot2")
library("ggrepel")
library("gridExtra")
library("shadowtext")
library("stringr")
library("pesdint")
library("sdlutils")

#####
# load data
#####
maddison = income_maddison[!is.na(pop), ]

#####
# one country
#####
datalist = list(country = "United Kingdom", xlim = c(1800, 2020), ylim = NULL, xintercepts = NULL)
datalist = list(country = "Canada", xlim = c(1860, 2020), ylim = NULL, xintercepts = NULL)
datalist = list(country = "United States", xlim = c(1800, 2020), ylim = NULL, xintercepts = NULL)
datalist = list(country = "Sweden", xlim = c(1800, 2020), ylim = list(NULL, c(-.1,.1)), xintercepts = NULL)
datalist = list(country = "Japan", xlim = c(1850, 2020), ylim = list(NULL, c(-.15,.15)), xintercepts = NULL)
datalist = list(country = "Italy", xlim = c(1800, 2020), ylim = NULL, xintercepts = NULL)
datalist = list(country = "Iraq", xlim = c(1950, 2020), ylim = NULL, xintercepts = c(1990, 2003))
datalist = list(country = "Libya", xlim = c(1950, 2020), ylim = NULL, xintercepts = c(2011))
datalist = list(country = "Tunisia", xlim = c(1950, 2020), ylim = NULL, xintercepts = c(2011))
datalist = list(country = "Hungary", xlim = c(1880, 2020), ylim = NULL, xintercepts = c(1945, 1990))
datalist = list(country = "Soviet Union", xlim = c(1880, 2020), ylim = NULL, xintercepts = c(1917,1991))
datalist = list(country = "Brazil", xlim = c(1880, 2020), ylim = NULL, xintercepts = NULL)
datalist = list(country = "Cuba", xlim = c(1920, 2020), ylim = NULL, xintercepts = c(1959))
datalist = list(country = "^China$", xlim = c(1950, 2020), ylim = NULL, xintercepts = c(1949))
datalist = list(country = "Chile", xlim = c(1950, 2020), ylim = list(NULL, c(-.1,.1)), xintercepts = c(1971, 1973, 1990))
datalist = list(country = "South Africa", xlim = c(1940, 2020), ylim = list(NULL, c(-.1,.1)), xintercepts = c(1990, 1994))
datalist = list(country = "Republic of Korea", xlim = c(1950, 2020), ylim = list(NULL, c(-.1, .15)), xintercepts = c(1953, 1961, 1972, 1981, 1988)) # civil war, end of first republic (to parliament), end of second republic (to military coup), end of third republic (to martial law), end of fourth republic (to military coup), end of fifth republic (to democracy)
datalist = list(country = "D.P.R. of Korea", xlim = c(1950, 2020), ylim = list(c(0, 5000), c(-.1, .15)), xintercepts = c(1953))
datalist = list(country = "Australia", xlim = c(1940, 2020), ylim = NULL, xintercepts = c(1990, 1994))
datalist = list(country = "Brazil", xlim = c(1800, 2020), ylim = NULL, xintercepts = NULL)
datalist = list(country = "Argentina", xlim = c(1800, 2020), ylim = list(c(0, 25000), c(-.25, .25)), xintercepts = NULL)
datalist = list(country = "Yugoslavia", xlim = c(1880, 2020), ylim = list(c(0, 20000), c(-.25, .25)), xintercepts = c(1945,1991))
datalist = list(country = "Vietnam", xlim = c(1900, 2020), ylim = list(c(0, 10000), c(-.25, .25)), xintercepts = c(1955,1975,1986))
datalist = list(country = "China", xlim = c(1900, 2020), ylim = list(c(0, 10000), c(-.25, .25)), xintercepts = c(1927,1949,1978))
datalist = list(country = "Taiwan", xlim = c(1900, 2020), ylim = list(c(0, 10000), c(-.25, .25)), xintercepts = c(1927,1949,1978))
datalist = list(country = "Ukraine", xlim = c(1900, 2020), ylim = list(c(0, 20000), c(-.25, .25)), xintercepts = c(1945,1991))
datalist = list(country = "Bolivia", xlim = c(1980, 2020), ylim = list(c(0, 20000), c(-.25, .25)), xintercepts = c(2006))

g1 = ggplot(maddison[grep(datalist$country, country_name), ], aes(x = year, group = country_name)) +
  geom_point(aes(y = gdppc), color = "gray60") +
  geom_line(aes(y = gdppc), color = "gray60") +
  geom_line(aes(y = gdppc_sma_5), color = "red") +
  coord_cartesian(xlim = datalist$xlim, ylim = datalist$ylim[[1]]) +
  geom_vline(xintercept = c(0, datalist$xintercepts)) +
  theme_minimal() +
  labs(y = "real GDP per capita",
       title = paste0(c("real GDP per capita, annual (gray), 5-year average (red)\n",
                        datalist$country,
                        " ",
                        paste0(datalist$xlim, collapse = "-"),
                        ", Maddison 2018 data"),
                      collapse = ""))
g2 = ggplot(maddison[grep(datalist$country, country_name), ], aes(x = year, group = country_name)) +
  geom_point(aes(y = gdppc_delta), color = "gray60") +
  geom_line(aes(y = gdppc_delta), color = "gray60") +
  geom_line(aes(y = gdppc_delta_sma_5), color = "red") +
  coord_cartesian(xlim = datalist$xlim, ylim = datalist$ylim[[2]]) +
  geom_hline(yintercept = 0) +
  geom_vline(xintercept = c(0, datalist$xintercepts)) +
  theme_minimal() +
  labs(y = "real GDP per capita growth",j
       title = paste0(c("real GDP per capita growth, annual (gray), 5-year average (red)\n",
                        datalist$country,
                        " ",
                        paste0(datalist$xlim, collapse = "-"),
                        ", Maddison 2018 data"),
                      collapse = ""))
grid.arrange(g1, g2, ncol=1)

#####
# graphing average growth of multiple countries
#####
datalist = list(country_name = "South Africa|Greece|Portugal|Spain", xlim = c(1940, 2020), ylim = list(NULL, c(-.1,.1)), xintercepts = c(1990, 1994))
datalist = list(country_name = "Soviet Union|United States|United Kingdom|^Germany$|Italy", xlim = c(1920, 1945), ylim = list(c(0, 17500), c(.25, -.25)), xintercepts = c(1917,1991))
datalist = list(country_name = "Former USSR|Yugoslavia|Albania|Poland|Czechoslovakia|Hungary|Romania|Bulgaria", xlim = c(1950, 1991), ylim = list(c(0, 17500), c(-.05, .05)), xintercepts = c(1917, 1940, 1945, 1950, 1968, 1980, 1991))
datalist = list(country_name = "China|Vietnam|Korea North|Laos")
datalist = list(country_name = "Sweden|United States|United Kingdom|Germany|France|Italy", xlim = c(1920, 2020), ylim = list(c(0, 50000), c(.1, -.1)), xintercepts = NULL)
datalist = list(country_name = "United States|United Kingdom", xlim = c(1850, 1900), ylim = list(c(0, 17500), c(.12, -.12)), xintercepts = NULL)
datalist = list(country_name = "Nigeria|Ethiopia|Congo-Kinshasa|South Africa|Tanzania|Kenya|Uganda|Algeria|Sudan|Morocco|Mozambique|Ghana", xlim = c(1960, 2020), ylim = list(c(0, 17500), c(.25, -.25)), xintercepts = NULL)
datalist = list(country_name = "China|Japan|Korea North|Korea South|Taiwan", xlim = c(1955, 2020), ylim = list(c(0, 40000), c(-.25, .25)), xintercepts = NULL)
datalist = list(country_name = "Iran|Turkmenistan|Uzbekistan|Kazakhstan|Kyrgystan|Tajikistan|Afghanistan|Pakistan|China|India", xlim = c(1990, 2014), ylim = list(NULL, NULL), xintercepts = c(0,1990,2001,2014,2021,2050))

gdt = maddison_project_gdp[grep(datalist$country_name, country_name), ]
gdt[, gdppc_delta_sma_5 := gdppc_delta_sma_5/10000]
gdt[, year_cut := cut(year, datalist$xintercepts, dig.lab = 4)]
hlines = gdt[, .(mean = mean(gdppc_delta_sma_5, na.rm = TRUE)), by = c("year_cut", "country_name")]
hlines[, `:=`(year1 = as.numeric(substr(year_cut, 2, 5)),
              year2 = as.numeric(substr(year_cut, 7, 10)))]
setorderv(hlines, c("country_name"))
hlines[, group := .GRP, by = c("country_name")]
hlines[, yearx := year1 + (year2 - year1) * (group) / (max(group) + 1)]
hlines[, label := paste0(country_name, ": ", floor(mean * 1000) / 10, "%")]
gdt[!is.na(gdppc_growth_sma_5), ][["gdppc_growth_sma_5"]]
ggplot(gdt, aes(x = year, y = gdppc_delta_sma_5, group = country_name, color = country_name)) +
  geom_hline(yintercept = 0, color = "white") +
  geom_vline(xintercept = c(0, datalist$xintercepts), color = "white") +
  geom_segment(data = hlines, aes(x = year1, xend = year2, y = mean, yend = mean)) +
  # geom_text_repel(data = hlines, aes(x = yearavg, y = mean * 1.05, label = country_name)) +
  geom_point() + geom_line() +
  geom_shadowtext(data = hlines, aes(x = yearx, y = mean, label = label), show.legend = FALSE) +
  theme_sdl() +
  scale_x_continuous(limits = datalist$xlim) +
  scale_y_continuous(limits = datalist$ylim[[2]], labels = scales::percent_format(accuracy = 1), oob = scales::oob_keep) +
  labs(y = "real GDP per person growth",
       title = "Real GDP per person growth, 5-year averages",
       subtitle = paste0("Countries: ", gsub("\\|", ", ", datalist$country_name)),
       caption = c("@socdoneleft", "Source: Maddison Project Database 2018")) +
  theme(plot.caption = element_text(hjust=c(1, 0)), panel.grid.minor = element_blank())

#####
# soviet union with good intra-stalin period labels
#####
gdt = income_maddison[str_which(country_name, "Former USSR"), ]

xvec = as.Date(c("7 November 1917", "21 March 1921", "21 January 1924", "1 October 1928", "1 May 1931", "1 July 1933", "1 August 1936", "1 March 1938", "22 June 1941"), format = "%d %B %Y")
xvec = year(xvec) + yday(xvec)/365
xoffset = -0.4
yvec = 5500
lvec = c("1917: civil war starts",
         "1921: most fighting over, NEP starts",
         "1924: Lenin dies, Stalin starts rise",
         "1928: NEP ends, Great Turn begins",
         "1931: Famine begins, kulaks deported",
         "1933: Famine ends, Great Turn moderated",
         "1937: Great Purge begins",
         "1938: Great Purge ends",
         "1941: Nazi Germany invades the Soviet Union")

ggplot(gdt, aes(x = year, group = country_name, y = gdppc)) +
  geom_point(color = "gray60") +
  geom_line(color = "gray60") +
  geom_labelled_vline(xvec = xvec, yvec = yvec, labs = lvec, xoffset = xoffset) +
  scale_y_continuous(limits = c(0, 8000), expand = c(0,0)) +
  scale_x_continuous(limits = c(1913, 1946), expand = c(0,0)) +
  theme_sdl() +
  labs(title = "Real GDP per person in the Soviet Union, 1913-1946",
       subtitle = "from 1917 to 1940, real economic growth only occurred during Lenin's NEP and moderation of Stalin's Great Turn",
       caption = c("@socdoneleft", "Sources:\nIncome: Maddison Project Database 2020"),
       y = "real GDP per person",
       x = NULL)
ggsave_sdl("soviet_income_stalin.png")

#####
# graphing ratio between countries
#####
# Soviet Union|United Kingdom|France|Germany|Italy|Spain|Portugal
datalist = list(compare = "United States", countries = "Sweden|Norway|Denmark|Finland", xlim = c(1880, 2020), ylim = c(NULL, NULL), xintercepts = NULL)
datalist = list(compare = "United States", countries = "Brazil|Argentina|Chile|Uruguay", xlim = c(1880, 2020), ylim = c(NULL, NULL), xintercepts = c(1970,1973,1991))
datalist = list(compare = "South Africa", countries = "Spain|Portugal|Greece", xlim = c(1950, 2020), ylim = c(NULL, NULL), xintercepts = NULL)
datalist = list(compare = "Republic of Korea", countries = "D.P.R. of Korea", xlim = c(1950, 2020), ylim = c(NULL, NULL), xintercepts = NULL)
datalist = list(compare = "Argentina", countries = "Brazil", xlim = c(1900, 2020), ylim = c(NULL, NULL), xintercepts = NULL)
datalist = list(compare = "Soviet Union", countries = "Yugoslavia|Bulgaria|Romania|Hungary|Slovakia|Czechia|Poland", xlim = c(1945, 2000), ylim = c(NULL, NULL), xintercepts = c(1917,1921,1940,1945,1990))
datalist = list(compare = "Soviet Union", countries = "Yugoslavia", xlim = c(1945, 2000), ylim = c(NULL, NULL), xintercepts = c(1917,1921,1940,1945,1990))

ratio_dt = copy(maddison)[year %between% datalist$xlim, ]
regx = paste0(c(datalist$compare, datalist$countries), collapse = "|")
ratio_dt = ratio_dt[str_detect(country_name, regx),]
ratio_dt[, gdppc_max := max(gdppc * (country_name == datalist$compare), na.rm = TRUE), by = "year"]
ratio_dt = ratio_dt[gdppc_max > 0, ]
ratio_dt[, gdppc_ratio := gdppc/gdppc_max]
ggplot(ratio_dt[country_name != datalist$compare, ], aes(x = year, group = country_name, color = country_name)) +
  geom_point(aes(y = gdppc_ratio)) + geom_line(aes(y = gdppc_ratio)) +
  geom_smooth(aes(y = gdppc_ratio), alpha = 0.25) +
  coord_cartesian(xlim = datalist$xlim, ylim = datalist$ylim[1]) +
  geom_hline(yintercept = 1) +
  geom_vline(xintercept = c(0, datalist$xintercepts)) +
  theme_sdl() +
  labs(title = paste0("real GDP per person ratio, ", datalist$compare, " = 1"),
       y = paste0("real GDP per person (rGDPpc) ratio, ", datalist$compare, " = 1"))

#####
# graphing allen 2003 style univariate control
#####
datalist = list(highlight = "Soviet Union", years = c(1950, 1970), ylim = c(0, 6))
datalist = list(highlight = "Soviet Union|Yugoslavia|Albania|Poland|Czechoslovakia|Hungary|Romania|Bulgaria", years = c(1950, 1980), ylim = c(0, 10))
datalist = list(highlight = "Soviet Union|Yugoslavia|Albania|Poland|Czechoslovakia|Hungary|Romania|Bulgaria|Korea North|China|Vietnam|Laos|Cambodia", years = c(1970, 1990), ylim = c(0, 10))
datalist = list(highlight = "Soviet Union|Yugoslavia|Albania|Poland|Czechoslovakia|Hungary|Romania|Bulgaria|Korea North|China|Vietnam|Laos|Cambodia", years = c(1980, 1990), ylim = c(0, 10))
datalist = list(highlight = "Iran|Turkmenistan|Uzbekistan|Kazakhstan|Kyrgystan|Tajikistan|Afghanistan|Pakistan|China|India", years = c(2001, 2014), ylim = c(0, 3))

datalist = list(highlight = "Sweden|Norway|Denmark|Finland", years = c(1950, 1980), ylim = c(0, 10))

countries = strsplit(datalist$highlight, "\\|")[[1]]
gdt = maddison[year %in% datalist$years, ][!is.na(gdppc), ][, N := .N, by = c("country_name")][N > 1, ][, N := NULL]
gdt[, `:=`(gdppc_t1 = max(gdppc * (year == datalist$years[1])),
           gdppc_t2 = max(gdppc * (year == datalist$years[2]))),
    by = c("country_name")]
gdt[, gdppc_ratio := gdppc_t2 / gdppc_t1]
gdt[, highlight := country_name %in% countries]
gdt = gdt[year == datalist$year[2], ]
fit1 = glm(gdppc_ratio ~ gdppc_t1, data = gdt[oecd == TRUE, ])
gdt[oecd == TRUE, predicted := predict(fit1)]
fit2 = glm(gdppc_ratio ~ gdppc_t1, data = gdt[highlight == TRUE, ])
gdt[highlight == TRUE, predicted := predict(fit2)]
gdt[oecd == TRUE | highlight == TRUE, label := country_name]
ggplot(gdt, aes(x = gdppc_t1, y = gdppc_ratio, label = label, color = highlight)) +
  geom_abline(intercept = coef(fit1)[1], slope = coef(fit1)[2], color = "white") +
  geom_abline(intercept = coef(fit2)[1], slope = coef(fit2)[2], color = "white") +
  geom_point() +
  geom_segment(aes(xend = gdppc_t1, yend = predicted)) +
  geom_text_repel(segment.color = NA) +
  theme_ft_rc() +
  scale_y_continuous(limits = datalist$ylim) +
  labs(title = paste0("Real GDP per person in ", datalist$years[1], " vs ", datalist$years[2]),
       x = paste0("STARTING: ", datalist$years[1], " real GDP per person"),
       y = paste0("GROWTH: Ratio of real GDP per person in ", datalist$years[2], " and in ", datalist$years[1]))

#####
# exponential growth models
####
country_exp = "Former USSR"; start_year = 1917; growth_years = 1890:1910; exist_years = 1880:2020 # Tsarist Russia vs USSR
country_exp = "Former USSR"; start_year = 1928; growth_years = 1981:1991; exist_years = 1920:2020 # USSR vs Yeltsin-Putin
country_exp = "Former USSR"; start_year = 1970; growth_years = 1981:1991; exist_years = 1920:2020 # late USSR vs Yeltsin-Putin
country_exp = "Cuba"; start_year = 1959; growth_years = 1980:1990; exist_years = 1950:2020 # Communist Cuba w/o USSR collapse
country_exp = "Cuba"; start_year = 1970; growth_years = 1980:1990; exist_years = 1950:2020 # Communist Cuba w/o USSR collapse

exp_gro_model = function(countries, year_range) {
  return(lm(log10(gdppc) ~ year, data = maddison_dt[country %in% countries & year %in% year_range, ]))
}
exp_gro_model_list = lapply(growth_years, function(end_year) { exp_gro_model(country_exp, start_year:end_year) } )
exp_gro_model_predict = function(x) {
  e = 10^(predict(x, data.table(year = exist_years)))
  years = x$model[["year"]]
  d = data.table(predicted = e, item = names(e))[, years := paste0(years[1], ":", years[length(years)])]
  return(d)
}
model_dt = rbindlist(lapply(exp_gro_model_list, exp_gro_model_predict))
ggplot() + aes(x = year) +
  coord_cartesian(xlim = c(first(exist_years), last(exist_years)), expand = 1) +
  geom_line(data = maddison_dt[country == country_exp & !is.na(gdppc), ], aes(y = gdppc)) +
  geom_line(data = model_dt[years > first(exist_years), ], aes(x = exist_years[as.numeric(item)], y = predicted, color = years)) +
  geom_text(data = model_dt[item == last(item), ], aes(x = exist_years[as.numeric(item)], y = predicted, label = years))

mean_growth = function(countries, year_range) { mean(maddison_dt[country %in% countries & year %in% year_range, "gdppc_delta", with = FALSE][[1]]) }
compound_growth = function(initial, growth_rate, growth_cycles) { return(initial * ((1 + growth_rate) ^ growth_cycles)) }
mean_growths = unlist(lapply(lapply(growth_years, function(x){ seq(exist_years[2], x) }), function(x){ mean_growth(country_exp, x) }))
mean_growths_dt = data.table(mean_growths = mean_growths, start_year = growth_years)[, start_gdp := maddison_dt[country == country_exp & year == start_year, "gdppc", with = FALSE][[1]], by = start_year]
mean_growths_dt = mean_growths_dt[, .(predicted = compound_growth(start_gdp, mean_growths, exist_years - start_year), year = exist_years), by = start_year]
mean_growths_dt = mean_growths_dt[, start_year := factor(start_year)]
ggplot() + aes(x = year) +
  coord_cartesian(xlim = c(first(exist_years), last(exist_years)), expand = 1) +
  geom_line(data = maddison_dt[country == country_exp & !is.na(gdppc), ], aes(y = gdppc)) +
  geom_line(data = mean_growths_dt, aes(x = year, y = predicted, group = start_year, color = start_year)) +
  geom_text(data = mean_growths_dt[year == 2016, ], aes(x = year, y = predicted, label = paste0(exist_years[1], ":", start_year)))

#####
# GDP growth relative to initial time
#####
relativeGrowth = function(dt, year_base) {
  dt = copy(dt)
  dt[, gdppc_base := max(gdppc * (year == year_base), na.rm = TRUE), by = country_name]
  dt[, gdppc_relative_base := gdppc / gdppc_base * 100]
  return(dt)
}
year_base = 1928
ggplot(relativeGrowth(pesdintf, year_base)[oecd == TRUE | country_name %in% c("Former USSR"), ][, country_name := "Former USSR"][oecd == TRUE, country_name := "OECD member"], aes(x = year, y = gdppc_relative_base, color = country_name, group = country_name)) +
  geom_line() + geom_point() +
  coord_cartesian(xlim = c(1900, 2000), ylim = c(25, 800)) +
  geom_hline(yintercept = 100) + geom_vline(xintercept = year_base) +
  theme_minimal() # scale_colour_manual(values = cbbPalette) +
labs(title = paste0("Relative real GDP per capita (rGDPpc) growth (", year_base, "=100)"), x = "Year", y = paste0("Relative rGDPpc growth (", year_base, "=100)"))

year_base = 1928
ggplot(relativeGrowth(pesdintf, year_base)[country_name %in% c("Former USSR", "Germany", "United States", "United Kingdom", "Italy", "France", "Spain", "Portugal"), ], aes(x = year, y = gdppc_relative_base, color = country_name)) +
  geom_line() + geom_point() +
  coord_cartesian(xlim = c(1908, 1943), ylim = c(25, 175)) +
  geom_hline(yintercept = 100) + geom_vline(xintercept = year_base) +
  theme_minimal() + # scale_colour_manual(values = cbbPalette) +
  labs(title = paste0("Relative real GDP per capita (rGDPpc) growth (", year_base, "=100)"), x = "Year", y = paste0("Relative rGDPpc growth (", year_base, "=100)"))


year_base = 1933
ggplot(relativeGrowth(maddison_dt, year_base)[country %in% c("Former USSR", "Germany", "United States", "United Kingdom", "Italy", "France", "Spain", "Portugal"), ], aes(x = year, y = gdppc_relative_base, color = country)) +
  geom_line() + geom_point() +
  coord_cartesian(xlim = c(1913, 1953), ylim = c(25, 300)) +
  geom_hline(yintercept = 100) + geom_vline(xintercept = year_base) +
  theme_minimal() + scale_colour_manual(values = cbbPalette) +
  labs(title = paste0("Relative real GDP per capita (rGDPpc) growth (", year_base, "=100)"), x = "Year", y = paste0("Relative rGDPpc growth (", year_base, "=100)"))

year_base = 1946
ggplot(relativeGrowth(maddison_dt, year_base)[country %in% c("Former USSR", "Germany", "United States", "United Kingdom", "Italy", "France", "Spain", "Portugal"), ], aes(x = year, y = gdppc_relative_base, color = country)) +
  geom_line() + geom_point() +
  coord_cartesian(xlim = c(1910, 1960), ylim = c(25, 300)) +
  geom_hline(yintercept = 100) + geom_vline(xintercept = year_base) +
  theme_minimal() + scale_colour_manual(values = cbbPalette) +
  labs(title = paste0("Relative real GDP per capita (rGDPpc) growth (", year_base, "=100)"), x = "Year", y = paste0("Relative rGDPpc growth (", year_base, "=100)"))

year_base = 1970
ggplot(relativeGrowth(maddison_dt, year_base)[oecd == TRUE | country %in% c("China"), ][, country_name := "China"][oecd == TRUE, country_name := "OECD member"], aes(x = year, y = gdppc_relative_base, color = country, group = country)) +
  geom_line() + geom_point() +
  coord_cartesian(xlim = c(1960, 2020), ylim = c(25, 800)) +
  geom_hline(yintercept = 100) + geom_vline(xintercept = year_base) +
  theme_minimal() + scale_colour_manual(values = cbbPalette) +
  labs(title = paste0("Relative real GDP per capita (rGDPpc) growth (", year_base, "=100)"), x = "Year", y = paste0("Relative rGDPpc growth (", year_base, "=100)"))

#####
# average GDP growth in time periods
#####
timeGDP = function(dt, start_time = 1880, end_time = 2020, by_time = 5) {
  dt = copy(dt)
  dt[, period := cut(year, c(-Inf, seq(start_time, end_time, by = by_time), Inf))]
  dt[, gdppc_delta_average := mean(gdppc_delta, na.rm = TRUE), by = c("period", "country")]
  dt = dt[, .SD[1], by = c("period", "country")]
  return(dt)
}
additional_countries = c("Former USSR")
ggplot(timeGDP(maddison_dt[oecd == TRUE | country %in% additional_countries, ])[country %in% additional_countries, country_name := country][oecd == TRUE, country_name := "OECD member"], aes(x = period, y = gdppc_delta_average, group = country, color = country_name)) +
  geom_point() + geom_line() +
  scale_y_continuous(breaks = seq(-.2, .2, 0.05)) +
  theme_minimal() + theme(axis.text.x = element_text(vjust = 0.5, hjust = 0.5, angle = 90)) + scale_colour_manual(values = cbbPalette) +
  labs(y = "real GDP per capita (rGDPpc) growth, period averages")

# USSR: timeGDP(maddison_dt[oecd == TRUE | country %in% c("Former USSR"), ])[country %in% c("Former USSR"), country_name := country][oecd == TRUE, country_name := "OECD member"]
# Cuba: timeGDP(maddison_dt[oecd == TRUE | country %in% c("Cuba"), ])[country %in% c("Cuba"), country_name := country][oecd == TRUE, country_name := "OECD member"]
# didn't work: [order(-country_name)][, country_name := factor(country_name)]

#####
# GDP after event
#####
afterEvent = function(dt, country_years_list) {
  dt = copy(dt)
  output_dt = data.table()
  for (item in country_years_list) {
    country_var = item[1]
    year_base = as.numeric(item[2])
    for_dt = copy(dt)[country == country_var, ]
    for_dt[, gdppc_base := max(gdppc * (year == year_base), na.rm = TRUE)]
    for_dt[, gdppc_relative_base := gdppc / gdppc_base * 100]
    for_dt[, year_relative := year - year_base]
    if (length(item) == 3) {
      for_dt = for_dt[year < as.numeric(item[3]), ]
    }
    if (!(any(is.infinite(for_dt[["gdppc_base"]])))) {
      output_dt = rbind(output_dt, for_dt)
    }
  }
  return(output_dt)
}
# maddison 2018 does not distinguish west vs east germany
# maddison 2018 does not distinguish yemen vs south yemen
# creation = list(c("Former USSR", 1928, 1991), c("Mongolia", 1922, 1992), c("Poland", 1945, 1989), c("Romania", 1948, 1989), c("Yugoslavia", 1946, 1966), c("Bulgaria", 1946, 1989), c("Albania", 1946, 1992), c("Czechoslovakia", 1948, 1990), c("Hungary", 1949, 1990), c("China", 1950, 1978), c("Cuba", 1959, 2011), c("D.P.R. of Korea", 1953), c("Yemen", 1967, 1990), c("Congo", 1969, 1991), c("Somalia", 1970, 1991), c("Viet Nam", 1973, 1986), c("Ethiopia", 1974, 1987), c("Mozambique", 1975, 1990), c("Benin", 1976, 1990), c("Angola", 1975, 1991), c("Madagascar", 1975, 1992), c("Cambodia", 1979, 1991))
# creation = list(c("Former USSR", 1991), c("Mongolia", 1992), c("Poland", 1989), c("Romania", 1989), c("Yugoslavia", 1966), c("Bulgaria", 1989), c("Albania", 1992), c("Czechoslovakia", 1990), c("Hungary", 1990), c("China", 1978), c("Cuba", 2011), c("Yemen", 1990), c("Somalia", 1991), c("Viet Nam", 1986), c("Congo", 1991), c("Ethiopia", 1987), c("Mozambique", 1990), c("Benin", 1990), c("Angola", 1991), c("Madagascar", 1992), c("Cambodia", 1991))
creation = list(c("Germany", 1933, 1945), c("Former USSR", 1928, 1991))
# rbind(afterEvent(maddison_dt, list(c("Cuba", 1959, 2011)))[, country_name := "Cuba 1959"], afterEvent(maddison_dt, list(c("Cuba", 2011)))[, country_name := "Cuba 2011"])
output_dt = afterEvent(maddison_dt, creation)[!is.infinite(gdppc_relative_base) & !is.na(gdppc_relative_base), ][, .SD[max(year_relative, na.rm = TRUE) >= 25, ], by = c("country")]
ggplot(output_dt, aes(x = year_relative, y = gdppc_relative_base, color = country)) +
  geom_point() + geom_line() +
  geom_hline(yintercept = 100) + geom_vline(xintercept = 0) +
  coord_cartesian(xlim = c(-20, 50), ylim = c()) + theme_minimal() + scale_colour_manual(values = rep(cbbPalette, 3))

#####
# compare with region
#####
# comparison
twoRegions = function(g1, g2, l) {
  dt = copy(maddison_dt)
  dt = dt[grep(paste0(g1,collapse="|"), country), ]
  dt = dt[grep(paste0(g1[!g1 %in% g2],collapse="|"), country), country := l]
  dt = dt[, lapply(.SD, weighted.mean, w=pop, na.rm = TRUE), by=c("country","year"), .SDcols=grep("gdppc", colnames(maddison_dt), value=TRUE)]
  return(dt)
}

g1 = country_conversions[continent == "South America", ][["clio_infra"]]
g2 = c("Bolivia", "Venezuela")
l = "South America"
dt = twoRegions(g1, g2, l)
ggplot(dt, aes(x = year, y = gdppc, color = country)) + geom_point() + geom_line() + coord_cartesian(xlim = c(1940, 2020)) + geom_vline(xintercept = 1973) + geom_vline(xintercept = 1990) + labs(y = "real GDP per capita")
ggplot(dt, aes(x = year, y = gdppc_delta_sma_5, color = country)) + geom_point() + geom_line() + coord_cartesian(xlim = c(1940, 2020)) + geom_vline(xintercept = 1973) + geom_vline(xintercept = 1990) + labs(y = "real GDP per capita YOY growth, 5 year moving average")
ggplot(dt, aes(x = year, y = gdppc, color = country)) + geom_point() + geom_line() + coord_cartesian(xlim = c(1980, 2020)) + geom_vline(xintercept = 2006) + labs(y = "real GDP per capita")
ggplot(dt, aes(x = year, y = gdppc_delta_sma_5, color = country)) + geom_point() + geom_line() + coord_cartesian(xlim = c(1980, 2020)) + geom_vline(xintercept = 2006) + labs(y = "real GDP per capita YOY growth, 5 year moving average")

g1 = country_conversions[continent == "Africa", ][["clio_infra"]]
g2 = c("South Africa", "Nigeria")
l = "Africa"
dt = twoRegions(g1, g2, l)
ggplot(dt, aes(x = year, y = gdppc, color = country)) + geom_point() + geom_line() + coord_cartesian(xlim = c(1940, 2020)) + geom_vline(xintercept = 1973) + geom_vline(xintercept = 1990) + labs(y = "real GDP per capita")
ggplot(dt, aes(x = year, y = gdppc_delta_sma_5, color = country)) + geom_point() + geom_line() + coord_cartesian(xlim = c(1940, 2020)) + geom_vline(xintercept = 1973) + geom_vline(xintercept = 1990) + labs(y = "real GDP per capita YOY growth, 5 year moving average")
