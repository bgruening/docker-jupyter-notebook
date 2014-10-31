#!/bin/bash

ipython trust /import/ipython_galaxy_notebook.ipynb
/monitor_traffic.sh &
ipython notebook --no-browser
