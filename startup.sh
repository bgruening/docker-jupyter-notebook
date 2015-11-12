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

su ipython -c 'python /get_notebook.py'

if [ ! -f /import/ipython_galaxy_notebook.ipynb ]; then
    cp /home/ipython/notebook.ipynb /import/ipython_galaxy_notebook.ipynb
    chown ipython:ipython /import/ipython_galaxy_notebook.ipynb
fi

su ipython -c 'ipython trust /home/ipython/workdir/ipython_galaxy_notebook.ipynb'
su ipython -c '/monitor_traffic.sh' &
su ipython -c 'ipython notebook --no-browser'
