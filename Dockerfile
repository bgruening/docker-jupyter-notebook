FROM debian:wheezy
MAINTAINER Bjoern Gruening <bjoern.gruening@gmail.com>

# Install all requirements and clean up afterwards
RUN DEBIAN_FRONTEND=noninteractive apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y libzmq1 libzmq-dev python-dev libc-dev pandoc python-pip
RUN DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y build-essential
RUN DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y libfreetype6-dev libpng-dev net-tools procps cron
RUN pip install pyzmq ipython jinja2 tornado pygments
RUN pip install distribute --upgrade
RUN pip install numpy biopython scikit-learn pandas sklearn-pandas bioblend matplotlib
RUN pip install pysam khmer dendropy
RUN DEBIAN_FRONTEND=noninteractive apt-get remove -y --purge libzmq-dev python-dev libc-dev build-essential binutils
RUN DEBIAN_FRONTEND=noninteractive apt-get autoremove -y
RUN DEBIAN_FRONTEND=noninteractive apt-get clean -y && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


ADD ./monitor_traffic.sh /monitor_traffic.sh
RUN chmod +x /monitor_traffic.sh
RUN echo "* *     * * *   root    /monitor_traffic.sh" >> /etc/crontab

# /import will be the universal mount-point for IPython
# The Galaxy instance can copy in data that needs to be present to the IPython webserver
RUN mkdir /import
VOLUME ["/import/"]
WORKDIR /import/

ADD ./startup.sh /startup.sh
RUN chmod +x /startup.sh

# IPython will run on port 6789, export this port to the host system
EXPOSE 6789

# Start IPython Notebook
CMD /startup.sh
