# IsoMemo Data Package (iso-data)

## Modify Data Sources

Data extraction for all data sources are defined in the files `R/02-<datasource>.R`. Within the function `extract.<datasource>.R` you can retrieve data, modify values as you like. You only need to ensure these points:

- the function name needs to be `extract.<datasource>`. `<datasource>` needs to match the entry `name` in the file `R/00-databases.R`
- the function needs to have a single argument `x`. `x` holds all configuration from the entry in `R/00-databases.R`
- the retrieved data needs to be a single data.frame. Assign this to the list element `x$dat` and return `x`
- only variables in the data frame which are part of `inst/mapping/Field_Mapping.csv` will be processed

A minimal example of the extract function looks like this

```r
extract.testdb <- function(x) {
    dat <- mtcars # dummy dataset

    x$dat <- dat # assign data to list element x$dat

    x # return x
}
```

## Add New Data Source

1. Create a new file `R/02-<datasource>.R`, i.e. from the template in `02-template-db.R` (data retrieved from database) or `02-template-file.R` (data retrieved from static file in `inst/'` folder)
2. Set the function name to `extract.<datasource>`
3. Add an entry in `R/00-databases.R`. Specify `name`, `datingType` and `coordType` for this database in this file


## Test Data Sources

Run the following commands in R to install the package locally and run the extract function.

```r
devtools::install() # install package locally
devtools::load_all() # load all functions from package

res <- test()
```

Inspect the results in test. Data from the nth datasource will be in the element `res[[n]]$dat`

IMPORTANT: Only 5 rows will be processed during the test! If you want to process all data specify `full = TRUE`:

```r
res <- test(full = TRUE)
```

To test only the n-th datasource execute the function like this
```r
res <- test(databases()[n])
```

Results will be in the object res[[1]]$dat

## Test

Test your code by running

```
devtools::check()
```

## Deployment

Code from the master branch will be automatically deployed to the dev system on the MPI server (given successful `devtools::check()`) and will be on the beta version of the API and App

Code from the depl branch will be deployed to the production sytems (API and App)

## Access to Data

data is returned in JSON format

- IsoData: https://isomemodb.com/testapi/v1/iso-data

You can use the following parameters:

- dbsource
- category
- field

Example call:

https://isomemodb.com/api/v1/iso-data?dbsource=LiVES&category=Location&field=site,longitude

Helper endpoints

- Databases: https://isomemodb.com/testapi/v1/dbsources
- Mapping: https://isomemodb.com/testapi/v1/mapping

For the production api use /api instead of /testapi
