import os
import galaxy
import shutil

hid = os.environ.get('DATASET_HID', None)
if hid not in ('None', None):
    galaxy.get(int(hid))
    shutil.copy('/import/%s' % hid, '/import/ipython_galaxy_notebook.ipynb')
