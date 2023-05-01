#!/usr/bin/env python3
#
# Repo Profiler
#
# Crawls a root directory and builds a list of all git repositories.
#
# Author(s): Cody Buell
#
# Requisite:
#
# Usage:

import os

repodir = "{{ Repos }}"
repos   = []

for dirpath, dirnames, _ in os.walk(repodir):
    if '.git' in dirnames:
        reponame = dirpath.split('/')[-1]
        repos.append(reponame + ':' + dirpath)
        dirnames[:] = []

f = open(repodir + '/.repos', 'w')
f.writelines('\n'.join(repos))
f.close()
