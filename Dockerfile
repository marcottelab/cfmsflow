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
    r-base

# Install R
#RUN echo "deb http://cran.rstudio.com/bin/linux/debian jessie-cran3/" >>  /etc/apt/sources.list &&\
#apt-key adv --keyserver keys.gnupg.net --recv-key 381BA480 &&\
#apt-get update --fix-missing && \
RUN apt-get -y install r-base

# Install R libraries
#RUN R -e 'install.packages("ROCR", repos="http://cloud.r-project.org/"); install.packages("randomForest",repos="http://cloud.r-project.org/")'
#RUN git clone https://github.com/marcottelab/run_TPOT.git /opt/run_TPOT




