
#' Plot a map for one species of the List of the Mammals of Colombia
#'
#' This function retrieve the locality data for one species in
#' the mammalcol pacakage dataset, and returns a map using ggplot2 of the 
#' departamentos where the species has been recorded.
#'
#' The function does not allows fuzzy matching, so the specie name should be correct. 
#' It is advised to run first the search_mammalcol function.
#'
#' @param species A character string containing the name of one species present in 
#' Colombia to plot a map of presence by departamento.
#' 
#' @param legend A logical (TRUE or FALSE) to get the legend in the map when is TRUE, 
#' or not if it is FALSE.
#' 
#'
#' @return A ggplot2 map for the species.
#'
#' @examples
#' species <- "Tapirus pinchaque" 
#' mammalmap(species, legend=FALSE)
#'
#' @importFrom mammalcol taxon
#' @importFrom mammalcol colmap
#' @export
mammalmap <- function(species, legend=TRUE){

  if (!requireNamespace("ggplot2", quietly = TRUE))
    install.packages("ggplot2")
  if (!requireNamespace("sf", quietly = TRUE))
    install.packages("sf")
  
  if (missing(species)) {
    stop("Argument species was not included")
  }
  
  if (!is.character(species)) {
    stop(paste0("Argument species must be a character, not ", class(species)))
  }
  
  if (!is.logical(legend)) {
    stop(paste0("Argument legend must be logical, not ", class(legend)))
  }
  
  # require("ggplot2")
  # require("sf")
  
  #load("data/colmap.rda")
  #load("data/taxon.rda")
  
  #data(mammalcol::taxon)
  #data(mammalcol::colmap)
  
  distribution_list <-
    strsplit(taxon$distribution, "\\|") # trimws () removes spaces
  
  deptos <- as.data.frame(cbind(Depto=unique(colmap$NAME_1), fill="white"))
  sp_id <- which(taxon$scientificName == species)
  unos <- trimws(distribution_list[[ sp_id ]]) # species number
  
  # nested loop to get deptos
  for (i in 1:length(deptos[,1])){
    for (j in 1:length(unos)){
      if(deptos$Depto[i]==unos[j]){deptos$fill[i] <- "blue"}
    }
  }
  
  # make the map
  # if legend true 
  if(legend==TRUE) {
    mapa <-   ggplot2::ggplot(colmap) +
      ggplot2::geom_sf(ggplot2::aes(fill = NAME_1)) +
      ggplot2::scale_fill_manual(values = deptos$fill) +
      # ggtitle(taxon$scientificName[25]) + #species name number
      ggplot2::labs(subtitle = taxon$scientificName[sp_id])+
      ggplot2::theme(legend.position="right", # location legend
                     legend.title = ggplot2::element_blank(),#element_text(size=7),#,
                     legend.text = ggplot2::element_text(size=8,), # text depto size
                     plot.subtitle = ggplot2::element_text(face = "italic") # italica
      )
  }else{ # if legend false
    mapa <-   ggplot2::ggplot(colmap) +
      ggplot2::geom_sf(ggplot2::aes(fill = NAME_1), show.legend = FALSE) + # removes legend
      ggplot2::scale_fill_manual(values = deptos$fill) +
      # ggtitle(taxon$scientificName[25]) + #species name number
      ggplot2::labs(subtitle = taxon$scientificName[sp_id]) +
      ggplot2::theme(plot.subtitle = ggplot2::element_text(face = "italic")
                      )# italica
  }
  
return(mapa)
} # end function
