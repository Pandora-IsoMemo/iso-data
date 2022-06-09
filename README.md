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

1. Specify the name `<datasource>`, `<datingType>` and `<coordType>` for the new data source.
2. Execute the following function to create a new file `R/02-<datasource>.R` with 
   a) data retrieved from a mySql database. Here, the `<tableName>` must be specified.
```r
createNewDBSource(dbName = <datasource>,
                  datingType = <datingType>,
                  coordType = <coordType>,
                  tableName = <tableName>,
                  descriptionCreator = NULL)
```
    b) data retrieved from a static `"local"` file in `inst/'` folder or from a `"remote"`
 `<location>`. If second the `<remotePath>` must be given.
 Provide the `<filename>` (only `*.csv` or `*.xlsx` are supported). Optionally for `.xlsx` files,
 a `<sheetName>` can be specified.
```r
createNewFileSource(dbName = <datasource>,
                    datingType = <datingType>,
                    coordType = <coordType>,
                    locationType = <location>,
                    remotePath = <remotePath>,
                    fileName = <filename>,
                    sheetName = <sheetName>,
                    descriptionCreator = NULL)
```


A column containing a description can be added to the new data source with the
`<descriptionCreator>`. E.g. 

- select a particular column `var`: `<descriptionCreator> = isoData$var` or
- paste two columns `var1` and `var2`: `<descriptionCreator> = paste(isoData$var1, isoData$var2)`.

Executing either `createNewDBSource` or `createNewFileSource` 

- creates a new file `R/02-<datasource>.R`,
- sets the function name to `extract.<datasource>` in the new file `R/02-<datasource>.R`,
- an entry in `R/00-databases.R` will be added automatically,
- for mySql databases an `.Renviron` file will be created/updated that containes placeholders for
database credentials.

The files `R/02-<datasource>.R` can contain individual and extensive data preparations that can be
added manually, e.g. compare `R/02-LiVES.R`.

## Test Data Sources

Run the following commands in R to install the package locally and run the extract function.

```r
devtools::install() # install package locally
devtools::load_all() # load all functions from package

res <- etlTest()
```

Inspect the results in test. Data from the nth datasource will be in the element `res[[n]]$dat`

IMPORTANT: Only 5 rows will be processed during the test! If you want to process all data specify `full = TRUE`:

```r
res <- etlTest(full = TRUE)
```

To test only the n-th datasource execute the function like this
```r
res <- etlTest(databases()[n])
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
