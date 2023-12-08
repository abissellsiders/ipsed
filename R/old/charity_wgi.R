#' @title Charities Aid Foundation World Giving Index dataset
#' @description Charities Aid Foundation annually (since 2010) releases a report titled "World Giving Index" which asks what proportion of people have done charitable acts, such as donating or volunteering.
#' @references Charities Aid Foundation. "World Giving Index" reports, 2016. Charities Aid Foundation. "International Comparisons of Charitable Giving", 2006.
#' @source Data sources:
#' \itemize{
#' \item INFO: Charity Aid Foundation publications: <https://www.cafonline.org/about-us/publications>
#' \item DATA: Charities Aid Foundation World Giving Index
#' \item DATA: Charities Aid Foundation World Giving Index
#' \item DATA: Charities Aid Foundation World Giving Index 2020: <https://www.cafonline.org/about-us/publications/2021-publications/caf-world-giving-index-2021>
#' \item DATA: Charities Aid Foundation World Giving Index 2019: <https://www.cafonline.org/about-us/publications/2019-publications/caf-world-giving-index-10th-edition>
#' \item DATA: Charities Aid Foundation World Giving Index 2018: <https://www.cafonline.org/about-us/publications/2018-publications/caf-world-giving-index-2018>
#' \item DATA: Charities Aid Foundation World Giving Index 2017: <https://www.cafonline.org/about-us/publications/2017-publications/caf-world-giving-index-2017>
#' \item DATA: Charities Aid Foundation World Giving Index 2016: <https://www.cafonline.org/about-us/publications/2016-publications/caf-world-giving-index-2016>
#' \item DATA: Charities Aid Foundation World Giving Index 2015: <https://www.cafonline.org/about-us/publications/2015-publications/caf-world-giving-index-2015>
#' \item DATA: Charities Aid Foundation World Giving Index 2014: <https://www.cafonline.org/about-us/publications/2014-publications/caf-world-giving-index-2014>
#' \item DATA: Charities Aid Foundation World Giving Index 2013: <https://www.cafonline.org/about-us/publications/2013-publications/world-giving-index-2013>
#' \item DATA: Charities Aid Foundation World Giving Index 2012: <https://www.cafonline.org/about-us/publications/2012-publications/world-giving-index-2012>
#' \item DATA: Charities Aid Foundation World Giving Index 2011: <https://www.cafonline.org/about-us/publications/2011-publications/world-giving-index-2011>
#' \item DATA: Charities Aid Foundation World Giving Index 2010: <https://www.cafonline.org/about-us/publications/2010-publications/world-giving-index>
#' }
#' @keywords caf, charity, charities, charitable, giving, give, donation, donate
#' @format A data table with many rows and 11 variables:
#' \describe{
#' \item{country_code}{master_short country code (no code originally given)}
#' \item{country_name}{master_long country name (converted from WGI's (inconsistent) country names)}
#' \item{year}{year (2010 to 2021)}
#' \item{wgi_overall}{simple mean of money, time, stranger}
#' \item{wgi_overall_rank}{ranking of overall}
#' \item{wgi_money}{proportion of respondents answering yes to: "Have you done any of the following in the past month? Donated money to a charity?"}
#' \item{wgi_money_rank}{ranking of money (2012-2019)}
#' \item{wgi_time}{proportion of respondents answering yes to: "Have you done any of the following in the past month? Volunteered your time to an organisation?"}
#' \item{wgi_time_rank}{ranking of time (2012-2019)}
#' \item{wgi_stranger}{proportion of respondents answering yes to: "Have you done any of the following in the past month? Helped a stranger, or someone you didn't know who needed help."}
#' \item{wgi_stranger_rank}{ranking of stranger (2012-2019)}
#' }
"charity_wgi"
