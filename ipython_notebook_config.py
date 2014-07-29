# See http://ipython.org/ipython-doc/1/interactive/public_server.html for more information.
# Configuration file for ipython-notebook.
c = get_config()
c.NotebookApp.ip = '0.0.0.0'
c.NotebookApp.port = 6789
c.NotebookApp.open_browser = False
c.NotebookApp.profile = u'default'
import yaml
with open('/import/conf.yaml','r') as handle:
    conf = yaml.load(handle)
c.NotebookApp.base_url = '/ipython/%d/' % conf['docker_port']
c.NotebookApp.webapp_settings = {'static_url_prefix':'/ipython/%d/static/' % conf['docker_port']}
