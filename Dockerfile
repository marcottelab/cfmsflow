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
   # Need one of these three libs for igraph to work
   # Do process of elimination
    gfortran-7\
   libxml2-dev \
   libglpk-dev \
    python3 \
   python3-pip 

## Have python command run python3
RUN ln -s /usr/bin/python3 /usr/bin/python && \
    ln -s /usr/bin/pip3 /usr/bin/pip

# Install python packages
WORKDIR /usr/src/app

COPY requirements.txt ./

RUN pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

COPY . .

# Install R packages
RUN install2.r --error \
    igraph \
    dendextend 

# Get repositories
RUN git clone --single-branch --branch pandas_update_fix https://github.com/marcottelab/protein_complex_maps.git /indocker_repos/protein_complex_maps

RUN git clone --single-branch --branch master https://github.com/marcottelab/run_TPOT.git /indocker_repos/run_TPOT

# Set environmental variables
ENV PYTHONPATH "${PYTHONPATH}:/indocker_repos/protein_complex_maps"
ENV R_LIBS_SITE "${R_LIBS_SITE}:/usr/local/lib/R/site-library"
ENV LD_LIBRARY_PATH "${LD_LIBRARY_PATH}:/usr/local/lib/R/lib:/usr/local/lib:/usr/lib/x86_64-linux-gnu:/usr/lib/jvm/java-11-openjdk-amd64/lib/server"
