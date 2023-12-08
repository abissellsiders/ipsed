#' @title Corruptions Perception Index dataset
#' @description The Corruptions Perceptions Index, last published in 2020, contains data from 1980* to 2019 on the perceived public-sector corruption -- "misuse of public power for private benefit" -- for most countries in the world.
#' @details
#' I divide the CPI into three major versions, indicated by #' \code{cpi_version}: (1) 1980-85 & 1988-92 & 1993-1996 & 1997, (2) 1998-2011, and (3) 2012-2019.
#'
#' \itemize{
#' \item 2012-2021: Absolute CPI: <https://www.transparency.org/files/content/pressrelease/2012_CPIUpdatedMethodology_EMBARGO_EN.pdf>
#' \itemize{
#' \item Stable # of sources, stable # of countries
#' \item Ratings are absolute values from 0-100 (0 clean, 100 corrupt)
#' \item Ratings used only ~1-year-old or younger data
#' \item Ratings covered only one year (not a range of years)
#' \item Ratings reported overall and by each data source
#' }
#' \item 1997-2011: Relative CPI: <http://www.icgg.org/corruption.cpi_olderindices.html>
#' \itemize{
#' \item Increasing # of sources, increasing # of countries
#' \item Ratings are relative values from 0-10 (0 worst, 10 best)
#' \item Ratings use only ~3-year-old or younger data
#' \item Ratings covered only one year (not a range of years)
#' \item Ratings reported overall only (not by each data source)
#' \item 2000: 90 countries, 16 sources (minimum of 3): 6 from 2000, 4 from 1999, 1 from 1999-2000, 5 from 1998: <https://images.transparencycdn.org/images/2000_CPI_Framework_EN.pdf>
#' \item 1999: 99 countries, 16 sources (minimum of 3): 4 from 1999, 5 from 1998, 6 from 1997, 1 from 1996-1997: <http://www.icgg.org/downloads/1999_CPI_FD.pdf>
#' \item 1998: 85 countries, 12 sources (minimum of 3): 5 from 1998, 5 from 1997, 2 from 1996: <http://www.icgg.org/downloads/FD1998.pdf>
#' }
#' \item 1980-1997: Early CPI: <http://www.icgg.org/corruption.cpi_childhooddays.html>
#' \itemize{
#' \item Increasing # of sources, stable # of countries
#' \item Ratings are relative values from 0-10 (0 worst, 10 best)
#' \item Ratings use only ~4-year-old or younger data
#' \item Ratings covered only one year (not a range of years)
#' \item Ratings reported overall only (not by each data source)
#' \item 1997: 52 countries, 7 sources (minimum of 4): 6 from 1997, 1 from 1996: <https://www.transparency.org/files/content/tool/1997_CPI_EN.pdf>
#' \item 1993-96 (released as CPI 1996): 54 countries, 10 sources (minimum of 4): 1 from 1996, 1 from 1995-6, 3 from 1995, 2 from 1994, 1 from 1993-95, 2 from 1993: <https://www.transparency.org/files/content/tool/1996_CPI_EN.pdf>
#' \item 1995 (don't use): 41 countries, 7 sources (minimum of 2): 2 from 1994, 2 from 1993, 2 from 1992, 1 from 1980 (!): <http://www.icgg.org/corruption.cpi_olderindices_1995.html> and <https://www.transparency.org/files/content/tool/1995_CPI_EN.pdf>
#' \item 1988-92: 54 countries, 4 sources (minimum 1): 2 from 1988, 2 from 1992: <http://www.icgg.org/corruption.cpi_olderindices_historical.html> and <http://www.icgg.org/corruption.cpi_olderindices_hist_sources.html>
#' \item 1980-85: 54 countries, 2 sources (minimum 1): 1 from 1982-85, 1 from 1980: <http://www.icgg.org/corruption.cpi_olderindices_historical.html> and <http://www.icgg.org/corruption.cpi_olderindices_hist_sources.html>
#' }
#' }
#' These methodology changes prevent simple comparison across years. Users should choose a strategy below:
#' \itemize{
#' \item Most conservative: Use #' \code{cpi_rescaled} for version 3 only (#' \code{fipsed[cpi_version == 4, ]}). Years 2012-2019.
#' \item Less conservative: Use #' \code{cpi_rescaled} for versions 2-3 only (#' \code{fipsed[cpi_version #' \%in#' \% c(3,4), ]}) in separate analyses. Years 1998-2011 and 2012-2019.
#' \item Less conservative: Use #' \code{cpi_linked} and #' \code{cpi_weight} for versions 1-3 (#' \code{fipsed[cpi_version #' \%in#' \% c(2:4), ]}) in joint analysis. Years 1980-2019. (Author's choice)
#' \item Naive: Use #' \code{cpi_rescaled} for versions 1-3. Years 1980-2019. (Strongly unadvised, especially for trend analysis)
#' }
#' \section{Attempted to convert the relative to absolute data (link 2012-2019 and 1998-2011) following the below procedure:}{
#' Equate 2011 and 2012 scores for the top X and bottom X of the scores and using that to compute the other scores.
#' }
#' @references Transparency International (2020). "Corruption Perceptions Index". Authored by Johann Lambsdorff from 1995-2008.
#' @source Data sources:
#' \itemize{
#' \item Wiki: <https://en.wikipedia.org/wiki/Corruption_Perceptions_Index>
#' \item Page: <https://www.transparency.org/en/cpi>
#' \item Methodology: <https://images.transparencycdn.org/images/2019_CPI_methodology.pdf>
#' \item 2021: <https://www.transparency.org/en/cpi/2021>
#' \item 2020: <https://www.transparency.org/en/cpi/2020>
#' \item 2019: <https://images.transparencycdn.org/images/2019_CPI_FULLDATA.zip>
#' \item 2018: <https://images.transparencycdn.org/images/2018_CPI_FullResults.zip>
#' \item 2017: <https://images.transparencycdn.org/images/CPI2017_FullDataSet.xlsx>
#' \item 2016: <https://images.transparencycdn.org/images/CPI2016_FullDataSetWithRegionalTables_200409_135127.xlsx>
#' \item 2015: <https://images.transparencycdn.org/images/CPI_2015_FullDataSet.xlsx>
#' \item 2014: <https://images.transparencycdn.org/images/CPI2014_DataBundle-2.zip>
#' \item 2013: <https://images.transparencycdn.org/images/CPI2013_DataBundle-2.zip>
#' \item 2012: <https://images.transparencycdn.org/images/2012_CPI_DataPackage.zip>
#' \item 2011: <https://images.transparencycdn.org/images/CPI-Archive-2011.csv>
#' \item 2010: <https://images.transparencycdn.org/images/CPI-Archive-2010.csv>
#' \item 2009: <https://images.transparencycdn.org/images/CPI-Archive-2009.csv>
#' \item 2008: <https://images.transparencycdn.org/images/CPI-Archive-2008.csv>
#' \item 2007: <https://images.transparencycdn.org/images/CPI-Archive-2007.csv>
#' \item 2006: <https://images.transparencycdn.org/images/CPI-Archive-2006.csv>
#' \item 2005: <https://images.transparencycdn.org/images/CPI-Archive-2005.csv>
#' \item 2004: <https://images.transparencycdn.org/images/CPI-Archive-2004.csv>
#' \item 2003: <https://images.transparencycdn.org/images/CPI-Archive-2003.csv>
#' \item 2002: <https://images.transparencycdn.org/images/CPI-Archive-2002.csv>
#' \item 2001: <https://images.transparencycdn.org/images/CPI-Archive-2001-1.csv>
#' \item 2000: <https://images.transparencycdn.org/images/CPI-Archive-2000.csv>
#' \item 1999: <https://images.transparencycdn.org/images/CPI-Archive-1999.csv>
#' \item 1998: <https://images.transparencycdn.org/images/CPI-Archive-1998.csv>
#' \item 1997: <https://images.transparencycdn.org/images/CPI-Archive-1997.csv>
#' \item 1996: <https://images.transparencycdn.org/images/CPI-Archive-1996.csv>
#' \item 1995: <https://images.transparencycdn.org/images/CPI-Archive-1995.csv>
#' \item 1980-85, 1988-92, and 1993-96 (pp 5-6): <https://www.transparency.org/files/content/tool/1996_CPI_EN.pdf>
#' \item 1980-85 and 1988-92 Lambsdorff: <http://www.icgg.org/corruption.cpi_olderindices_historical.html> and <http://www.icgg.org/corruption.cpi_olderindices_hist_sources.html>
#' }
#' @keywords gdp per capita, real gdp, gdppc, maddison, pop, population, historical gdp
#' @format A data table with 17548 rows and 23 variables:
#' \describe{
#' \item{country_code}{ISO 3166 country name}
#' \item{country_name}{ISO 3166 country name}
#' \item{year}{year (1980 to 2019)}
#' \item{cpi_version}{Indicates which CPI version was used (see Details): (1) 1980-85 & 1988-92 & 1993-1996 & 1997, (2) 1998-2011, and (3) 2012-2019}
#' \item{cpi_weight}{Some ratings were originally ranges across years and should probably be weighted lower (ignore if analysis years >=1997): 1 for 1997-2019, 0.25 (1/4) for 1993-1996, 0.2 (1/5) for 1988-1992, 0.167 (1/6) for 1980-1985}
#' \item{cpi_score}{Weighted average of recent general public, expert, and businessperson ratings of corruption in a country. Absolute rating from 2012-2019. Relative rating from 1980-2011. One should almost always use \code{cpi_score_rescaled} or \code{cpi_score_linked} instead.}
#' \item{cpi_rescaled}{\code{cpi_score} rescaled from 0 to 1 (/100 for 2012-2019, /10 for 1980-2011)}
#' \item{cpi_linked}{\code{cpi_rescaled} linked across versions 4, 3, and 2. Allows comparison across 1995-2019. Uses method in Details.}
#' \item{cpi_se}{Standard error of CPI score (across sources). Available only 2012-2019. Note to self: CPI author Johann Lambsdorff's website contains a(n otherwise identical) copy of CPI from 1995-2008 that also contains data on the number of surveys used and between-survey ratings variance, but these tables are difficult to read programmatically and are unavailable for 1980-85, 1988-92, and 2009-11.}
#' }
"govt_cpi_corruption"
