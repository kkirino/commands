#!/bin/bash
# 
# onedrivesync
# 

set -e

# ディレクトリの設定
DIR_ONEDRIVE=/mnt/c/Users/kkirino/OneDrive/onedrivesync
DIR_SOURCE=$(pwd)
DIR_PULL_TO=$(dirname ${DIR_SOURCE})
DIR_DEST=${DIR_ONEDRIVE}/${DIR_SOURCE##*/}

# usage function を定義
function usage() {
    cat <<EOF
usage: onedrivesync [command] [option]
command: push   synchronize source to destination
         pull   synchronize destination to source
option: -n, --dry-run   perform a trial run with no changes made
EOF
    exit 1
}

# エラーの対処
if [ ! $# -eq 1 ] && [ ! $# -eq 2 ]; then
    echo 1
    usage
elif [ ! "$1" = 'push' ] && [ ! "$1" = 'pull' ]; then
    echo 2
    usage
elif [$# -eq 2 ] && [ ! "$2" = '--dry-run' ] && [ ! "$2" = '-n' ]; then
    echo 3
    usage
elif [ ! -d ${DIR_DEST} ] && [ "$1" = 'pull' ]; then
    echo "onedrivesync: ${DIR_SOURCE##*/}: no such directory in OneDrive"
    exit 1
fi

# push の処理 
if [ "$1" = 'push' ]; then
    rsync -auvh --delete ${DIR_SOURCE} ${DIR_ONEDRIVE} $2
    exit 0
# pull の処理
else
    rsync -auvh --delete ${DIR_DEST} ${DIR_PULL_TO} $2
    exit 0
fi
 
