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
# with the UID 1450 (preconfigured jupyter user) or a newly created 'galaxy' user
# with the same UID/GID as /import.

export PATH=/home/jovyan/.local/bin:$PATH

python /get_notebook.py

#if [ ! -f /import/ipython_galaxy_notebook.ipynb ]; then
#    cp /home/$NB_USER/notebook.ipynb /import/ipython_galaxy_notebook.ipynb
#    chown $NB_USER /import/ipython_galaxy_notebook.ipynb
#fi

jupyter trust /import/ipython_galaxy_notebook.ipynb
##/monitor_traffic.sh &
jupyter notebook --no-browser

