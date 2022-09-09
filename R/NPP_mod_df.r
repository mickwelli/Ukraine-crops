#' npp_mod_df
#' 
#' @description NPP MODIS data represented as a data frame extracted
#' for 1st of January 2010 through to August 2022.
#' 
#' @format A data frame comprising 813008 rows and 10 columns. 
#' \describe{
#'    \item{date}{date of NPP capture}
#'    \item{x}{longitude}
#'    \item{y}{latitude}
#'    \item{NPP}{Net Primary Productivity}
#'    \item{year}{year that NPP was captured}
#'    \item{month}{month that NPP was captured}
#'    \item{day}{day of month that NPP was captured}
#'    \item{war}{factor representing pre (2012-2021) and post (2022) war period}
#'    \item{x_1}{longitude backup}
#'    \item{y_1}{latitude backup}
#'    }
"npp_mod_df"

 