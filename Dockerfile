FROM debian:wheezy
MAINTAINER Bjoern Gruening <bjoern.gruening@gmail.com>

# Install all requirements and clean up afterwards
RUN DEBIAN_FRONTEND=noninteractive apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y libzmq1 libzmq-dev python-dev libc-dev pandoc python-pip
RUN DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y build-essential libblas-dev liblapack-dev gfortran
RUN DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y libfreetype6-dev libpng-dev net-tools procps
RUN pip install pyzmq ipython==2.2 jinja2 tornado pygments
RUN pip install distribute --upgrade
RUN pip install numpy biopython scikit-learn pandas scipy sklearn-pandas bioblend matplotlib
RUN pip install patsy
RUN pip install pysam khmer dendropy ggplot mpld3 sympy
RUN DEBIAN_FRONTEND=noninteractive apt-get remove -y --purge libzmq-dev python-dev libc-dev build-essential binutils gfortran
RUN DEBIAN_FRONTEND=noninteractive apt-get autoremove -y
RUN DEBIAN_FRONTEND=noninteractive apt-get clean -y && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# /import will be the universal mount-point for IPython
# The Galaxy instance can copy in data that needs to be present to the IPython webserver

ADD ./startup.sh /startup.sh
RUN chmod +x /startup.sh

ADD ./monitor_traffic.sh /monitor_traffic.sh
RUN chmod +x /monitor_traffic.sh

ADD ./cron.sh /cron.sh
RUN chmod +x /cron.sh

RUN mkdir /import && mkdir -p /home/ipyuser && groupadd -r ipyuser -g 500 && \
    useradd -u 1000 -r -g ipyuser -d /home/ipyuser -s /sbin/nologin ipyuser && \
    chown -R ipyuser:ipyuser /home/ipyuser && \
    chown -R ipyuser:ipyuser /import && \
    chown -R ipyuser:ipyuser /monitor_traffic.sh && \
    chown -R ipyuser:ipyuser /cron.sh

USER ipyuser

# Install MathJax locally because it has some problems with https as reported here: https://github.com/bgruening/galaxy-ipython/pull/8
RUN python -c 'from IPython.external import mathjax; mathjax.install_mathjax("2.4.0")'

# We can get away with just creating this single file and IPython will create the rest of the
# profile for us.
RUN mkdir -p /home/ipyuser/.ipython/profile_default/startup/
RUN mkdir -p /home/ipyuser/.ipython/profile_default/static/custom/

# These imports are done for every open IPython console
ADD ./ipython-profile.py /home/ipyuser/.ipython/profile_default/startup/00-load.py
ADD ./ipython_notebook_config.py /home/ipyuser/.ipython/profile_default/ipython_notebook_config.py
ADD ./custom.js /home/ipyuser/.ipython/profile_default/static/custom/custom.js
ADD ./custom.css /home/ipyuser/.ipython/profile_default/static/custom/custom.css

VOLUME ["/import/"]
WORKDIR /import/

# IPython will run on port 6789, export this port to the host system
EXPOSE 6789

# Start IPython Notebook
CMD /startup.sh
