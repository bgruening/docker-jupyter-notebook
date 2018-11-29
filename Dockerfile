# Jupyter container used for Galaxy IPython (+other kernels) Integration

FROM jupyter/datascience-notebook:628fbcb24afd

MAINTAINER Björn A. Grüning, bjoern.gruening@gmail.com

ENV DEBIAN_FRONTEND noninteractive

# Install system libraries first as root
USER root

RUN apt-get -qq update && apt-get install --no-install-recommends -y libcurl4-openssl-dev libxml2-dev \
    apt-transport-https python-dev libc-dev pandoc pkg-config liblzma-dev libbz2-dev libpcre3-dev \
    build-essential libblas-dev liblapack-dev gfortran libzmq3-dev libyaml-dev libxrender1 fonts-dejavu \
    libfreetype6-dev libpng-dev net-tools procps libreadline-dev wget software-properties-common octave \
    # IHaskell dependencies
    zlib1g-dev libtinfo-dev libcairo2-dev libpango1.0-dev && \
    apt-get autoremove -y && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Glasgow Haskell Compiler
#RUN add-apt-repository -y ppa:hvr/ghc && \
#    sed -i s/jessie/trusty/g /etc/apt/sources.list.d/hvr-ghc-jessie.list && \
#    apt-get update && apt-get install -y cabal-install-1.22 ghc-7.8.4 happy-1.19.4 alex-3.1.3 && \
#    apt-get autoremove -y && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Ruby dependencies
RUN add-apt-repository -y  ppa:brightbox/ruby-ng && \
    sed -i s/jessie/trusty/g  /etc/apt/sources.list.d/brightbox-ruby-ng-jessie.list && apt-get update && \
    apt-get install -y --no-install-recommends ruby2.2 ruby2.2-dev libtool autoconf automake gnuplot-nox libsqlite3-dev \
    libatlas-base-dev libgsl0-dev libmagick++-dev imagemagick && \
    ln -s /usr/bin/libtoolize /usr/bin/libtool && \
    apt-get purge -y software-properties-common && \
    apt-get autoremove -y && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN gem install --no-rdoc --no-ri rbczmq sciruby-full 

ENV PATH /home/$NB_USER/.cabal/bin:/opt/cabal/1.22/bin:/opt/ghc/7.8.4/bin:/opt/happy/1.19.4/bin:/opt/alex/3.1.3/bin:$PATH

USER jovyan

# Python packages
RUN conda config --add channels r && conda install --yes --quiet biopython rpy2 \
    cython patsy statsmodels cloudpickle dill tensorflow=1.1* r-xml && conda clean -yt && \
    pip install --no-cache-dir bioblend galaxy-ie-helpers

# Now for a python2 environment
RUN /bin/bash -c "source activate python2 && conda install --quiet --yes biopython rpy2 \
    cython patsy statsmodels cloudpickle dill tensorflow=1.1* && conda clean -yt && \
    pip install --no-cache-dir bioblend galaxy-ie-helpers"

# IRuby
RUN iruby register

# IHaskell + IHaskell-Widgets + Dependencies for examples
#RUN cabal update && \
#    CURL_CA_BUNDLE='/etc/ssl/certs/ca-certificates.crt' curl 'https://www.stackage.org/lts-2.22/cabal.config?global=true' >> ~/.cabal/config && \
#    cabal install cpphs && \
#    cabal install gtk2hs-buildtools && \
#    cabal install ihaskell-0.8.0.0 --reorder-goals && \
#    cabal install ihaskell-widgets-0.2.2.1 HTTP Chart Chart-cairo && \
#     ~/.cabal/bin/ihaskell install && \
#    rm -fr $(echo ~/.cabal/bin/* | grep -iv ihaskell) ~/.cabal/packages ~/.cabal/share/doc ~/.cabal/setup-exe-cache ~/.cabal/logs


# Extra Kernels
RUN pip install --upgrade pip && \
    pip install --user --no-cache-dir bash_kernel bioblend octave_kernel galaxy-ie-helpers && \
    python -m bash_kernel.install && \
    # add galaxy-ie-helpers to PATH
    echo 'export PATH=/home/jovyan/.local/bin:$PATH' >> /home/jovyan/.bashrc 

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
    GALAXY_URL=none

RUN chown -R $NB_USER:users /home/$NB_USER/ /import

USER jovyan

WORKDIR /import

# Jupyter will run on port 8888, export this port to the host system

# Start Jupyter Notebook
CMD /startup.sh
