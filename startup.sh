#!/bin/bash

/etc/init.d/cron start
ipython trust /import/ipython_galaxy_notebook.ipynb
ipython notebook --no-browser --ip=0.0.0.0 --port 6789 --profile=default
