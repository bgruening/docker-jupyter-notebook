#!/bin/bash

uid=`stat --printf %u /import`
gid=`stat --printf %g /import`

if [[ $uid != '1450' ]] && [[ $gid != '1450' ]]; then

    groupadd -r galaxy -g $gid && \
    useradd -u $uid -r -g galaxy -d /home/ipython -c "IPython user" galaxy && \
    chown galaxy:galaxy /home/ipython -R
    su galaxy -c 'ipython trust /import/ipython_galaxy_notebook.ipynb'
    su galaxy -c '/monitor_traffic.sh' & 
    su galaxy -c 'ipython notebook --no-browser'

else

    ipython trust /import/ipython_galaxy_notebook.ipynb
    /monitor_traffic.sh &
    ipython notebook --no-browser

fi
