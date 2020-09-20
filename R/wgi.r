#' @title
#' World Giving Index Dataset
#' @description
#' The World Giving Indexes, last published in 2020, contain data from 2010 to 2019 on self-reported charitability of many countries. Constructed both manually and programmatically, see /data-raw/wgi.r in source.
#' @references
#' Charities Aid Foundation and Gallup (2020). "World Giving Index 2019".
#' @source
#' * 2019: <https://www.cafonline.org/about-us/publications/2019-publications/caf-world-giving-index-10th-edition>
#' * 2018: <https://www.cafonline.org/about-us/publications/2018-publications/caf-world-giving-index-2018>
#' * 2017: <https://www.cafonline.org/about-us/publications/2017-publications/caf-world-giving-index-2017>
#' * 2016: <https://www.cafonline.org/about-us/publications/2016-publications/caf-world-giving-index-2016>
#' * 2015: <https://www.cafonline.org/about-us/publications/2015-publications/caf-world-giving-index-2015>
#' * 2014: <https://www.cafonline.org/about-us/publications/2014-publications/caf-world-giving-index-2014>
#' * 2013: <https://www.cafonline.org/about-us/publications/2013-publications/world-giving-index-2013>
#' * 2012: <https://www.cafonline.org/about-us/publications/2012-publications/world-giving-index-2012>
#' * 2011: <https://www.cafonline.org/about-us/publications/2011-publications/world-giving-index-2011>
#' * 2010: <https://www.cafonline.org/about-us/publications/2010-publications/world-giving-index>
#' @keywords charity, charities, aid, foundation, world, giving, index
#' @format A data table with 1394 rows and 11 variables:
#' \describe{
#'   \item{country_code}{master_short country code (no code originally given)}
#'   \item{country_name}{master_long country name (converted from WGI's (inconsistent) country names)}
#'   \item{year}{year (2010 to 2019)}
#'   \item{wgi_overall}{simple mean of money, time, stranger}
#'   \item{wgi_overall_rank}{ranking of overall}
#'   \item{wgi_money}{proportion of respondents answering yes to: "Have you done any of the following in the past month? Donated money to a charity?"}
#'   \item{wgi_money_rank}{ranking of money (2012-2019)}
#'   \item{wgi_time}{proportion of respondents answering yes to: "Have you done any of the following in the past month? Volunteered your time to an organisation?"}
#'   \item{wgi_time_rank}{ranking of time (2012-2019)}
#'   \item{wgi_stranger}{proportion of respondents answering yes to: "Have you done any of the following in the past month? Helped a stranger, or someone you didn't know who needed help."}
#'   \item{wgi_stranger_rank}{ranking of stranger (2012-2019)}
#' }
"wgi"
