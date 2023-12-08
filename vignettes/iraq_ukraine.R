#####
# init
#####
# remove all objects
rm(list=ls(all=TRUE))

# load packages
library("pesdint")
library("data.table")
library("ggplot2")
library("sdlutils")
library("scales")
library("ggrepel")

# set working directory
(wd = "C:/gdrive/rpackages/pesdint/vignettes/")
setwd(wd)

# date iraq, ukraine started and duration since then
date_iraq_start = as.Date("2003-03-20")
date_ukraine_start = as.Date("2022-02-24")
date_current = Sys.Date()
date_ukraine_diff = (date_current - date_ukraine_start)

#####
# read data
#####
# read iraq data
ibc = copy(iraq_body_count_even)

# read ukraine data, subset since start of formal war
ukr = copy(united_nations_ukraine_casualties_even)

#####
# melt data
#####
# merge data
rdt = rbind(ibc, ukr, fill = TRUE)

# reformat date as numeric
gdt = copy(rdt)
gdt[, days_since_start := as.numeric(days_since_start)]

# subset since start of formal war
gdt = gdt[days_since_start > 0, ]

# subset to prior to most recent ukraine day
max_days = max(gdt[country == "Ukraine", days_since_start])
gdt = gdt[days_since_start <= max_days, ]
rdt = rdt[days_since_start <= max_days, ]

#####
# graph data
#####
# formatting
f1 = list(scale_fill_brewer(palette = "Reds", direction = -1L),
          labs(caption = c("@socdoneleft", 'Sources:\nUnited Nations in Ukraine, civilian casualties updates: https://ukraine.un.org/en/resources/publications\nIraq Body Count: https://iraqbodycount.org/database'),
               fill = "Country",
               x = "Days since start of war",
               y = "Cumulative civilian deaths"))
s1 = list(scale_x_continuous(limits = c(0, max(gdt[["days_since_start"]])), breaks = seq(0, 3000, by = 30), expand = c(0.01, 0.01)),
          scale_y_continuous(limits = c(0, 1.5e4), expand = c(0.01, 0.01)))
s2 = list(scale_y_continuous(limits = c(0, 0.9e4), expand = c(0.01, 0.01)))
s3 = list(scale_x_continuous(breaks = seq(-3000, 3000, by = 30), expand = c(0.01, 0.01)))
maxcas = round(max(rdt[country == "Ukraine", ][["deaths_cumulative"]])/100)*100
s4 = list(scale_x_date(),
          scale_y_continuous(limits = c(0, maxcas), expand = c(0.01, 0.01)))


# plot ukraine and iraq
ggplot(gdt, aes(x = days_since_start, y = deaths_cumulative_sincestart, fill = country)) +
  theme_sdl() + f1 + s1 +
  geom_area(position = "identity", color = "white") +
  labs(title = "Civilian death toll in Ukraine 2022 and Iraq 2003",
       subtitle = "Both datasets are undercounts that include only corroborated deaths\nBoth datasets include deaths by *all* perpetrators\nBoth datasets mostly corroborated by media, medical, or military reports\nDeaths from multi-day events or reporting periods spread evenly over each day\nUkraine: Deaths are further undercounted due to information and publication delays")
ggsave_sdl("casualties_deaths_ukraine_iraq.png")

# plot iraq
ggplot(gdt[country == "Iraq", ], aes(x = days_since_start, y = deaths_cumulative_sincestart, fill = country)) +
  theme_sdl() + f1 + s1 +
  geom_area(color = "white") +
  labs(title = "Civilian death toll in Iraq 2003",
       subtitle = "Includes deaths by *all* perpetrators\nDataset is an undercount that includes only corroborated deaths\nDeaths from multi-day events or reporting periods spread evenly over each day")
ggsave_sdl("casualties_deaths_iraq.png")

# plot ukraine
ggplot(gdt[country == "Ukraine", ], aes(x = days_since_start, y = deaths_cumulative_sincestart, fill = country)) +
  theme_sdl() + f1 + s1 + s2 +
  geom_area(color = "white") +
  labs(title = "Civilian death toll in Ukraine 2022",
       subtitle = "Includes deaths by *all* perpetrators\nDataset is an undercount that includes only corroborated deaths\nData is further substantially undercounted due to ongoing warfare\nDeaths from multi-day events or reporting periods spread evenly over each day")
ggsave_sdl("casualties_deaths_ukraine.png")

# plot ukraine since maidan
xvec = as.Date(c("2013-11-21", "2014-02-21", "2014-06-25", "2015-02-12", "2022-02-22"))
yvec = 5000
labs = c("Euromaidan protests start", "Trade Union fire; Putin begins Crimean annexation", "Russian troops occupy Donetsk and Luhansk", "Minsk II agreement announced", "Putin announces invasion of Ukraine")
xoffset = as.Date("2000-01-01")-as.Date("2000-02-15")
g4 = geom_labelled_vline(xvec = xvec, yvec = yvec, labs = labs, xoffset = xoffset, color = "white")
ggplot(rdt[country == "Ukraine", ], aes(x = day, y = deaths_cumulative, fill = country)) +
  theme_sdl() + f1 + s4 +
  geom_area(color = "white") + g4 +
  labs(title = "Civilian death toll in Ukraine 2014-22",
       subtitle = "Includes deaths by *all* perpetrators\nDataset is an undercount that includes only corroborated deaths\nData is further substantially undercounted due to ongoing warfare\nDeaths from multi-day events or reporting periods spread evenly over each day")
ggsave_sdl("casualties_deaths_ukraine_sincemaidan.png")

# plot ukraine since maidan noncum
ggplot(rdt[country == "Ukraine", ], aes(x = day, y = deaths, fill = country)) +
  theme_sdl() + f1 +
  geom_bar(stat = "identity", color = "white") +
  labs(title = "Civilian death toll in Ukraine 2014-22",
       x = NULL,
       y = "Deaths per day",
       subtitle = "Includes deaths by *all* perpetrators\nDataset is an undercount that includes only corroborated deaths\nData is further substantially undercounted due to ongoing warfare\nDeaths from multi-day events or reporting periods spread evenly over each day")
ggsave_sdl("casualties_deaths_ukraine_sincemaidan_noncum.png")

# plot ukraine since maidan noncum
gdt = copy(rdt)
gdt[, year := year(day)]
gdt = gdt[, .(deaths = sum(deaths)), by = c("year", "country")]
gdt = gdt[country == "Ukraine", ]
ggplot(gdt, aes(x = year, y = deaths, fill = country)) +
  theme_sdl() + f1 +
  scale_x_continuous(expand = c(0.01, 0.01)) +
  scale_y_continuous(limits = c(0, .9e4), expand = c(0, 0)) +
  geom_bar(stat = "identity", color = "white") +
  geom_text(mapping = aes(y = deaths, label = round(deaths)), angle = 90, hjust = -0.1) +
  labs(title = "Civilian death toll in Ukraine 2014-22",
       x = NULL,
       y = "Deaths per year",
       subtitle = "Includes deaths by *all* perpetrators\nDataset is an undercount that includes only corroborated deaths\nData is further substantially undercounted due to ongoing warfare\nDeaths from multi-day events or reporting periods spread evenly over each day")
ggsave_sdl("casualties_deaths_ukraine_sincemaidan_noncum_yearly.png")
