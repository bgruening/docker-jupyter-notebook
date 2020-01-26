[![Build Status](https://travis-ci.org/bgruening/docker-jupyter-notebook.svg?branch=master)](https://travis-ci.org/bgruening/docker-jupyter-notebook)
[![Docker Repository on Quay](https://quay.io/repository/bgruening/docker-jupyter-notebook/status "Docker Repository on Quay")](https://quay.io/repository/bgruening/docker-jupyter-notebook)
[![DOI](https://zenodo.org/badge/5466/bgruening/docker-jupyter-notebook.svg)](https://zenodo.org/badge/latestdoi/5466/bgruening/docker-jupyter-notebook)
[![Manuscript](https://img.shields.io/badge/DOI-10.1371/journal.pcbi.1005425-blue.svg)](https://doi.org/10.1371/journal.pcbi.1005425)



Docker Jupyter Container
========================


This [Jupyter](http://jupyter.org/) Docker container is used by the [Galaxy Project](https://galaxyproject.org/) and can be installed from the [docker.io index](https://registry.hub.docker.com/u/bgruening/docker-jupyter-notebook/).

```bash
docker pull bgruening/docker-jupyter-notebook
```

Usage
=====

* Build your own image and run it

 [Docker](https://www.docker.com) is a pre-requirement for this project. You can build the container with:
 ```bash
  docker build -t jupyter-notebook . 
 ```
 The build process can take some time, but if finished you can run your container with:
 ```bash
  docker run -p 7777:8888 -i -t jupyter-notebook
 ```
 and you will have a running [Jupyter Notebook](http://jupyter.org) instance on ``http://localhost:7777/ipython/``.

* Run a pre-build image from docker registry

 ``docker run -p 7777:8888 bgruening/docker-jupyter-notebook ``  


Environment Variables
=====================

Some environment variables are made available to the user which will allow for configuring the behaviour of individual instances.

Variable            | Use
------------------- | ---
`API_KEY`           | Galaxy API Key with which to interface with Galaxy
`CORS_ORIGIN`       | If the notebook is proxied, this is the URL the end-user will see when trying to access a notebook
`DEBUG`             | Enable debugging mode, mostly for developers
`GALAXY_URL`        | URL at which Galaxy is accessible
`GALAXY_WEB_PORT`   | Port on which Galaxy is running, if applicable
`HISTORY_ID`        | ID of current Galaxy History, used in easing the dataset upload/download process
`NOTEBOOK_PASSWORD` | Password with which to secure the notebook
`PROXY_PREFIX`      | Prefix to URL which allows Galaxy proxy to share cookies with Galaxy itself.


Authors
=======

 * Ananthraj K
 * Satheesh S

History
=======

- v0.1: Initial public release
 - with Julia, Bash, Python2/3, Ruby, Haskell and R kernels 



