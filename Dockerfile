# IPython container used for Galaxy IPython Integration
#
# VERSION       0.3.0

FROM ubuntu:14.04

MAINTAINER Björn A. Grüning, bjoern.gruening@gmail.com

ENV DEBIAN_FRONTEND noninteractive

RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9 && \
    echo 'deb http://cran.r-project.org/bin/linux/ubuntu trusty/' >> /etc/apt/sources.list && \
    apt-get -qq update && apt-get install --no-install-recommends -y libcurl4-openssl-dev libxml2-dev \
    apt-transport-https python-dev libc-dev pandoc python-pip pkg-config liblzma-dev libbz2-dev libpcre3-dev \
    build-essential libblas-dev liblapack-dev gfortran libzmq3-dev curl \
    libfreetype6-dev libpng-dev net-tools procps r-base libreadline-dev && \
    pip install distribute --upgrade && \
    pip install pyzmq ipython==2.4 jinja2 tornado pygments numpy biopython scikit-learn pandas \
        scipy sklearn-pandas bioblend matplotlib patsy pysam khmer dendropy ggplot mpld3 sympy rpy2 && \
    apt-get autoremove -y && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ADD ./startup.sh /startup.sh
RUN chmod +x /startup.sh

ADD ./monitor_traffic.sh /monitor_traffic.sh
RUN chmod +x /monitor_traffic.sh

# /import will be the universal mount-point for IPython
# The Galaxy instance can copy in data that needs to be present to the IPython webserver
RUN mkdir /import /home/ipython

# Create user and group with the same UID and GID as the Galaxy main docker container.
RUN groupadd -r ipython -g 1450 && \
    useradd -u 1450 -r -g ipython -d /home/ipython -c "IPython user" ipython

# Install MathJax locally because it has some problems with https as reported here: https://github.com/bgruening/galaxy-ipython/pull/8
RUN python -c 'from IPython.external import mathjax; mathjax.install_mathjax("2.5.0")'

# We can get away with just creating this single file and IPython will create the rest of the
# profile for us.
RUN mkdir -p /home/ipython/.ipython/profile_default/startup/
RUN mkdir -p /home/ipython/.ipython/profile_default/static/custom/

ADD ./ipython-profile.py /home/ipython/.ipython/profile_default/startup/00-load.py
ADD ./ipython_notebook_config.py /home/ipython/.ipython/profile_default/ipython_notebook_config.py
ADD ./custom.js /home/ipython/.ipython/profile_default/static/custom/custom.js
ADD ./custom.css /home/ipython/.ipython/profile_default/static/custom/custom.css

# Add python module to a special folder for modules we want to be able to load within IPython
RUN mkdir /py/
ADD ./galaxy.py /py/galaxy.py
ADD ./put /py/put
ADD ./get /py/get
# Make sure the system is aware that it can look for python code here
ENV PYTHONPATH /py/:$PYTHONPATH
ENV PATH /py/:$PATH

RUN chown -R 1450:1450 /home/ipython /import

# Drop privileges
USER ipython

VOLUME ["/import/"]
WORKDIR /import/

# IPython will run on port 6789, export this port to the host system
EXPOSE 6789

# Start IPython Notebook
CMD /startup.sh
