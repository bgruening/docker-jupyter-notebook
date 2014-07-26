#!/bin/bash


# Take the netstat output the estimate if the client is still connected to
# the IPython Notebook server. The 'CLOSE_WAIT' state will be ignored. It
# Indicates that the server has received the first FIN signal from the client
# and the connection is in the process of being closed. But that can never happen.
# For some reason there are a few connections open that do not relate the the
# client that needs to be connected over the port :6789. If we do not have a
# connection open from port 6789, kill the server and herewith the docker container.

if [ `netstat -t | grep -v CLOSE_WAIT | grep ':6789' | wc -l` -lt 3 ]
then
    pkill ipython
    # We will create new history elements with all data that is relevant,
    # this means we can delete everything from /import/
    rm /import/ -rf
fi

