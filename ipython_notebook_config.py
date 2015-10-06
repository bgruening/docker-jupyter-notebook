# See http://ipython.org/ipython-doc/1/interactive/public_server.html for more information.
# Configuration file for ipython-notebook.
import os

c = get_config()
c.NotebookApp.ip = '0.0.0.0'
c.NotebookApp.port = 6789
c.NotebookApp.open_browser = False
c.NotebookApp.profile = u'default'
c.IPKernelApp.matplotlib = 'inline'

headers = {
    'X-Frame-Options': 'ALLOWALL',
}
c.NotebookApp.allow_origin = '*'
c.NotebookApp.allow_credentials = True

# In case this Notebook was launched from Galaxy a config file exists in /import/
# For standalone usage we fall back to a port-less URL
c.NotebookApp.base_url = '%s/ipython/' % os.environ.get('PROXY_PREFIX', '')
c.NotebookApp.webapp_settings = {
    'static_url_prefix': '%s/ipython/static/' % os.environ.get('PROXY_PREFIX', '')
}

if os.environ.get('NOTEBOOK_PASSWORD', 'none') != 'none':
    c.NotebookApp.password = os.environ['NOTEBOOK_PASSWORD']

if os.environ.get('CORS_ORIGIN', 'none') != 'none':
    c.NotebookApp.allow_origin = os.environ['CORS_ORIGIN']

c.NotebookApp.webapp_settings['headers'] = headers
