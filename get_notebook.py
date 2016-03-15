#!/usr/bin/env python
import os
import galaxy_ie_helpers
import shutil

hid = os.environ.get('DATASET_HID', None)
if hid not in ('None', None):
    galaxy_ie_helpers.get(int(hid))
    shutil.copy('/import/%s' % hid, '/import/ipython_galaxy_notebook.ipynb')
