#!/bin/bash

# Take the netstat output the estimate if the client is still connected to
# the IPython Notebook server. The 'CLOSE_WAIT' state will be ignored. It
# Indicates that the server has received the first FIN signal from the client
# and the connection is in the process of being closed. But that can never happen.
# For some reason there are a few connections open that do not relate the the
# client that needs to be connected over the port :6789. If we do not have a
# connection open from port 6789, kill the server and herewith the docker container.

while true; do
    sleep ${DEFAULT_CONTAINER_RUNTIME:-240}

    if [ `netstat -t | grep -v CLOSE_WAIT | grep ':8888' | wc -l` -lt 3 ]
    then
        pkill jupyter
    fi

done
