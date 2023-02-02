# IsoMemo Data Package (iso-data)

## Infrastructure

![image](https://user-images.githubusercontent.com/16759098/216335554-864c2d9b-0200-48f5-b6b7-975f66b1fe74.png)

## Add a New Data Source

1. Define the new data source: Choose names `<datasource>`, `<datingType>` and `<coordType>`.
2. Execute one of the functions `createNewDBSource()` or `createNewFileSource()` to create a new 
file `R/02-<datasource>.R`. Respectively, two cases are possible:

   **a) data retrieved from a mySql database:** Here, database credentials 
   `<dbName>, <dbUser>, <dbPassword>, <dbHost>, <dbPort>` and the `<tableName>` must be specified.
   The credentials are not to be stored on Github. 
   
   They will not be stored in any file that will be uploaded to Github. They are only needed for
   local development and for testing the database connection.
   
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

   **b) data retrieved from a file:**
     - either from a **local file** in the `inst/extdata'` folder
   (` <location> = "local"`), or
     - from a **remote file** (`<location> = "remote"`). 
   Here, the `<remotePath>` must be given.
   
   Please, provide the `<filename>` (only `*.csv` or `*.xlsx` are supported). Optionally for `.xlsx` files,
   a `<sheetName>` can be specified.
 
   ```r
   createNewFileSource(dataSourceName = <datasource>,
                       datingType = <datingType>,
                       coordType = <coordType>,
                       fileName = <filename>,
                       locationType = <location>,
                       remotePath = <remotePath>,
                       sheetName = <sheetName>)
   ```

Executing one of the above function calls will automatically:

1. create a new file `R/02-<datasource>.R`,
2. define a new function `extract.<datasource>` in the new file `R/02-<datasource>.R`,
3. add a new entry in `R/00-databases.R`,
4. (only for mySql databases) create/update the `.Renviron` file that contains database credentials.

Files for sources `R/02-<datasource>.R` may contain individual and extensive data preparations that can be
adjusted manually, e.g. compare `R/02-LiVES.R`, and the next section 
"Modify An Existing Data Source".

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
