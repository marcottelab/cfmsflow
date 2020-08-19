#Download base image ubuntu 20.04
FROM ubuntu:20.04
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
#    cmake \
#    build-essential \
#    gcc-multilib \
 

RUN apt-get update && apt-get install --yes --no-install-recommends \
   wget \
   git \
   python3 \
   python3-pip 
   #r-base

# Have python command run python3
RUN ln -s /usr/bin/python3 /usr/bin/python && \
    ln -s /usr/bin/pip3 /usr/bin/pip

#FROM python:3

WORKDIR /usr/src/app

COPY requirements.txt ./

RUN pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

COPY . .


# Install R
#RUN echo "deb http://cran.rstudio.com/bin/linux/debian jessie-cran3/" >>  /etc/apt/sources.list &&\
#apt-key adv --keyserver keys.gnupg.net --recv-key 381BA480 &&\
#apt-get update --fix-missing && \


#RUN apt-get -y install r-base

# Install R libraries
#RUN R -e 'install.packages("igraph", repos="http://cloud.r-project.org/"); install.packages("dendextend",repos="http://cloud.r-project.org/"); install.packages("dplyr",repos="http://cloud.r-project.org/")'
#RUN git clone https://github.com/marcottelab/run_TPOT.git /opt/run_TPOT

RUN git clone --single-branch --branch pandas_update_fix https://github.com/marcottelab/protein_complex_maps.git /opt/protein_complex_maps

RUN git clone --single-branch --branch master https://github.com/marcottelab/run_TPOT.git /opt/run_TPOT





ENV PYTHONPATH "${PYTHONPATH}:/opt/protein_complex_maps"

