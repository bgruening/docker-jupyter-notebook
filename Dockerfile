# Jupyter container used for Galaxy IPython (+other kernels) Integration

FROM jupyter/base-notebook:6d42503c684f

MAINTAINER Björn A. Grüning, bjoern.gruening@gmail.com

ENV DEBIAN_FRONTEND noninteractive

# Install system libraries first as root
USER root

RUN apt-get -qq update && apt-get install --no-install-recommends -y libcurl4-openssl-dev libxml2-dev \
    apt-transport-https python-dev libc-dev pandoc && \
    apt-get autoremove -y && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

USER jovyan

# Python packages
RUN conda config --add channels conda-forge && \
    conda install --yes --quiet \
    pyiron=0.2.17 lammps gpaw sphinxdft nglview=2.7.7 requests-toolbelt boto git && conda clean -yt && \
    pip install --no-cache-dir bioblend galaxy-ie-helpers

# ngl view for jupyter lab
RUN jupyter labextension install @jupyter-widgets/jupyterlab-manager --no-build && \
    jupyter labextension install nglview-js-widgets@2.7.7

# pyiron setup
COPY galaxytools.py ${HOME}/examples
COPY first_steps.ipynb ${HOME}/examples
COPY submit-to-galaxy.ipynb ${HOME}/examples

ADD ./startup.sh /startup.sh
ADD ./monitor_traffic.sh /monitor_traffic.sh
ADD ./get_notebook.py /get_notebook.py

USER root

# /import will be the universal mount-point for Jupyter
# The Galaxy instance can copy in data that needs to be present to the Jupyter webserver
RUN mkdir /import


# We can get away with just creating this single file and Jupyter will create the rest of the
# profile for us.
RUN mkdir -p /home/$NB_USER/.ipython/profile_default/startup/
RUN mkdir -p /home/$NB_USER/.jupyter/custom/

COPY ./ipython-profile.py /home/$NB_USER/.ipython/profile_default/startup/00-load.py
#ADD ./ipython_notebook_config.py /home/$NB_USER/.jupyter/jupyter_notebook_config.py
COPY jupyter_notebook_config.py /home/$NB_USER/.jupyter/

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
    GALAXY_URL=none \
    CONDA_PREFIX=$CONDA_DIR

RUN mkdir /export/ && chown -R $NB_USER:users /home/$NB_USER/ /import /export/

##USER jovyan

WORKDIR /import

# Jupyter will run on port 8888, export this port to the host system

# Start Jupyter Notebook
CMD /startup.sh
