#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys
import os
import filterpath
import subprocess

def clang_format_one_file(filename, binary='tools/clang-format/clang-format'):
  #Run clang-format on the given file
  clang_format_cmd = [binary, '-i', filename]
  try:
    clang_format = subprocess.Popen(clang_format_cmd)
  except OSError as e:
    if e.errno == errno.ENOENT:
      die('cannot find executable "%s"' % binary)
    else:
      raise
  if clang_format.wait() != 0:
    die('`%s` failed' % ' '.join(clang_format_cmd))

def die(message):
  sys.stderr.write('error: %s \n' % message)
  sys.exit(2)

def main(argv):
  if len(argv) < 2:
    print('Usage: python tools/clang-format/batchformat.py <dir>')
    return

  root = argv[1]
  filenames = filterpath.getfiles(root)
  filtered = filterpath.filterpath(filenames)
  for filename in filtered:
    print('formatting: ' + filename)
    clang_format_one_file(filename)

if __name__ == '__main__':
  main(sys.argv)
