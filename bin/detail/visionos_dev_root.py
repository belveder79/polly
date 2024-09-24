# Copyright (c) 2014, Ruslan Baratov
# All rights reserved.

import os
import re

def get(visionos_version):
  dev_dir = re.sub(r'\.', '_', visionos_version)
  dev_dir = 'VISIONOS_{}_DEVELOPER_DIR'.format(dev_dir)
  return os.getenv(dev_dir)
