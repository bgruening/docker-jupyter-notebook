# Jupyter container used for Galaxy IPython (+other kernels) Integration

# from 5th March 2021
FROM jupyter/datascience-notebook:d990a62010ae

MAINTAINER Björn A. Grüning, bjoern.gruening@gmail.com

ENV DEBIAN_FRONTEND noninteractive

# Python packages
RUN conda config --add channels conda-forge && \
    conda config --add channels bioconda && \
    conda install --yes --quiet \
    biopython \
    rpy2 \
    bash_kernel \
    #octave_kernel \
    # Scala
    #spylon-kernel \
    # Java
    #scijava-jupyter-kernel \
    # ansible
    ansible-kernel \
    bioblend galaxy-ie-helpers \
    # Jupyter widgets
    jupytext \
    cython patsy statsmodels cloudpickle dill r-xml && conda clean -yt && \
    pip install jupyterlab_hdf

ADD ./startup.sh /startup.sh
#ADD ./monitor_traffic.sh /monitor_traffic.sh
ADD ./get_notebook.py /get_notebook.py

# We can get away with just creating this single file and Jupyter will create the rest of the
# profile for us.
RUN mkdir -p /home/$NB_USER/.ipython/profile_default/startup/ && \
    mkdir -p /home/$NB_USER/.jupyter/custom/

COPY ./ipython-profile.py /home/$NB_USER/.ipython/profile_default/startup/00-load.py
COPY jupyter_notebook_config.py /home/$NB_USER/.jupyter/
COPY jupyter_lab_config.py /home/$NB_USER/.jupyter/

ADD ./custom.js /home/$NB_USER/.jupyter/custom/custom.js
ADD ./custom.css /home/$NB_USER/.jupyter/custom/custom.css
ADD ./default_notebook.ipynb /home/$NB_USER/notebook.ipynb

# ENV variables to replace conf file
ENV DEBUG=false \
    GALAXY_WEB_PORT=10000 \
    NOTEBOOK_PASSWORD=none \
    CORS_ORIGIN=none \
    DOCKER_PORT=none \
    API_KEY=none \
    HISTORY_ID=none \
    REMOTE_HOST=none \
    GALAXY_URL=none

RUN jupyter labextension install @jupyterlab/geojson-extension @jupyterlab/toc-extension @jupyterlab/katex-extension @jupyterlab/fasta-extension

# @jupyterlab/google-drive  not yet supported

USER root

RUN apt-get -qq update && \
    apt-get install -y net-tools procps && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# /import will be the universal mount-point for Jupyter
# The Galaxy instance can copy in data that needs to be present to the Jupyter webserver
RUN mkdir -p /import/jupyter/outputs/ && \
    mkdir -p /import/jupyter/data && \
    mkdir /export/ && \
    chown -R $NB_USER:users /home/$NB_USER/ /import /export/

##USER jovyan

WORKDIR /import

# Start Jupyter Notebook
CMD /startup.sh
