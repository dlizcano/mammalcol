#' Mammal occurrence by departamento
#' 
#' Find the mammal species that occur in a given departamento of Colombia
#' 
#' @param states a character vector with one or more departamento names
#' @param type type of matching to be used. \code{any} will return the mammal species that
#'   occur in any of the passed \code{states}. \code{only} matches mammal species that
#'   occur only in all provided (no more, no less) \code{states} and \code{all} matches 
#'   mammal species that occur at least in all \code{states} passed. See examples.
#' @param taxa optional character vector to match against the departamentos. Use the order name
#' @export
#' @return a data frame
#' @examples
#' \dontrun{
#' occ.any <- sp_by_depto(c("Arauca", "Norte de Santander"), type = "any")
#' occ.only <- sp_by_depto(c("Norte de Santander"), type = "only")
#' occ.all <- sp_by_depto(c("Arauca", "Norte de Santander"), type = "all")
#' occ.taxa <- sp_by_depto(c("Arauca", "Norte de Santander"), type = "all", taxa = "Chiroptera")
#' 
#' head(occ.any)
#' head(occ.only)
#' head(occ.all)
#' head(occ.taxa)
#' }
#' 
sp_by_depto <- function(states, type = c("any", "only", "all"), taxa = NULL) {
  if (length(states) == 0) stop("Please provide at least one Colombian Departamento")
  type <- match.arg(type)
  states <- sort(states)
  # states <- paste("BR-", states, sep = "")
  if (length(states) == 0) stop("Please provide at least one Colombian Departamento")
  # res <- lapply(occurrences, match, states)
  if (type == "any") {
    #res <- lapply(res, function(x) any(!is.na(x)))
    res <- subset(distribution, grepl(paste(states, collapse = "|"), locality))
  }
  if (type == "only") {
    res <- subset(distribution, grepl(paste("^", paste(states, collapse = "\\|"), "$", sep = ""), locality))
  }
  if (type == "all") {
    res <- subset(distribution, grepl(paste(states, collapse = ".*"), locality))
  }
  # res <- distribution[unlist(res), ]
  if (nrow(res) == 0) {
    return(NA)
  }
  if (is.null(taxa)) {
    merge(taxon[, c("scientificName", "family", "order",  "id")], res[, c("id", "locality")], by = "id")[,-1]
    # removes id
  } else {
    merge(taxon[taxon$order %in% taxa, c("scientificName", "family", "order",  "id" )], res[, c("id", "locality")], by = "id")[,-1]
    # removes id
  }
}
