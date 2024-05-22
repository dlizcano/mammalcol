.onAttach <- function(lib, pkg) {
  packageStartupMessage("This is mammalcol ",
    utils::packageDescription("mammalcol",
      fields = "Version"
    ),
    appendLF = TRUE
  )
}


# -------------------------------------------------------------------------

show_progress <- function() {
  isTRUE(getOption("mammalcol.show_progress")) && # user disables progress bar
    interactive() # Not actively knitting a document
}



.onLoad <- function(libname, pkgname) {
  opt <- options()
  opt_mammalcol <- list(
    mammalcol.show_progress = TRUE
  )
  to_set <- !(names(opt_mammalcol) %in% names(opt))
  if (any(to_set)) options(opt_mammalcol[to_set])
  invisible()
}
