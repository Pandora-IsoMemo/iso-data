# This file contains the format of the environment variables that are mentioned in the template:
# inst/templates/template-extractFromDB.R
#
# The given variables will not be stored on gitHub but need to be specified in Jenkins
# Never upload this files with credentials to GitHub!
# Only use locally for database connections for development and when testing.
#
# Expected format for credentials:
#
# DBNAME_NAME='db'
# DBNAME_USER='user'
# DBNAME_PASSWORD='password'
# DBNAME_HOST='www.domain.com'
# DBNAME_PORT=1234

{{ dataSourceName }}_DBNAME='{{ dbName }}'
{{ dataSourceName }}_USER='{{ dbUser }}'
{{ dataSourceName }}_PASSWORD='{{ dbPassword }}'
{{ dataSourceName }}_HOST='{{ dbHost }}'
{{ dataSourceName }}_PORT={{ dbPort }}
