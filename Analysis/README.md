# Steps to Reproduce RYGB Analysis

## 1. Ensure that BioLockJ (v1.3.13 or newer) is on local system
BioLockJ - https://biolockj-dev-team.github.io/BioLockJ/Getting-Started/

## 2. Download RYGB_IntegratedAnalysis directory
git clone https://github.com/FarnazFouladi/RYGB_IntegratedAnalysis2020.git

## 3. Set up required software

### Option A) using docker

Install docker.
Docker Desktop - https://www.docker.com/products/docker-desktop

Make sure the ` docker run hello-world ` command runs successfully.

The docker images required for this pipeline will be automatically pulled from the docker hub as need.  The first time the pipeline runs, startup will be slow as images are downloaded. 

**_If_** the specified images cannot be retrieved, they can be built from the docker files.  See the BioLockJ/Analysis/dockerfiles folder.  Build instructions are included in each file.

### Option B) not using docker

Make sure R is installed.  See https://www.r-project.org/.  These scripts were written with 4.0.2.

Make sure all required R packages are installed                                

 * nlme
 * stringr
 * ggplot2
 * gridExtra
 * ggsignif
 * ggrepel
 * vegan
 * tidyverse
 * cowplot
 * pROC
 * yaml
 * ComplexHeatmap
 * reshape2
 * pdp
 * SIAMCAT

## 4. Run BioLockJ pipeline

Move to the Analysis folder:            
`cd <path/to/RYGB_IntegratedAnalysis2020>/Analysis`

To run the pipeline using **locally installed software**:                 
`biolockj RYGB_IntegreatedAnalysis.config`

To run the pipeline using **docker images**, add the -d argument:                                    
`biolockj -d RYGB_IntegreatedAnalysis.config`
