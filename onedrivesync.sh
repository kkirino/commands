#!/bin/bash
# 
# onedrivesync
# 


# ディレクトリの設定
ONEDRIVE_DIR=/mnt/c/Users/kkirino/OneDrive/onedrivesync
LOCAL_DIR=$(pwd)
PULL_TO_DIR=$(dirname ${LOCAL_DIR})
DIR_NAME=${LOCAL_DIR##*/}
REMOTE_DIR=${ONEDRIVE_DIR}/${DIR_NAME}

# usage function を定義
function usage() {
    cat <<EOF
usage: onedrivesync [command]
command: push    copy files at local to remote on OneDrive
         pull    copy files at remote on OneDrive to local
         status  show infomation of local-remote synchronization
         ls      show all OneDrive remote directories
         rm      remove an OneDrive remote directory
         clean   remove all OneDrive remote directories
EOF
    exit 1
}

# エラーの対処
if [ ! $# -eq 1 ]; then
    usage
elif [ ! "$1" = 'push' ] && [ ! "$1" = 'pull' ] && [ ! "$1" = 'status' ] && [ ! "$1" = 'ls' ] && [ ! "$1" = 'rm' ] && [ ! "$1" = 'clean' ]; then
    usage
elif [ ! -d ${REMOTE_DIR} ] && [ "$1" = 'pull' ]; then
    echo "onedrivesync: ${DIR_NAME}: no remote directory detected"
    exit 1
elif [ ! -d ${REMOTE_DIR} ] && [ "$1" = 'rm' ]; then
    echo "onedrivesync: ${DIR_NAME}: no remote directory detected"
    exit 1
fi

# push の処理 
if [ "$1" = 'push' ]; then
    # rsync dry run
    rsync -auvh --delete ${LOCAL_DIR} ${ONEDRIVE_DIR} --dry-run
    # 実行の可否を問う
    echo -n 'Do you really want to run synchronization? [yes/no]: '
    read input
    if [ "$input" = 'no' ]; then 
        exit 0
    elif [ "$input" = 'yes' ]; then
        # rsync 実行
        rsync -auvh --delete ${LOCAL_DIR} ${ONEDRIVE_DIR}
    else
        echo "onedrivesync: $input: input yes or no"
        exit 1
    fi
# pull の処理
elif [ "$1" = 'pull' ]; then
    # rsync dry run
    rsync -auvh --delete ${REMOTE_DIR} ${PULL_TO_DIR} --dry-run
    # 実行の可否を問う
    echo -n 'Do you really want to run synchronization? [yes/no]: '
    read input
    if [ "$input" = 'no' ]; then 
        exit 0
    elif [ "$input" = 'yes' ]; then
        # rsync 実行
        rsync -auvh --delete ${REMOTE_DIR} ${PULL_TO_DIR}
    else
        echo "onedrivesync: $input: input yes or no"
        exit 1
    fi
# status の処理
elif [ "$1" = 'status' ]; then
    # OneDrive directory の有無を判定する
    if [ ! -d ${REMOTE_DIR} ]; then
        echo "onedrivesync: ${DIR_NAME}: no remote directory detected"
        exit 1
    else
        LOCAL_NUMBER=$(tree -a ${LOCAL_DIR} | tail -n 1)
        LOCAL_UPDATE_TIME=$(ls -alFR --time-style=+'%Y-%m-%d %H:%M:%S' ${LOCAL_DIR} | awk '$6!=""&&!/\/$/{print $6,$7}' | sort -r | head -n 1)
        REMOTE_NUMBER=$(tree -a ${REMOTE_DIR} | tail -n 1)
        REMOTE_UPDATE_TIME=$(ls -alFR --time-style=+'%Y-%m-%d %H:%M:%S' ${REMOTE_DIR} | awk '$6!=""&&!/\/$/{print $6,$7}' | sort -r | head -n 1)
        echo "name:    ${DIR_NAME}"
        echo "local:   ${LOCAL_NUMBER}"
        echo "         updated at ${LOCAL_UPDATE_TIME}"
        echo "rermote: ${REMOTE_NUMBER}"
        echo "         updated at ${REMOTE_UPDATE_TIME}"
        exit 0
    fi
# ls の処理 
elif [ "$1" = 'ls' ]; then
    ls -al ${ONEDRIVE_DIR}
# rm の処理
elif [ "$1" = 'ls' ]; then
    rm -rf ${REMOTE_DIR}
# clean の処理
else
    # 実行の可否を問う
    echo -n 'Do you really want to remove all OneDrive remote directories? [yes/no]: '
    read input
    if [ "$input" = 'no' ]; then 
        exit 0
    elif [ "$input" = 'yes' ]; then
        rm -rf ${ONEDRIVE_DIR}/*
    else
        echo "onedrivesync: $input: input yes or no"
        exit 1
    fi
fi
 
