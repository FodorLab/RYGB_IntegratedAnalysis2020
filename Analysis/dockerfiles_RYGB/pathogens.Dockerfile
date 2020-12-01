## build command: docker build -f pathogens.Dockerfile -t asorgen/pathogens:v1 .
## Use for OpportunisticPathogens.R, Diversity.R

FROM r-base:3.6.3

#1.) set shell to bash
SHELL ["/bin/bash", "-c"]
ARG DEBIAN_FRONTEND=noninteractive

#2.) Install R Packages 
RUN Rscript -e "install.packages('testthat', dependencies=c('Depends', 'Imports') )" && \
    Rscript -e "install.packages('isoband', dependencies=c('Depends', 'Imports') )" && \
    Rscript -e "install.packages('ggplot2', dependencies=c('Depends', 'Imports') )"

#3.) Install more R Packages
RUN Rscript -e "install.packages('ggsignif', dependencies=c('Depends', 'Imports') )" && \
    Rscript -e "install.packages('reshape2', dependencies=c('Depends', 'Imports') )" && \
    Rscript -e "install.packages('stringr', dependencies=c('Depends', 'Imports') )" && \
    Rscript -e "install.packages('nlme', dependencies=c('Depends', 'Imports') )" && \
    Rscript -e "install.packages('pdp', dependencies=c('Depends', 'Imports') )"

#4.) check that packages installed
RUN Rscript -e "library('ggplot2'); library('ggsignif'); library('reshape2'); library('stringr'); library('nlme'); library('pdp'); "

#5.) Cleanup
RUN	apt-get clean && \
	find / -name *python* | xargs rm -rf && \
	rm -rf /tmp/* && \
	rm -rf /usr/share/* && \
	rm -rf /var/cache/* && \
	rm -rf /var/lib/apt/lists/* && \
	rm -rf /var/log/*