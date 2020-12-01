## build command: docker build -f nlme.Dockerfile -t asorgen/nlme:v1 .
## Use this for a lot of the R scripts

FROM r-base:3.6.3

#1.) set shell to bash
SHELL ["/bin/bash", "-c"]
ARG DEBIAN_FRONTEND=noninteractive

#2.) Install R Packages 
RUN Rscript -e "install.packages('nlme', dependencies=c('Depends', 'Imports') )" 
RUN Rscript -e "install.packages('stringr', dependencies=c('Depends', 'Imports') )" 

#3.) check that packages installed
RUN Rscript -e "library('nlme'); "

#4.) Cleanup
RUN	apt-get clean && \
	find / -name *python* | xargs rm -rf && \
	rm -rf /tmp/* && \
	rm -rf /usr/share/* && \
	rm -rf /var/cache/* && \
	rm -rf /var/lib/apt/lists/* && \
	rm -rf /var/log/*
