#Download base image ubuntu 20.04
#FROM ubuntu:20.04
#FROM rocker/r-ver:3.6.2
FROM rocker/tidyverse:latest
#Now add detailed information about the custom image using the LABEL instruction.

# LABEL about the custom image
LABEL maintainer="claire.mcwhite@utexas.edu"
LABEL version="0.1"
LABEL description="This is custom Docker Image for \
the cfmsflow pipeline."


# File Author / Maintainer
MAINTAINER clairemcwhite <claire.mcwhite@utexas.edu>

# Prevents interactive tzdata question 
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=America/New_York

#    locales \
#    vim-tiny \
 


RUN apt-get update && apt-get install --yes --no-install-recommends \
   wget \
   git \
#   make \ 
#   gcc-multilib \
#   cmake \
#    build-essential 
    #gcc-7 \
#    g++-7 \
   # Need one of these three libs for igraph to work
   # Do process of elimination
    gfortran-7\
   libxml2-dev \
   libglpk-dev \
   #
    python3 \
   python3-pip 
  # r-base

# Install R libraries
#RUN R -e "install.packages('igraph',dependencies=TRUE, version = '1.0.0', repos='http://cran.rstudio.com/')"

#RUN R -e "install.packages('dendextend',dependencies=TRUE, repos='http://cran.rstudio.com/')"
#RUN R -e "install.packages('dplyr',dependencies=TRUE, repos='http://cran.rstudio.com/')"
#
#
## Have python command run python3
RUN ln -s /usr/bin/python3 /usr/bin/python && \
    ln -s /usr/bin/pip3 /usr/bin/pip
#
##FROM python:3
#
WORKDIR /usr/src/app
#
COPY requirements.txt ./
#
RUN pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt
#
COPY . .
#
#
## Install R
##RUN echo "deb http://cran.rstudio.com/bin/linux/debian jessie-cran3/" >>  /etc/apt/sources.list &&\
##apt-key adv --keyserver keys.gnupg.net --recv-key 381BA480 &&\
##apt-get update --fix-missing && \
#
#
##RUN apt-get -y install r-base
#
## Start new stage
##FROM rocker/tidyverse:latest
##COPY --from=0 . .
#
#
## Install R packages
 
#

RUN install2.r --error \
    igraph \
    dendextend 
#

#
##RUN R -e 'install.packages("igraph", repos="http://cloud.r-project.org/"); install.packages("dendextend",repos="http://cloud.r-project.org/"); install.packages("dplyr",repos="http://cloud.r-project.org/")'
#
RUN git clone --single-branch --branch pandas_update_fix https://github.com/marcottelab/protein_complex_maps.git /opt/protein_complex_maps
#
RUN git clone --single-branch --branch master https://github.com/marcottelab/run_TPOT.git /opt/run_TPOT
#
#
#
#
#
ENV PYTHONPATH "${PYTHONPATH}:/opt/protein_complex_maps"
ENV R_LIBS_SITE "${R_LIBS_SITE}:/usr/local/lib/R/site-library"
#ENV LD_LIBRARY_PATH "/usr/local/lib/R/site-library/:${LD_LIBRARY_PATH}"
#/usr/local/lib/R/site-library
#
