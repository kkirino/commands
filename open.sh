#!/bin/bash
#
# open
#

if [ ! $# -eq 1 ]; then
  explorer.exe
  exit 0
else
  if [ -e $1 ]; then
    cmd.exe /c start $(wslpath -w $1) 2>/dev/null
    exit 0
  else
    echo "open: $1 : No such file or directory" >&2
    exit 1
  fi
fi

