# IsoMemo Data Package (iso-data)

## Infrastructure
![Infrastructure](https://user-images.githubusercontent.com/16759098/216335554-864c2d9b-0200-48f5-b6b7-975f66b1fe74.png)

## Add a New Data Source

There are two ways to define a new data source:
  
1. data source retrieved from a **mySql database**
2. data source retrieved from a **local or remote file**

Executing one of the functions

- `createNewDBSource()` or 
- `createNewFileSource()`

will automatically:

1. create a new file `R/02-<datasource>.R`,
2. define a new function `extract.<datasource>` in the new file `R/02-<datasource>.R`,
3. add a new entry in `R/00-databases.R`,
4. (only for mySql databases) create/update the `.Renviron` file that contains database credentials.

The Files `R/02-<datasource>.R` for different data sources may contain individual and extensive data
preparations that can be adjusted manually. For details compare e.g. `R/02-LiVES.R`, and read the 
section [Modify An Existing Data Source](#modify-an-existing-data-source).

### Specify the type of data

For both data sources, **database** and **file**, three mandatory parameters must be specified:

- `dataSourceName`: (character) name of the new data source, e.g. "14CSea", "CIMA", "IntChron", "LiVES"
- `datingType`: (character) dating type, e.g. "radiocarbon" or "expert"
- `coordType`: (character) coordinate type of latitude and longitude columns, one of
  - "decimal degrees", e.g. `40.446` or `79.982`,
  - "degrees decimal minutes", e.g. `40° 26.767' N` or `79° 58.933' W`,
  - "degrees minutes seconds", e.g. `40° 26' 46'' N` or `79° 58' 56'' W`

### Specify the data source

#### MySql database:

Here, database credentials `<dbName>, <dbUser>, <dbPassword>, <dbHost>, <dbPort>` and the 
`<tableName>` must be specified. The credentials are not to be stored on Github, they will not be 
stored in any file that will be uploaded to Github. The credentials are only needed for local
development and for testing the database connection.
   
```r
createNewDBSource(dataSourceName = <datasource>,
                  datingType = <datingType>,
                  coordType = <coordType>,
                  dbName = <dbName>,
                  dbUser = <dbUser>,
                  dbPassword = <dbPassword>,
                  dbHost = <dbHost>,
                  dbPort = <dbPort>,
                  tableName = <tableName>)
```

#### File:

Data can be loaded either

- from a **local file** that must be stored in the `inst/extdata'` folder, or
- from a **remote file**, the `<remotePath>` must be given, e.g. `"http://www.14sea.org/img/"`
 
Please set `<location> = "local"` in the first case, and `<location> = "remote"` in the second case.

Please, provide the `<filename>` with extension (only `*.csv` or `*.xlsx` are supported), e.g. 
`"data.csv"`, `"14SEA_Full_Dataset_2017-01-29.xlsx"`

Optionally for `.xlsx` files, a `<sheetNumber>` as integer can be specified.
 
```r
createNewFileSource(dataSourceName = <datasource>,
                    datingType = <datingType>,
                    coordType = <coordType>,
                    fileName = <filename>,
                    locationType = <location>,
                    remotePath = <remotePath>,
                    sheetNumber = <sheetNumber>)
```

## Modify an Existing Data Source
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

Code from the main branch will be automatically deployed to the production system on the MPI server (given successful `devtools::check()`) and will be on the main version of the API and App.

Respectively, code from the beta branch will be automatically deployed to the beta version of the API and App.

## Access to Data

data is returned in JSON format

- IsoData: https://isomemodb.com/api/v1/iso-data
- IsoData (beta): https://isomemodb.com/testapi/v1/iso-data

You can use the following parameters:

- dbsource
- category
- field

Example call:

https://isomemodb.com/api/v1/iso-data?dbsource=LiVES&category=Location&field=site,longitude

Helper endpoints

- Databases: https://isomemodb.com/api/v1/dbsources
- Databases (beta): https://isomemodb.com/testapi/v1/dbsources
- Mapping: https://isomemodb.com/api/v1/mapping
- Mapping (beta): https://isomemodb.com/testapi/v1/mapping

For the production api use /api instead of /testapi
