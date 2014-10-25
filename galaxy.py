from bioblend import galaxy
from bioblend.galaxy.tools import ToolClient
from bioblend.galaxy.histories import HistoryClient
from bioblend.galaxy.datasets import DatasetClient
import yaml
import subprocess
import argparse

def _get_conf( config_file = '/import/conf.yaml' ):
    with open(config_file, 'rb') as handle:
        conf = yaml.load(handle)
    return conf

def get_galaxy_connection( ):
    """
        Given access to the configuration dict that galaxy passed us, we try and connect to galaxy's API.

        First we try connecting to galaxy directly, using an IP address given
        us by docker (since the galaxy host is the default gateway for docker).
        Using additional information collected by galaxy like the port it is
        running on and the application path, we build a galaxy URL and test our
        connection by attempting to get a history listing. This is done to
        avoid any nasty network configuration that a SysAdmin has placed
        between galaxy and us inside docker, like disabling API queries.

        If that fails, we failover to using the URL the user is accessing
        through. This will succeed where the previous connection fails under
        the conditions of REMOTE_USER and galaxy running under uWSGI.
    """
    conf = _get_conf()
    try:
        # Remove trailing slashes
        app_path = conf['galaxy_url'].rstrip('/')
        # Remove protocol+host:port if included
        app_path = ''.join(app_path.split('/')[3:])
        # Now obtain IP address from a netstat command.

        cmd_netstat = ['netstat','-nr']
        p1 = subprocess.Popen(cmd_netstat, stdout=subprocess.PIPE)
        cmd_grep = ['grep', '^0\.0\.0\.0']
        p2 = subprocess.Popen(cmd_grep, stdin=p1.stdout, stdout=subprocess.PIPE)
        cmd_awk = ['awk', '{ print $2 }']
        p3 = subprocess.Popen(cmd_awk, stdin=p2.stdout, stdout=subprocess.PIPE)
        # Now we have an ip address to connect to galaxy on.
        galaxy_ip = p3.stdout.read()
        # We should be able to find a port to connect to galaxy on via this
        # conf var: galaxy_paster_port
        galaxy_port = conf['galaxy_paster_port']

        if not galaxy_port:
            # We've failed to detect a port in the config we were given by
            # galaxy, so we won't be able to construct a valid URL
            raise Exception("No port")

        built_galaxy_url = 'http://%s:%s/%s' %  (galaxy_ip.strip(), galaxy_port, app_path.strip())
        gi = galaxy.GalaxyInstance(url=built_galaxy_url.rstrip('/'), key=conf['api_key'])
        gi.histories.get_histories()
    except:
        try:
            gi = galaxy.GalaxyInstance(url=conf['galaxy_url'], key=conf['api_key'])
            gi.histories.get_histories()
        except:
            raise Exception("Could not connect to a galaxy instance. Please contact your SysAdmin for help with this error")
    return gi

def _get_history_id():
    conf = _get_conf()
    return conf['history_id']

def put(filename, file_type = 'auto'):
    """
        Given a filename of any file accessible to the docker instance, this
        function will upload that file to galaxy using the current history.
        Does not return anything.
    """
    conf = _get_conf()
    gi = get_galaxy_connection()
    tc = ToolClient( gi )
    tc.upload_file(filename, conf['history_id'], file_type = file_type)


def get( dataset_id ):
    """
        Given the history_id that is displayed to the user, this function will
        download the file from the history and stores it under /import/
        Return value is the path to the dataset stored under /import/
    """
    conf = _get_conf()
    gi = get_galaxy_connection()
    hc = HistoryClient( gi )
    dc = DatasetClient( gi )

    file_path = '/import/%s' % dataset_id

    dataset_mapping = dict( [(dataset['hid'], dataset['id']) for dataset in hc.show_history(conf['history_id'], contents=True)] )
    try:
        hc.download_dataset(conf['history_id'], dataset_mapping[dataset_id], file_path, use_default_filename=False, to_ext=None)
    except:
        dc.download_dataset(dataset_mapping[dataset_id], file_path, use_default_filename=False)

    return file_path

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Connect to Galaxy through the API')
    parser.add_argument('action',   help='Action to execute', choices=['get', 'put'])
    parser.add_argument('argument', help='File/ID number to Upload/Download, respectively')
    parser.add_argument('file_type', nargs='?', help='File format to pass', default='auto')
    args = parser.parse_args()

    if args.action == 'get':
        # Ensure it's a numerical value
        get(int(args.argument))
    elif args.action == 'put':
        put(args.argument, file_type=args.file_type)
