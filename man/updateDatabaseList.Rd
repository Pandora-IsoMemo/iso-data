% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/00-databases_updateList.R
\name{updateDatabaseList}
\alias{updateDatabaseList}
\title{Update Database List}
\usage{
updateDatabaseList(
  dataSourceName,
  datingType,
  coordType,
  mappingName,
  scriptFolder = "R"
)
}
\arguments{
\item{dataSourceName}{(character) name of the new data source, something like "xyDBname",
"14CSea", "CIMA", "IntChron", "LiVES". The name of the source must be contained exactly
as a column name in the mapping file.}

\item{datingType}{(character) dating type for the database, e.g. "radiocarbon" or "expert"}

\item{coordType}{(character) coordinate type of latitude and longitude columns; one of
"decimal degrees" (e.g. 40.446 or 79.982),
"degrees decimal minutes" ("40° 26.767' N" or "79° 58.933' W"),
"degrees minutes seconds" ("40° 26' 46'' N" or "79° 58' 56'' W")}

\item{mappingName}{(character) name of the mapping without file extension, e.g. "IsoMemo".
The mapping (a .csv file) must be available under "inst/mapping/".}

\item{scriptFolder}{(character) place to store the scripts.}
}
\description{
Updates the list of all data sources.
}
