#' @title United Nations Civilian Casualties datasets
#' @description The United Nations publishes daily estimates of corroborated civilian casualties in the 2022 Russian invasion of Ukraine.
#' @references United Nations in Ukraine. Civilian Casualties: Mutliple dates (26 February-14 March 2022).
#' @source Data sources:
#' \itemize{
#' \item DATA: UN Ukraine publications: <https://ukraine.un.org/en/resources/publications>
#' \item DATA: Civilian casualties  1 January 2018 to 31 March 2021 and civilian deaths 2014-2022: <https://ukraine.un.org/sites/default/files/2021-04/Conflict-related%20civilian%20casualties%20as%20of%2031%20March%202021%20%28rev%2015%20April%202021%29%20EN.pdf>
#' \item DATA: Civilian casualties  1 January 2018 to 30 April 2021 and civilian deaths 2014-2022: <https://ukraine.un.org/sites/default/files/2021-05/Conflict-related%20civilian%20casualties%20as%20of%2030%20April%202021%20%28rev%206%20May%202021%29%20EN.pdf>
#' \item DATA: Civilian casualties  1 January 2018 to 30 September 2021 and civilian deaths 2014-2022: <https://ukraine.un.org/sites/default/files/2021-10/Conflict-related%20civilian%20casualties%20as%20of%2030%20September%202021%20%28rev%208%20Oct%202021%29%20EN.pdf>
#' \item DATA: Civilian casualties: 1 January 2018 to 31 December 2021 and civilian deaths 2014-2022: <https://ukraine.un.org/sites/default/files/2022-02/Conflict-related%20civilian%20casualties%20as%20of%2031%20December%202021%20%28rev%2027%20January%202022%29%20corr%20EN_0.pdf>
#' \item DATA: Civilian deaths: Protests in Odessa: <https://ukraine.un.org/sites/default/files/2020-09/2%20May%202020%20ENG%20%281%29.pdf>
#' \item DATA: Civilian deaths: Maidan protests in Kyiv: <https://ukraine.un.org/sites/default/files/2020-09/Maidan%20ENG%2020.02.20.pdf>
#' }
#' @keywords ukraine,body count,casualty,casualties,kill,killing,dead,death,fatality,fatal,death toll
#' @format A data table with 17 or more rows and 5 variables. Key variables:
#' \describe{
#' \item{date_start}{date on which casualties started}
#' \item{date_end}{date on which casualties were reported by the UN in Ukraine}
#' \item{location}{location of casualties}
#' \item{civilians_killed}{number of civilians reported killed}
#' \item{civilians_injured}{number of civilians reported injured}
#' \item{url}{url of source}
#' }
"united_nations_ukraine_casualties"
