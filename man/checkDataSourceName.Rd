% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/00-createNewSource_fromDB.R
\name{checkDataSourceName}
\alias{checkDataSourceName}
\title{Check Data Source Name}
\usage{
checkDataSourceName(dataSourceName, isTest = FALSE)
}
\arguments{
\item{dataSourceName}{(character) name of the new data source, something like "xyDBname",
"14CSea", "CIMA", "IntChron", "LiVES". The name of the source must be contained exactly
as a column name in the mapping file.}

\item{isTest}{(logical) TRUE if testing}
}
\description{
Check Data Source Name
}
