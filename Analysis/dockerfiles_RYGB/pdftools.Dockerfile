## build command: docker build -f pdftools.Dockerfile -t asorgen/pdftools:v1 .
## Use for Diversity.R

FROM rocker/ropensci:latest

#1.) set shell to bash
SHELL ["/bin/bash", "-c"]
ARG DEBIAN_FRONTEND=noninteractive

#2.) Install pdftools R Packages
RUN Rscript -e "install.packages('stringr', dependencies=c('Depends', 'Imports') )" 
RUN Rscript -e "install.packages('pdftools', dependencies=c('Depends', 'Imports') )"

RUN apt-get update \
    && wget http://ftp.de.debian.org/debian/pool/contrib/m/msttcorefonts/ttf-mscorefonts-installer_3.7_all.deb -P ~/Downloads \
    && apt install ~/Downloads/ttf-mscorefonts-installer_3.7_all.deb -y \
    && apt-mark hold ttf-mscorefonts-installer

#3.) check that packages installed
RUN Rscript -e "library('pdftools');"

#5) Cleanup
RUN	apt-get clean && \
	find / -name *python* | xargs rm -rf && \
	rm -rf /tmp/* && \
	rm -rf /var/cache/* && \
	rm -rf /var/lib/apt/lists/* && \
	rm -rf /var/log/* 