#!/bin/bash

# The IPython image starts as privileged user.
# The parent Galaxy server is mounting data into /import with the same 
# permissions as the Galaxy server is running on.
# In case of 1450 as UID and GID we are fine, because our preconfigured ipython
# user owns this UID/GID. 
# (1450 is the user id the Galaxy-Docker Image is using)
# If /import is not owned by 1450 we need to create a new user with the same
# UID/GID as /import and make everything accessible to this new user.
#
# In the end the IPython Server is started as non-privileged user. Either
# with the UID 1450 (preconfigured ipython user) or a newly created 'galaxy' user
# with the same UID/GID as /import.

uid=`stat --printf %u /import`
gid=`stat --printf %g /import`

if [ ! -f /import/ipython_galaxy_notebook.ipynb ]; then
    cp /home/ipython/notebook.ipynb /import/ipython_galaxy_notebook.ipynb
fi


if [[ $uid != '1450' ]] && [[ $gid != '1450' ]]; then

    [ $(getent group $gid) ] || groupadd -r galaxy -g $gid
    useradd -u $uid -r -g $gid -d /home/ipython -c "IPython user" galaxy
    chown $uid:$gid /home/ipython -R
    su - galaxy -c 'ipython trust /import/ipython_galaxy_notebook.ipynb'
    su - galaxy -c '/monitor_traffic.sh' & 
    su - galaxy -c 'ipython notebook --no-browser'

else

    su - ipython -c 'ipython trust /import/ipython_galaxy_notebook.ipynb'
    su - ipython -c '/monitor_traffic.sh' &
    su - ipython -c 'ipython notebook --no-browser'

fi
