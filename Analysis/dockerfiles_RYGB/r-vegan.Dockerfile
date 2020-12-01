## build command: docker build -f r-vegan.Dockerfile -t asorgen/r-vegan:v1 .
## Use for pco.R

FROM r-base:3.6.3

#1.) set shell to bash
SHELL ["/bin/bash", "-c"]
ARG DEBIAN_FRONTEND=noninteractive

#2.) Install vegan R Packages
RUN Rscript -e "install.packages('vegan', dependencies=c('Depends', 'Imports') )"
RUN Rscript -e "install.packages('stringr', dependencies=c('Depends', 'Imports') )" 
RUN Rscript -e "install.packages('nlme', dependencies=c('Depends', 'Imports') )" 

#3.) Install R Packages for ggplot2
RUN Rscript -e "install.packages('testthat', dependencies=c('Depends', 'Imports') )" && \
    Rscript -e "install.packages('isoband', dependencies=c('Depends', 'Imports') )" && \
    Rscript -e "install.packages('ggplot2', dependencies=c('Depends', 'Imports') )"

#4.) check that packages installed
RUN Rscript -e "library('vegan'); library('stringr'); library('ggplot2'); library('nlme');"

#5) Cleanup
RUN	mv /usr/share/texmf/fonts /fonts && \
	apt-get clean && \
	find / -name *python* | xargs rm -rf && \
	rm -rf /tmp/* && \
	rm -rf /usr/share/* && \
	rm -rf /var/cache/* && \
	rm -rf /var/lib/apt/lists/* && \
	rm -rf /var/log/* && \
	mkdir /usr/share/texmf/ && \
	mv /fonts /usr/share/texmf/fonts
