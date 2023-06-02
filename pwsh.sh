#!/bin/bash

if [ ! $# -eq 1 ]; then
    pwsh.exe -WorkingDirectory $(wslpath -w /mnt/c/Users/kkirino)
    exit 0
else
    if [ -d $1 ]; then
        pwsh.exe -WorkingDirectory $(wslpath -w $1)
        exit 0
    else
        echo "pwsh: $1 : No such directory" >&2
        exit 1
    fi
fi
