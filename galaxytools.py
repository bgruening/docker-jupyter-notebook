import bioblend
from bioblend.galaxy.tools.inputs import inputs
from bioblend.galaxy import GalaxyInstance
import os
import shlex
from time import sleep
from urllib.parse import urljoin


def download_dataset(self, dataset_id, file_path=None, use_default_filename=True,
                     maxwait=12000):
    """
    Download a dataset to file or in memory. If the dataset state is not
    'ok', a ``DatasetStateException`` will be thrown.

    :type dataset_id: str
    :param dataset_id: Encoded dataset ID

    :type file_path: str
    :param file_path: If this argument is provided, the dataset will be streamed to disk
                      at that path (should be a directory if use_default_filename=True).
                      If the file_path argument is not provided, the dataset content is loaded into memory
                      and returned by the method (Memory consumption may be heavy as the entire file
                      will be in memory).

    :type use_default_filename: bool
    :param use_default_filename: If this argument is True, the exported
                             file will be saved as file_path/%s,
                             where %s is the dataset name.
                             If this argument is False, file_path is assumed to
                             contain the full file path including the filename.

    :type maxwait: float
    :param maxwait: Total time (in seconds) to wait for the dataset state to
      become terminal. If the dataset state is not terminal within this
      time, a ``DatasetTimeoutException`` will be thrown.

    :rtype: dict
    :return: If a file_path argument is not provided, returns a dict containing the file_content.
             Otherwise returns nothing.
    """
    dataset = self._block_until_dataset_terminal(dataset_id, maxwait=maxwait)
    # if not dataset['state'] == 'ok':
    #     raise DatasetStateException("Dataset state is not 'ok'. Dataset id: %s, current state: %s" % (dataset_id, dataset['state']))

    # Galaxy release_13.01 and earlier does not have file_ext in the dataset
    # dict, so resort to data_type.
    # N.B.: data_type cannot be used for Galaxy release_14.10 and later
    # because it was changed to the Galaxy datatype class
    file_ext = dataset.get('file_ext', dataset['data_type'])
    # Resort to 'data' when Galaxy returns an empty or temporary extension
    if not file_ext or file_ext == 'auto' or file_ext == '_sniff_':
        file_ext = 'data'
    # The preferred download URL is
    # '/api/histories/<history_id>/contents/<dataset_id>/display?to_ext=<dataset_ext>'
    # since the old URL:
    # '/dataset/<dataset_id>/display/to_ext=<dataset_ext>'
    # does not work when using REMOTE_USER with access disabled to
    # everything but /api without auth
    if 'url' in dataset:
        # This is Galaxy release_15.03 or later
        download_url = dataset['download_url'] + '?to_ext=' + file_ext
    else:
        # This is Galaxy release_15.01 or earlier, for which the preferred
        # URL does not work without a key, so resort to the old URL
        download_url = 'datasets/' + dataset_id + '/display?to_ext=' + file_ext
    url = urljoin(self.gi.base_url, download_url)

    stream_content = file_path is not None
    r = self.gi.make_get_request(url, stream=stream_content)
    r.raise_for_status()

    if file_path is None:
        if 'content-length' in r.headers and len(r.content) != int(r.headers['content-length']):
            log.warning("Transferred content size does not match content-length header (%s != %s)" % (len(r.content), r.headers['content-length']))
        return r.content
    else:
        if use_default_filename:
            # Build a useable filename
            filename = dataset['name'] + '.' + file_ext
            # Now try to get a better filename from the response headers
            # We expect tokens 'filename' '=' to be followed by the quoted filename
            if 'content-disposition' in r.headers:
                tokens = list(shlex.shlex(r.headers['content-disposition'], posix=True))
                try:
                    header_filepath = tokens[tokens.index('filename') + 2]
                    filename = os.path.basename(header_filepath)
                except (ValueError, IndexError):
                    pass
            file_local_path = os.path.join(file_path, filename)
        else:
            file_local_path = file_path

        with open(file_local_path, 'wb') as fp:
            for chunk in r.iter_content(chunk_size=bioblend.CHUNK_SIZE):
                if chunk:
                    fp.write(chunk)

        # Return location file was saved to
        return file_local_path


def run_with_galaxy(job, server='https://usegalaxy.eu', key=None):
    if key is None:
        key = os.environ['API_KEY']
    job.server.run_mode.manual = True
    job.run()
    gi = GalaxyInstance(server, key=key)
    hist = gi.histories.create_history('pyiron_' + job.job_name)
    ret = gi.tools.upload_file(job.project_hdf5.file_name, hist['id'])
    tool_inputs = inputs().set_dataset_param("infile", ret['outputs'][0]['id'], src='hda')
    output = gi.tools.run_tool(history_id=hist['id'],
                               tool_id='pyiron_meta',
                               tool_inputs=tool_inputs)
    while gi.jobs.get_state(output['jobs'][0]['id']) in ['running', 'new', 'queued']:
        sleep(5)
    file_name = download_dataset(self=gi.datasets,
                                 dataset_id=gi.jobs.show_job(output['jobs'][0]['id'])['outputs']['outfile']['id'],
                                 file_path=job.working_directory,
                                 use_default_filename=True,
                                 maxwait=12000)
    # os.remove(job.project_hdf5.file_name)
    os.rename(file_name, job.project_hdf5.file_name)
    job.from_hdf()
    job.status.finished = True
    gi.histories.delete_history(hist['id'], purge=True)
