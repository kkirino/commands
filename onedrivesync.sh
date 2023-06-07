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
usage: onedrivesync [command]
command: push   synchronize source to destination
         pull   synchronize destination to source
         rm     remove OneDrive directory
EOF
    exit 1
}

# エラーの対処
if [ ! $# -eq 1 ]; then
    usage
elif [ ! "$1" = 'push' ] && [ ! "$1" = 'pull' ] && [ ! "$1" = 'rm' ]; then
    usage
elif [ ! -d ${DIR_DEST} ] && [ "$1" = 'pull' ]; then
    echo "onedrivesync: ${DIR_SOURCE##*/}: no such directory in OneDrive"
    exit 1
elif [ ! -d ${DIR_DEST} ] && [ "$1" = 'rm' ]; then
    echo "onedrivesync: ${DIR_SOURCE##*/}: no such directory in OneDrive"
    exit 1
fi

# push の処理 
if [ "$1" = 'push' ]; then
    # rsync dry run
    rsync -auvh --delete ${DIR_SOURCE} ${DIR_ONEDRIVE} --dry-run
    # 実行の可否を問う
    echo -n Do you really want to run synchronization? [yes/no]: 
    read input
    if [ "$input" = "no" ]; then 
        exit 0
    elif [ "$input" = "yes" ]; then
        # rsync 実行
        rsync -auvh --delete ${DIR_SOURCE} ${DIR_ONEDRIVE}
        exit 0
    else
        echo "onedrivesync: $input: input yes or no"
        exit 1
    fi
# pull の処理
elif [ "$1" = 'pull' ]; then
    # rsync dry run
    rsync -auvh --delete ${DIR_DEST} ${DIR_PULL_TO} --dry-run
    # 実行の可否を問う
    echo -n Do you really want to run synchronization? [yes/no]: 
    read input
    if [ "$input" = "no" ]; then 
        exit 0
    elif [ "$input" = "yes" ]; then
        # rsync 実行
        rsync -auvh --delete ${DIR_DEST} ${DIR_PULL_TO}
        exit 0
    else
        echo "onedrivesync: $input: input yes or no"
        exit 1
    fi
# rm の処理
else
    rm -rf ${DIR_DEST}
    exit 0
fi
 
