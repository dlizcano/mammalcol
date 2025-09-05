# procedure to generate taxon, distribution and vernacularname tables

### package flow
# 0. load pkgdown, usethis
# 1 load data objects
# 2 fix typos in data objects (deptos)
# 3 put in /R/sysdata.rda using: usethis::use_data(colmap, distribution, taxon, internal = TRUE, overwrite = TRUE)
# 4 check()
# 5 build_site()
# 6 update version in Description
# 7 add change to NEWS.MD
# 8 build new version using build()
# 9 upload (pull) to github
# 10 upload to cran using devtools::submit_cran()


require(readr)
require(geodata)
require(finch) # load the ipt.files
library(stringr)
library(tidyverse)
library(readxl)
library(sf)


###########
# read ipt
##########

ipt.files <-
  finch::dwca_read(
    "https://ipt.biodiversidad.co/sib/archive.do?r=mamiferos_col&v=1.18",
    read = T,
    na.strings = "",
    encoding = "UTF-8"
  )

taxon <- ipt.files$data$taxon.txt
distribution <- ipt.files$data$distribution.txt
vernacularname <- ipt.files$data$vernacularname.txt


####################
# read from had disk
####################

colmap <- sf::st_as_sf(geodata::gadm(country = "COL", level = 1, path = tempdir()))
# Let’s apply st_simplify with a tolerance of 1km:
colmap <- st_simplify(colmap, preserveTopology = TRUE, dTolerance = 1000)

# taxon <- read_delim("C:/Users/usuario/Downloads/mammal_col_2024/taxon.csv",
#                    delim = "\t", escape_double = FALSE)

# save to check and fix typos in distribution
write_csv(distribution, "C:/Users/usuario/Downloads/mammal_col_2024/distribution.csv")

# load after fixed several typos from ipt file
distribution <- read_csv("C:/Users/usuario/Downloads/mammal_col_2024/distribution.csv")



# load('data/distribution.rda') # Baltazar code to check typos in deptos name
distribution %>%
  select(id, locality) %>%
  nest_by(id) %>%
  mutate(dept = map(data, ~ .x %>%
    str_split("\\|") %>%
    unlist() %>%
    str_squish())) %>%
  unnest(cols = dept) %>%
  ungroup() %>%
  select(dept) %>%
  table() %>%
  View()
# notice must be 33 departamentos
# fix many typos in departamentos


# mammal global database
MDD <- read_csv("C:/Users/usuario/Downloads/mammal_col_2024/MDD_v1.12.1_6718species.csv")
# vernacularname <- read_delim("C:/Users/usuario/Downloads/mammal_col_2024/vernacularname.csv",
#                             delim = "\t", escape_double = FALSE,
#                             trim_ws = TRUE) %>% filter(language=="es")


redlist <- read_excel("C:/Users/usuario/Downloads/mammal_col_2024/Mammal_Evaluados_2021-2022.xlsx")
names(redlist) <- c("scientificName", "Year_eval", "redlist", "Taller")



####################
# table operations
####################
# add distribution and other columns to taxon

MDD$scientificName <- stringr::str_replace(MDD$sciName, "_", " ")


# left join
MamCol_MDD <- left_join(taxon, MDD, by = "scientificName")
MamCol_MDD$inMDD <- is.na(MamCol_MDD$sciName)
MamCol_redlist <- left_join(taxon, redlist, by = "scientificName")
MamCol_distribution <- left_join(taxon, distribution, by = "id")
MamCol_vernacular <- left_join(taxon, vernacularname, by = "id")

####
index_notMDD <- which(is.na(MamCol_MDD$sciName))
taxon$inMDD <- 1 # ifelse(is.na(MamCol_MDD$inMDD$inMDD), 0, 1) #All to 1
# convert true NA to 0
taxon$inMDD[index_notMDD] <- 0 # asign if is in MDD
taxon$Col_redlist <- MamCol_redlist$redlist # national redlist
taxon$distribution <- MamCol_distribution$locality # present in depto
taxon$source <- MamCol_distribution$source
index_endemic <- which(MamCol_distribution$establishmentMeans == "Endémica")
taxon$endemic <- "No"
taxon$endemic[index_endemic] <- "Yes"
taxon$english_name <- MamCol_MDD$mainCommonName
# taxon$spanish_name <- MamCol_vernacular$vernacularName
# taxon$name_language <- MamCol_vernacular$language


#######################
# remove noisy columns
taxon <- taxon[, -c(1, 2, 3, 5, 15, 17, 18)]
#######################

###################
# encoding problem
###################
fix.encoding <- function(df, originalEncoding = "UTF-8") {
  numCols <- ncol(df)
  df <- data.frame(df)
  for (col in 1:numCols)
  {
    if(class(df[, col]) == "character"){
      Encoding(df[, col]) <- originalEncoding
    }

    if(class(df[, col]) == "factor"){
      Encoding(levels(df[, col])) <- originalEncoding
    }
  }
  return(as.data.frame(df))
}


# mammal_colombia_2024 <- fix.encoding(taxon) # rename

# save as RDS
save(taxon, file = "C:/CodigoR/Mammal_Col/mammalcol/data/taxon.rda")
# load(file="C:/CodigoR/Mammal_Col/MammalCol/data/taxon.rda")#, encoding = "UTF-8")
save(colmap, file = "C:/CodigoR/Mammal_Col/mammalcol/data/colmap.rda")
save(distribution, file = "C:/CodigoR/Mammal_Col/mammalcol/data/distribution.rda")



##############################
# hex package to make the logo
##############################

library(showtext)
## Loading Google fonts (http://www.google.com/fonts)
# font_add_google("Gochi Hand", "gochi")
font_add_google("Open Sans")
## Automatically use showtext to render text for future devices
showtext_auto()

library(magick)
library(hexSticker)
img.n <- image_read("C:/CodigoR/Mammal_Col/MammalCol_old/man/figures/SCMas_Small.png")
# SCMas_png <- image_convert(img.n, "png")
image_info(img.n)
sticker(img.n,
  package = "mammalcol", p_size = 20, s_x = 1, s_y = .85,
  s_width = 1.3, s_height = 1.3,
  h_size = 1.5,
  p_color = "#0c0706",
  p_family = "Open Sans",
  p_fontface = "bold",
  h_color = "#4a7092",
  h_fill = "#F0F8FF",
  filename = "inst/figures/mammalcol_hex.png"
)




#####################
# ocurrence by Depto
#####################

occurrence <- function(states, type = c("any", "only", "all"), taxa = NULL) {
  if (length(states) == 0) stop("Please provide at least one Colombian Departamento")
  type <- match.arg(type)
  states <- sort(states)
  # states <- paste("BR-", states, sep = "")
  if (length(states) == 0) stop("Please provide at least one Colombian Departamento")
  # res <- lapply(occurrences, match, states)
  if (type == "any") {
    # res <- lapply(res, function(x) any(!is.na(x)))
    res <- subset(distribution, grepl(paste(states, collapse = "|"), occurrence))
  }
  if (type == "only") {
    res <- subset(distribution, grepl(paste("^", paste(states, collapse = "\\|"), "$", sep = ""), occurrence))
  }
  if (type == "all") {
    res <- subset(distribution, grepl(paste(states, collapse = ".*"), occurrence))
  }
  # res <- distribution[unlist(res), ]
  if (nrow(res) == 0) {
    return(NA)
  }
  if (is.null(taxa)) {
    merge(all.taxa[, c("id", "family", "search.str")], res[, c("id", "occurrence")], by = "id")
  } else {
    merge(all.taxa[all.taxa$search.str %in% taxa, c("id", "family", "search.str")], res[, c("id", "occurrence")], by = "id")
  }
}



#### test
# test <- subset(distribution, grepl(paste("^", paste("Atlántico" , collapse = "\\|"), "$", sep = ""), taxon))

distribution_list <-
  strsplit(distribution$locality, "\\|") # trimws () removes spaces

# trimws(distribution_list[[55]])

mammalmap <- function(species, legend = TRUE) {
  if (missing(species)) {
    stop("Argument species was not included")
  }

  if (!is.character(species)) {
    stop(paste0("Argument species must be a character, not ", class(species)))
  }

  if (!is.logical(legend)) {
    stop(paste0("Argument legend must be logical, not ", class(legend)))
  }

  distribution_list <-
    strsplit(taxon$distribution, "\\|") # trimws () removes spaces

  deptos <- as.data.frame(cbind(Depto = unique(colmap$NAME_1), fill = "white"))
  sp_id <- which(taxon$scientificName == species)
  unos <- trimws(distribution_list[[sp_id]]) # species number

  # nested loop to get deptos
  for (i in 1:length(deptos[, 1])) {
    for (j in 1:length(unos)) {
      if (deptos$Depto[i] == unos[j]) {
        deptos$fill[i] <- "blue"
      }
    }
  }

  # make the map
  # if legend true
  if (legend == TRUE) {
    mapa <- ggplot2::ggplot(colmap) +
      ggplot2::geom_sf(ggplot2::aes(fill = NAME_1)) +
      ggplot2::scale_fill_manual(values = deptos$fill) +
      # ggtitle(taxon$scientificName[25]) + #species name number
      ggplot2::labs(subtitle = taxon$scientificName[sp_id]) +
      ggplot2::theme(
        legend.position = "right", # location legend
        legend.title = ggplot2::element_blank(), # element_text(size=7),#,
        legend.text = ggplot2::element_text(size = 8, ), # text depto size
        plot.subtitle = ggplot2::element_text(face = "italic") # italica
      )
  } else { # if legend false
    mapa <- ggplot2::ggplot(colmap) +
      ggplot2::geom_sf(ggplot2::aes(fill = NAME_1), show.legend = FALSE) + # removes legend
      ggplot2::scale_fill_manual(values = deptos$fill) +
      # ggtitle(taxon$scientificName[25]) + #species name number
      ggplot2::labs(subtitle = taxon$scientificName[sp_id]) +
      ggplot2::theme(plot.subtitle = ggplot2::element_text(face = "italic")) # italica
  }

  return(mapa)
} # end mammalmap function






