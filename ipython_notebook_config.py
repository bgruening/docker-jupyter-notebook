# See http://ipython.org/ipython-doc/1/interactive/public_server.html for more information.
# Configuration file for ipython-notebook.
c = get_config()
c.NotebookApp.ip = '0.0.0.0'
c.NotebookApp.port = 6789
c.NotebookApp.open_browser = False
c.NotebookApp.profile = u'default'
c.IPKernelApp.matplotlib = 'inline'
# This is needed for Cross-Origin Resource Sharing
c.NotebookApp.allow_origin = '*'

import os
import yaml

config_file_path = '/import/conf.yaml'
# In case this Notebook was launched from Galaxy a config file exists in /import/
# For standalone usage we fall back to a port-less URL
if os.path.exists( config_file_path ):
    with open( config_file_path ,'r') as handle:
        conf = yaml.load(handle)
    c.NotebookApp.base_url = '/ipython/%d/' % conf['docker_port']
    c.NotebookApp.webapp_settings = {'static_url_prefix':'/ipython/%d/static/' % conf['docker_port']}

    if 'notebook_password' in conf:
        c.NotebookApp.password = conf['notebook_password']
else:
    c.NotebookApp.base_url = '/ipython/'
    c.NotebookApp.webapp_settings = {'static_url_prefix':'/ipython/static/'}


# Allow the frame to be displayed within Galaxy by disabling X-Frame-Options
#c.NotebookApp.webapp_settings = {'headers': {'X-Frame-Options': 'ALLOW-FROM http://localhost:8080'}}
c.NotebookApp.webapp_settings['headers'] = {'X-Frame-Options': 'ALLOWALL'}


