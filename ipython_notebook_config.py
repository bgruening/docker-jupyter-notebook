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
