FROM continuumio/miniconda3

# This package requires python 3, GNU parallel, and R packages plyr and ggplot2.  

MAINTAINER Matthew Wyczalkowski <m.wyczalkowski@wustl.edu>

RUN conda create -n env python=3.6
RUN echo "source activate env" > ~/.bashrc
ENV PATH /opt/conda/envs/env/bin:$PATH

# run update
RUN apt-get update -y && apt-get install -y \
    libnss-sss \
    vim 

RUN conda install -c r r-ggplot2 
RUN conda install -c conda-forge parallel r-plyr

WORKDIR /opt
COPY . /opt/FSAudit


