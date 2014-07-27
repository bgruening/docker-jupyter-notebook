from bioblend import galaxy
from bioblend.galaxy.tools import ToolClient
#from bioblend.galaxy.histories import HistoryClient
import yaml

def export(filename):
    with open('conf.yaml', 'rb') as handle:
        conf = yaml.load(handle)
    gi = galaxy.GalaxyInstance(url=conf['galaxy_url'], key=conf['api_key'])
    tc = ToolClient( gi )
    tc.upload_file(filename, conf['history_id'])


def load(id):
    #with open('conf.yaml', 'rb') as handle:
        #conf = yaml.load(handle)
    #gi = galaxy.GalaxyInstance(url=conf['galaxy_url'], key=conf['api_key'])
    # TODO: implement
    raise Exception("Importing files from galaxy history is currently unimplemented")
