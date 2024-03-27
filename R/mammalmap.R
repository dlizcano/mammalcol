
#' Plot a map Data for one species of the List of the Mammals of Colombia
#'
#' This function retrieve the locality data for one species in
#' the MammalCol pacakage dataset, and returns a map of Departamentos
#' where the species has been recorded.
#'
#' The function does not allows fuzzy matching, so the specie name should be correct. 
#' It is advised to run first the search_mammalcol function.
#'
#' @param species A character string containing the name of the species to plot the map.
#' 
#'
#' @return A map for the species.
#'
#' @examples
#'
#' species <- "Tapirus pinchaque" 
#' mammalmap(species)
#'
#' @importFrom mammalcol taxon
#' @importFrom mammalcol colmap
#' @export
mammalmap <- function(species){

  if (!requireNamespace("ggplot2", quietly = TRUE))
    install.packages("ggplot2")
  if (!requireNamespace("sf", quietly = TRUE))
    install.packages("sf")
  
  if (!is.character(species)) {
    stop(paste0("Argument species must be a character, not ", class(Species)))
  }
  
  # require("ggplot2")
  # require("sf")
  
  #load("data/colmap.rda")
  #load("data/taxon.rda")
  
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
  ggplot2::ggplot(colmap) +
    ggplot2::geom_sf(ggplot2::aes(fill = NAME_1)) +
    ggplot2::scale_fill_manual(values = deptos$fill) +
    # ggtitle(taxon$scientificName[25]) + #species name number
    ggplot2::labs(subtitle = taxon$scientificName[sp_id])+
    ggplot2::theme(legend.position="right", # locatio legend
            legend.title = ggplot2::element_blank(),#element_text(size=7),#,
            legend.text = ggplot2::element_text(size=7,), # text depto size
            plot.subtitle = ggplot2::element_text(face = "italic") # italica
    )#,
}
