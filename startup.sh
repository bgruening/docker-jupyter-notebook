#!/bin/bash

ipython trust /import/ipython_galaxy_notebook.ipynb
/cron.sh &
ipython notebook
