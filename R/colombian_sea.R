#' Colombian_sea Dataset
#'
#' The colmap dataset is a simple feature collection with 33 features and 6 fields. This version 
#' was obtained from marine regions page: "https://www.marineregions.org/stats_downloads.php"
#' 
#' @format Simple feature collection with 33 features and 11 fields:
#'   \describe{
#'    \item{MRGID}{id from original GDAM}
#'     \item{GEONAME}{id from original GDAM}
#'     \item{SOVEREIGN1}{Colombia.}
#'     \item{NAME_1}{Departamentos.}
#'     \item{DEPARTAMEN}{class name GDAM.}
#'     \item{geometry}{order name of GDAM.}
#'   }
#'
#'
#' @details This dataset is designed to provide users of mammalcol package with a companion map to
#' plot the mammal distribution per departamento.
#'
#' @examples
#' 
#' # Load the mammalcol package
#' library(mammalcol)
#' library (sf)
#' 
#' # Access the mammalcol_tab dataset
#' # data("colmap")
#'
#' # Display the first few rows
#' head(colmap)
#'
#' plot (colmap["NAME_1"])
#' 
#' @seealso
#' For more information about the "mammalcol" package and the data sources, visit
#' the package's GitHub repository: \url{https://github.com/dlizcano/mammalcol}
#'
#' @references
#' The dataset is based on the "List of the Mammals of Colombia" by Ramírez-Chaves 2021.
#'
#' @author
#' Data compilation: Ramírez-Chaves 2021, Package implementation: Cristian A. Cruz-R.
#'
#' @keywords internal
"Colombian_sea"
