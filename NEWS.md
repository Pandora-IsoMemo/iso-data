# MpiIsoData

## Version 23.03.1

### New features

- option to add a new mapping and new sources was added to the functions `createNewDBSource()` and `createNewDBSource()`

### Updates
- update of the README.md with the description on how to add new sources and a new mapping

## Version 22.06.1

### New features

- new functions `createNewDBSource()` and `createNewDBSource()` in order to add a new source to the existing mapping. The functions can automatically 
  - create a new script `R/02-<datasource>.R`
  - add an entry to `R/00-databases.R`
  - update the `.Renviron` for mysql database sources

### Updates
- update of the README.md with the new description how to add a new source to the existing mapping
