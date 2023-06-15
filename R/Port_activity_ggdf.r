#' Port_activity_ggdf
#' 
#' @description Port activity summarised across space for 2021 and to December 2022. Data originally from EMODNET.
#' 
#' @format A data frame comprising 120 rows and 9 columns. 
#' \describe{
#'    \item{port}{Name of port zone}
#'    \item{name}{Layer name from raster file}
#'    \item{Activity}{Mean route density /km2}
#'    \item{Date}{Date of image from raster.}
#'    \item{year}{year of shipping data}
#'    \item{month}{month of shipping data}
#'    \item{day}{day of shipping data}
#'    \item{activity_cumsum}{Cumulative sum of activity for each year.}
#'    \item{year_fac}{Year as a factor for plotting}
#'    }
"Port_activity_ggdf"

 