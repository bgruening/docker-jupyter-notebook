#!/usr/bin/env python
import os
import shutil

import galaxy_ie_helpers

from bioblend.galaxy.histories import HistoryClient

hid = os.environ.get('DATASET_HID', None)
history_id = os.environ['HISTORY_ID']
if hid not in ('None', None):
    galaxy_ie_helpers.get(int(hid))
    shutil.copy('/import/%s' % hid, '/import/ipython_galaxy_notebook.ipynb')

additional_ids = os.environ.get("ADDITIONAL_IDS", "")
if additional_ids:
    gi = galaxy_ie_helpers.get_galaxy_connection(history_id=history_id, obj=False)
    hc = HistoryClient(gi)
    history = hc.show_history(history_id, contents=True)
    additional_ids = additional_ids.split(",")
    for hda in history:
        if hda["id"] in additional_ids:
            galaxy_ie_helpers.get(int(hda["hid"]))
