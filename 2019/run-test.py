#!/usr/bin/env python

import os
import glob
import subprocess


def exec_file(x):
    return os.path.isfile(x) and os.access(x, os.X_OK) and x != "./run-test"

files = list(filter(exec_file, glob.glob("./*")))
f = sorted(files, key=lambda x: os.path.getmtime(x))
subprocess.call(f[-1])
