#!/bin/bash
#
# pwsh.sh
#

if [ $# -eq 1 ] && [ -d "$1" ]; then
    pwsh.exe -wd "$(wslpath -w "$1")"
else
    pwsh.exe -wd 'C:\Users\kkirino'
fi
