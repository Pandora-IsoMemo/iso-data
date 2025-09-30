################################################################################
# This script tests the update of the Iso Database from external sources
#
# Scheduled to run once a week
#
# Author: Andreas Neudecker
# E-mail: andreas.neudecker@inwt-statistics.de
################################################################################


# 00 Preparation ---------------------------------------------------------------

Sys.setenv(TZ = "Europe/Berlin")
Sys.info()

# Empty workspace
rm(list = ls(all.names = TRUE))

# 01 start etl test-------------------------------------------------------------

# Load packages
devtools::load_all(".")

etlTest()

#etlMapping()

#cleanUp()

q(save = "no", status = 0)
