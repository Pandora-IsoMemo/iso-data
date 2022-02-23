FROM inwt/r-batch:4.1.2

ADD . .

RUN installPackage

CMD ["Rscript", "inst/RScripts/etl.R"]

## local testing
## docker build --pull -t tmp . && docker run --rm --network host tmp check
