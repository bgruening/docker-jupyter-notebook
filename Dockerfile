FROM debian:wheezy
MAINTAINER Bjoern Gruening <bjoern.gruening@gmail.com>

# Install all requirements and clean up afterwards
RUN DEBIAN_FRONTEND=noninteractive apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y libzmq1 libzmq-dev python-dev libc-dev pandoc python-pip
RUN DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y build-essential
RUN pip install pyzmq ipython jinja2 tornado pygments
RUN DEBIAN_FRONTEND=noninteractive apt-get remove -y --purge libzmq-dev python-dev libc-dev build-essential binutils
RUN DEBIAN_FRONTEND=noninteractive apt-get autoremove -y
RUN DEBIAN_FRONTEND=noninteractive apt-get clean -y && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# /import will be the universal mount-point for IPython
# The Galaxy instance can copy in data that needs to be present to the IPython webserver
RUN mkdir /import
VOLUME ["/import/"]
WORKDIR /import/

# IPython will run on port 6789, export this port to the host system
EXPOSE 6789

# Start IPython Notebook
CMD ipython notebook --no-browser --ip=0.0.0.0 --port 6789
