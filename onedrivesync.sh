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
command: push    copy files in local dir to OneDrive remote dir
         pull    copy OneDrive remote dir files to local dir
         status  show information of local and remote synchronization
         rm      remove iOneDrive dir
EOF
    exit 1
}

# エラーの対処
if [ ! $# -eq 1 ]; then
    usage
elif [ ! "$1" = 'push' ] && [ ! "$1" = 'pull' ] && [ ! "$1" = 'status' ] && [ ! "$1" = 'rm' ]; then
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
        exit 0
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
        exit 0
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
        LOCAL_FILE_NUMBER=$(find ${LOCAL_DIR} -type f | wc -l)
        LOCAL_UPDATE_TIME=$(ls -alFR --time-style=+'%Y-%m-%d %H:%M:%S' ${LOCAL_DIR} | awk '$6!=""{print $6,$7}' | sort -r | head -n 1)
        REMOTE_FILE_NUMBER=$(find ${REMOTE_DIR} -type f | wc -l)
        REMOTE_UPDATE_TIME=$(ls -alFR --time-style=+'%Y-%m-%d %H:%M:%S' ${REMOTE_DIR} | awk '$6!=""{print $6,$7}' | sort -r | head -n 1)
        echo "name:    ${DIR_NAME}"
        echo "local:   ${LOCAL_FILE_NUMBER} files detected"
        echo "         updated at ${LOCAL_UPDATE_TIME}"
        echo "rermote: ${REMOTE_FILE_NUMBER} files detected"
        echo "         updated at ${REMOTE_UPDATE_TIME}"
        exit 0
    fi
# rm の処理
else
    rm -rf ${REMOTE_DIR}
    exit 0
fi
 
