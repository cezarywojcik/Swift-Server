#! /usr/bin/env python

#-----------------------------------------------------------------------------#
# Name: swiftinclude.py
# Desc: This script replaces 'include "file.swift"' statements with the actual
#       file contents.
# Auth: Cezary Wojcik
# Opts: -i, --inputfile     : specify input file (default "main.swift")
#       -o, --outputfile    : specify output file (default "app.swift")
#       -d, --debug         : show debug messages
#-----------------------------------------------------------------------------#

# ---- [ imports ] ------------------------------------------------------------

import getopt, sys, re

# ---- [ globals ] ------------------------------------------------------------

files_included = []

# ---- [ utility functions ] --------------------------------------------------

def handle_error(message):
  print "Error: {0}".format(message)
  sys.exit(2)

# ---- [ helper functions ] ---------------------------------------------------

def includify_file(inputfile):
  global files_included
  files_included.append(inputfile)
  output = ""
  pattern = re.compile("include \"(.*)\"")
  with open(inputfile) as f:
    arr = f.readlines()
    for line in arr:
      m = pattern.match(line)
      if m:
        filename = m.group(1)
        if filename not in files_included:
          output += includify_file(filename)
      else:
        output += line
  return output

# ---- [ main ] ---------------------------------------------------------------

def main(argv):
  inputfile = "main.swift"
  outputfile = "app.swift"

  try:
    opts, args = getopt.getopt(sys.argv[1:], 'i:o:',
      ['inputfile=', 'outputfile='])
  except getopt.GetoptError as err:
    handle_error(str(err))

  for o, a in opts:
    if o in ['-i', '--inputfile']:
      inputfile = a
    elif o in ['-o', '--outputfile']:
      outputfile = a
    else:
      handle_error("unhandled option '{0}' detected".format(o))

  # create output file
  try:
    f = open(outputfile, "w+")
    f.close()
  except IOError:
    handle_error("failed to write to file, '{0}'."
      .format(benchmarkfile))

  # parse file
  f = open(outputfile, "w")
  f.write(includify_file(inputfile))

if __name__ == "__main__":
    main(sys.argv[1:])
