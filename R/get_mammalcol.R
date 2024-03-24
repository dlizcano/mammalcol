
#' Retrieve Data from the List of the Mammals of Colombia
#'
#' This function takes a list of Mammal species names, searches for their data in
#' the MammalCol pacakage dataset, and returns a data frame containing the relevant
#' information for each species.
#'
#' The function allows fuzzy matching for species names with a maximum
#' distance threshold to handle potential typos or variations in species names.
#'
#' @param splist A character vector containing the names of the species to search for.
#' @param max_distance The maximum allowed distance for fuzzy matching of species names.
#'   Defaults to 0.2.
#'
#' @return A data frame containing the retrieved information for each species.
#'
#' @examples
#'
#' splist <- c("Tapirus bairdii", "Tapirus pinchaque", "Tapirus terrestris",
#'             "Tapirus terrestris", "tapir terrestre", "Pudu mephistophiles")
#'
#' search_mammalcol(splist)
#'
#' @export
search_mammalcol <- function(splist, max_distance = 0.2) {
  # Defensive function here, check for user input errors
  if (is.factor(splist)) {
    splist <- as.character(splist)
  }
  # Fix species name
  splist_st <- standardize_names(splist)
  dupes_splist_st <- find_duplicates(splist_st)

  if(length(dupes_splist_st) != 0 ){
    message("The following names are repeated in the 'splist': ",
            paste(dupes_splist_st, collapse = ", "))
  }
  splist_std <- unique(splist_st)

  # create an output data container
  output_matrix <- matrix(nrow = length(splist_std), ncol = 21) # two more
  colnames(output_matrix) <- c("name_submitted",
                               names(mammalcol::mammal_colombia_2024), 
                               "Distance")
  
  # loop code to find the matching string

  for (i in seq_along(splist_std)) {
    # Standardise max distance value
    if (max_distance < 1 & max_distance > 0) {
      max_distance_fixed <- ceiling(nchar(splist_std[i]) * max_distance)
    } else {
      max_distance_fixed <- max_distance
    }

    # fuzzy and exact match
    matches <- agrep(splist_std[i],
                     mammalcol::mammal_colombia_2024$scientificName, # base data column
                     max.distance = max_distance_fixed,
                     value = TRUE)

    # check non matching result
    if (length(matches) == 0) {
      row_data <- rep("nill", 19) # number of columns
    }
    else if (length(matches) != 0){ # match result
      dis_value <- as.numeric(utils::adist(splist_std[i], matches))
      matches1 <- matches[dis_value <= max_distance_fixed]
      dis_val_1 <- dis_value[dis_value <= max_distance_fixed]

      if (length(matches1) == 0){
        row_data <- rep("nill", 19) # number of columns
      }
      else if (length(matches1) != 0){
        row_data <- as.matrix(mammalcol::mammal_colombia_2024[mammalcol::mammal_colombia_2024$scientificName %in% matches1,])
      }
    }

    # distance value
    if(is.null(nrow(row_data))){
      dis_value_1 <- "nill"
    } else{
      dis_value_1 <- utils::adist(splist_std[i], row_data[,2])
    }

    output_matrix[i, ] <-
      c(splist_std[i], row_data, dis_value_1)
  }

  # Output
  output <- as.data.frame(output_matrix)
  # rownames(output) <- NULL
  output <- output[,-2]# delete the id column
  return(output[output$scientificName != "nill",])
}

