#####
# init
#####
# clear old data
rm(list=ls(all=TRUE))

# load packages
library("data.table")
library("readxl")
library("sdlutils")
library("stringr")
library("lubridate")

# set working directory
wd_data = "C:/gdrive/rpackages/pesdint/data-raw/labor/bls_work_stoppages"
setwd(wd_data)

# https://download.bls.gov/pub/time.series/ws/
# https://www.bls.gov/wsp/data/
# https://www.bls.gov/wsp/data/tables/
# https://www.bls.gov/web/wkstp/monthly-listing.htm
# https://www.bls.gov/web/wkstp/annual-listing.htm
# https://www.bls.gov/wsp/factsheets/summary-of-work-stoppages-in-the-united-states.htm

#####
# read data
#####
url_ = "https://download.bls.gov/pub/time.series/ws/ws.data.1.AllData"
filename = "ws.data.1.AllData.csv"
bls = download_table_failover(url_, filename)

# period
bls[, period_type := c("monthly", "annual")[(period == "M13") + 1]]
bls[period_type == "monthly", month_ := as.numeric(str_replace_all(period, c("M0|M"="")))]
bls[period_type == "annual", month_ := 12]

# date
bls[, date_ := as.Date(paste0(year, "/", month_, "/", 1))]

# value
bls[value == "-", value := NA]
bls[, value := as.numeric(value)]

#####
# graph data
#####
# load packages
library("data.table")
library("readxl")
library("sdlutils")
library("stringr")
library("lubridate")
library("ggplot2")
library("scales")

gdt = bls[series_id == "WSU020", ]
# gdt[period_type == "annual", value := value / 12]
gdt = gdt[period_type == "monthly", ]
gdt[, value := value * 1000]

# # add last 3 months
# n = 1
# gdt2 = rbindlist(lapply(1:n, function(x){copy(gdt[nrow(gdt), ])}))
# gdt2[, date_ := seq.Date(as.Date("2023/07/01"), as.Date("2023/08/01"), "month")]
# gdt2[1, value := value + 160000]
# gdt = rbind(gdt, gdt2)

# smooth
cols_todo = c("value")
cols_smooth = paste0(cols_todo, "_smooth")
gdt[, (cols_smooth) := lapply(.SD, function(x){ksmooth(x = 1:length(x), y = x, kernel = "normal", bandwidth = 6)$y}), .SDcols = cols_todo]

sum(gdt[date_ >= as.Date("2004/1/1") & date_ < as.Date("2018/1/1"), ][["value"]])
sum(gdt[date_ >= as.Date("2018/1/1") & date_ < as.Date("2023/6/1"), ][["value"]])

# graph
ggplot(gdt, aes(x = date_, y = value)) +
  geom_col(width = 32, color = NA) +
  geom_line(mapping = aes(y = value_smooth), color = "white") +
  scale_x_date(expand = c(0.01, 0), date_breaks = "years", date_labels = "%Y", limits = as.Date(c("1981/01/01", "2023/12/31"))) +
  scale_y_continuous(expand = c(0, 0), limits = c(0, 7e5), breaks = seq(0, 1e6, 5e4), labels = comma) +
  theme_sdl() +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 0.5)) +
  labs(x = NULL,
       y = "number of workers in work stoppages",
       title = "Number of striking workers, by month, USA, 1981-2023",
       subtitle = "Includes the SAG-AFTRA strike, at 160,000 workers\nBLS data only includes strikes of 1,000 or more workers",
       caption = c("@socdoneleft", "Sources:\nBureau of Labor Statistics, Work Stoppages Flat File series WSU020\nGraph assumes that SAG-AFTRA strike lasts 1 month"))
ggsave_sdl("work_stoppages.png")

#####
# graph data
#####
gdt = bls[series_id == "WSU020", ]
gdt = gdt[period_type == "annual", ]
gdt[, value := value * 1000]

gdt2 = copy(gdt)[1, ]
value_ = sum(bls[series_id == "WSU020" & period_type == "monthly" & year == 2023, ][["value"]]) * 1000 #+ 1.6e5
gdt2[, value := value_]
gdt2[, year := 2023]
gdt = rbind(gdt, gdt2)

# graph
ggplot(gdt, aes(x = year, y = value)) +
  geom_col(width = 1, color = NA) +
  scale_x_continuous(expand = c(0.01, 0), breaks = seq(1980, 2025, 1)) +
  scale_y_continuous(expand = c(0, 0), limits = c(0, 1e6), breaks = seq(0, 1e6, 1e5), labels = comma) +
  theme_sdl() +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 0.5)) +
  labs(x = NULL,
       y = "number of workers in work stoppages",
       title = "Number of striking workers, by year, USA, 1981-2023",
       subtitle = "2023 numbers are incomplete (Jan-May) and add 160,000-person SAG-AFTRA strike\nBLS data only includes strikes of 1,000 or more workers",
       caption = c("@socdoneleft", "Sources:\nBureau of Labor Statistics, Work Stoppages Flat File series WSU020"))
ggsave_sdl("work_stoppages2.png")
