#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys
import os
import fnmatch
import re

config = "clang_format_ignore.txt"
known_suffixs = frozenset(['h', 'hpp', 'pch', 'hxx', 'c', 'cc', 'c++', 'cpp', 'cxx', 'm', 'mm'])
ignoreRules = list()

def filterpath(paths):
  if len(ignoreRules) == 0:
    ignoreRules.extend([line.rstrip('\n') for line in open(config)])

  matchs = set()
  for rule in ignoreRules:
    l = fnmatch.filter(paths, rule)
    matchs.update(l)
  result = set(paths).difference(matchs)
  return sorted(list(result))

def remove_prefix(text, prefix):
  return text[text.startswith(prefix) and len(prefix):]

def getfiles(path):
  files = []
  if os.path.isfile(path):
    files.append(remove_prefix(path, './'))
    return files

  for root, dirnames, filenames in os.walk(path):
    relative_root = remove_prefix(root, './')
    for filename in filenames:
      base_ext = filename.rsplit('.', 1)
      if len(base_ext) == 1 or base_ext[1].lower() not in known_suffixs:
        continue
      files.append(os.path.join(relative_root, filename))
  return files

def main(argv):
  if len(argv) < 2:
    print('Usage: python filtername.py <dir>')
    return

  root = argv[1]
  filenames = getfiles(root)
  filtered = filterpath(filenames)
  print ('\n'.join(filtered))

if __name__ == '__main__':
  main(sys.argv)
