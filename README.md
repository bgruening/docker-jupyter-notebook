docker-ipython
==============

IPython running in a docker container. This image can be used to integrate IPython into Galaxy

Usage
=====

``sudo docker build -t ipython-notebook . ``
``docker run -p 8080:6789 -v ./foo/:/import/ -t ipython-notebook ``

