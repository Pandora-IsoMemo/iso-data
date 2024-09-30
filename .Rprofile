# When starting a new R session, a specific directory is added to the libPath.
# It's called libWin resp. libLinux. As it is on the first libPath position,
# packages are installed into this directory by default. This enables working in
# a sandbox.

.First <- function() {
  options(
    repos = c(
      getOption("repos"),
      INWTLab = "https://inwtlab.github.io/drat/",
      PANDORA = "https://Pandora-IsoMemo.github.io/drat/"
    )
  )
  # Check operating system
  if (Sys.info()["sysname"] == "Windows") {
    # Add libWin with the full path to libPaths
    .libPaths(new = c(paste(getwd(), "libWin", sep = "/"), .libPaths()))
  } else if (Sys.info()["sysname"] == "Linux") {
    .libPaths(new = c(paste(getwd(), "libLinux", sep = "/"), .libPaths()))
  }
}

.First()
