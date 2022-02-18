FROM mariadb:10.1.31

ENV MYSQL_ROOT_PASSWORD root
ENV TZ "Europe/Berlin"

ADD ./*.sql /docker-entrypoint-initdb.d/

EXPOSE 3306

# Local testing of DB:
# docker build -t mpi-db inst/db/ && docker run --name mpi-db -p 3306:3306 --rm mpi-db

## ON MPI-ISO-DB
## docker build -t mpi-db inst/db/ && docker run \
##         -d \
##         --network host \
##         --name stakesapidb \
##         -v /var/lib/mysql:/var/lib/mysql \
##         --restart unless-stopped \
##         mpi-db