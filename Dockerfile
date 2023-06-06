FROM inwt/r-batch:4.1.2

ADD . .

RUN url=$(Rscript get_mirror_date.R) \ 
    && sed -i "/MRAN/ c\options(repos = c(CRAN = \"${url}\"))" /usr/local/lib/R/etc/Rprofile.site \
    && installPackage 

CMD ["Rscript", "inst/RScripts/etl.R"]

## local testing
## docker build --pull -t tmp . && docker run --rm --network host tmp check
