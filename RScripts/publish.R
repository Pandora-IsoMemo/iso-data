options(dratRepo = getwd())

check <- devtools::check()

if (length(check$errors) == 0){
  tmp <- tempdir()
  pkg_path <- devtools::build(path = tmp)

  drat::insertPackage(file = pkg_path, commit = TRUE)

  # switch back to master branch
  repo <- git2r::init(getwd())
  git2r::checkout(repo, "master")
}
