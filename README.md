# IsoMemo Data Package (iso-data)

## Infrastructure
![Infrastructure](https://user-images.githubusercontent.com/16759098/216335554-864c2d9b-0200-48f5-b6b7-975f66b1fe74.png)

## Content

This ReadMe contains instructions on how to:

- [Add a New Data Source](#add-a-new-data-source)
- [Modify an Existing Data Source](#modify-an-existing-data-source)
- [Test the ETL process of the Data Sources](#test-the-etl-process-of-the-data-sources)
- [Test the Code](#test-the-code)
- [Deployment](#deployment)
- [Access to Data](#access-to-data)

## Add a New Data Source

There are two ways to add a new data source depending on where data is retrieved from:
  
1. data source retrieved from a **mySql database** -> execute function `createNewDBSource()`
2. data source retrieved from a **local or remote file** -> execute function `createNewFileSource()`

Executing one of the functions

- `createNewDBSource()` or 
- `createNewFileSource()`

will automatically:

1. create a new file `R/02-<datasource>.R` that contains the function to extract the data: `extract.<datasource>()`,
2. add a new entry for the source into the file `R/00-databases.R`,
3. (only for mySql databases) create/update the `.Renviron` file that contains database credentials.

The Files `R/02-<datasource>.R` for different data sources may contain individual and extensive data
preparations that can be adjusted manually. For details compare e.g. `R/02-LiVES.R`, and read the 
section [Modify An Existing Data Source](#modify-an-existing-data-source).

### Specify the type of data

For both ways to add data sources (from **database** or from **file**), four mandatory parameters must be specified:

- `dataSourceName`: (character) name of the new data source, something like "xyDBname", "14CSea", "CIMA", "IntChron", "LiVES". The name of the source must be contained exactly as a column name in the mapping file.
- `datingType`: (character) dating type for the database, e.g. "radiocarbon" or "expert"
- `coordType`: (character) coordinate type of latitude and longitude columns, one of
  - "decimal degrees", e.g. `40.446` or `79.982`,
  - "degrees decimal minutes", e.g. `40° 26.767' N` or `79° 58.933' W`,
  - "degrees minutes seconds", e.g. `40° 26' 46'' N` or `79° 58' 56'' W`
- `mappingName`: (character) name of the mapping without file extension, e.g. "IsoMemo". The mapping (a .csv file) must be available under "inst/mapping/".

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
                  mappingName = <mappingName>,
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

Optionally, the following can be specified

- for `.xlsx` files, a `<sheetNumber>` as integer value
- for `.csv` files, `<sep>` for field separator character, and `<dec>` for the character used for decimal points
 
```r
createNewFileSource(dataSourceName = <datasource>,
                    datingType = <datingType>,
                    coordType = <coordType>,
                    mappingName = <mappingName>,
                    fileName = <filename>,
                    locationType = <location>,
                    remotePath = <remotePath>,
                    sheetNumber = 1,
                    sep = ";",
                    dec = ",")
```

## Modify an Existing Data Source
Data extraction for all data sources are defined in the files `R/02-<datasource>.R`. Within the function `extract.<datasource>()` you can retrieve data, modify values as you like. You only need to ensure these points:

- (_done automatically_) the function name needs to be `extract.<datasource>`. `<datasource>` needs to match the entry `name` in the file `R/00-databases.R`
- the function needs to have a single argument `x`. `x` holds all configuration from the entry in `R/00-databases.R`
- the retrieved data needs to be a single data.frame. Assign this to the list element `x$dat` and return `x`
- only variables in the data frame which are part of the mapping `<mappingId>` that must be available under `inst/mapping/<mappingId>.csv` and that is specified in `R/00-databases.R` will be processed.

A minimal example of the extract function looks like this

```r
extract.testdb <- function(x) {
    dat <- mtcars # dummy dataset

    x$dat <- dat # assign data to list element x$dat

    x # return x
}
```

## Test the ETL process of the Data Sources

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

## Test the Code

Test your code by running

```
devtools::check()
```

## Deployment

Code from the main branch will be automatically deployed to the dev system on the MPI server (given successful `devtools::check()`) and will be on the beta version of the API and App

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
