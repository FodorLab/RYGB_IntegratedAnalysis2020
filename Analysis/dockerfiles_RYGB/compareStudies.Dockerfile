## build command: docker build -f compareStudies.Dockerfile -t asorgen/comparestudies:v1 .
## Use for SequenceVariantAnalysis.R, compareStudies_*.R

FROM r-base:3.6.3

#1.) set shell to bash
SHELL ["/bin/bash", "-c"]
ARG DEBIAN_FRONTEND=noninteractive

#2.) Install R Packages, ggplot2 and its error-prone dependencies
RUN Rscript -e "install.packages('testthat', dependencies=c('Depends', 'Imports') )" && \
    Rscript -e "install.packages('isoband', dependencies=c('Depends', 'Imports') )" && \
    Rscript -e "install.packages('ggplot2', dependencies=c('Depends', 'Imports') )"
RUN Rscript -e "install.packages('stringr', dependencies=c('Depends', 'Imports') )" 

#3.) Install more R Packages
RUN Rscript -e "install.packages('gridExtra', dependencies=c('Depends', 'Imports') )" && \
    Rscript -e "install.packages('ggsignif', dependencies=c('Depends', 'Imports') )" && \
    Rscript -e "install.packages('ggrepel', dependencies=c('Depends', 'Imports') )"

#4.) check that packages installed
RUN Rscript -e "library('ggplot2'); library('gridExtra'); library('ggsignif'); library('ggrepel'); "

#5.) Cleanup
RUN	apt-get clean && \
	find / -name *python* | xargs rm -rf && \
	rm -rf /tmp/* && \
	rm -rf /usr/share/* && \
	rm -rf /var/cache/* && \
	rm -rf /var/lib/apt/lists/* && \
	rm -rf /var/log/*
