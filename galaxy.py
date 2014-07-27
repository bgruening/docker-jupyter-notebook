from bioblend import galaxy
from bioblend.galaxy.tools import ToolClient
from bioblend.galaxy.histories import HistoryClient
import yaml

def export(filename):
    with open('conf.yaml', 'rb') as handle:
        conf = yaml.load(handle)
    gi = galaxy.GalaxyInstance(url=conf['galaxy_url'], key=conf['api_key'])
    tc = ToolClient( gi )
    tc.upload_file(filename, conf['history_id'])


def import( dataset_id ):
    """
        Given the history_id that is displayed to the user, this function will
        download the file from the history and stores it under /import/
        Return value is the path to the dataset stored under /import/
    """
    with open('conf.yaml', 'rb') as handle:
        conf = yaml.load(handle)

    gi = galaxy.GalaxyInstance(url=conf['galaxy_url'], key=conf['api_key'])
    hc = HistoryClient( gi )

    file_path = '/import/%s' % dataset_id

    dataset_mapping = dict( [(dataset['hid'], dataset['id']) for dataset in hc.show_history(conf['history_id'], contents=True)] )
    hc.download_dataset(conf['history_id'], dataset_mapping[dataset_id], file_path, use_default_filename=False, to_ext=None)

    return file_path
