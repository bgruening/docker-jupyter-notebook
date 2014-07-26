#!/bin/bash

/etc/init.d/cron start
ipython notebook --no-browser --ip=0.0.0.0 --port 6789 --profile=galaxy
