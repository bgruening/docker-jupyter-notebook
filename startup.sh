#!/bin/bash

/etc/init.d/cron start
ipython trust /import/ipython_galaxy_notebook.ipynb
ipython notebook
