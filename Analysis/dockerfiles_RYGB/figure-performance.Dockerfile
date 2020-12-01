## build command: docker build -f figure-performance.Dockerfile -t asorgen/fig-perform:v1 .
## Use for Figure_performance.R

FROM rocker/tidyverse:3.6.3

#1.) set shell to bash
SHELL ["/bin/bash", "-c"]
ARG DEBIAN_FRONTEND=noninteractive

#2.) Install R Packages, ggplot2 and its error-prone dependencies
RUN Rscript -e "install.packages('cowplot', dependencies=c('Depends', 'Imports') )" && \
    Rscript -e "install.packages('pROC', dependencies=c('Depends', 'Imports') )" && \
    Rscript -e "install.packages('yaml', dependencies=c('Depends', 'Imports') )"

#3.) check that packages installed
RUN Rscript -e "library('cowplot'); library('pROC'); library('yaml'); "

#4.) Cleanup
RUN	apt-get clean && \
	find / -name *python* | xargs rm -rf && \
	rm -rf /tmp/* && \
	rm -rf /usr/share/* && \
	rm -rf /var/cache/* && \
	rm -rf /var/lib/apt/lists/* && \
	rm -rf /var/log/*
