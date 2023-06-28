#!/bin/bash
# 
# remotesync
# 

set -e


# ディレクトリの設定
REMOTE_SERVER=dsjumpserver
REMOTE_ROOT_DIR=/home/redcapit01/remotesync
LOCAL_DIR=$(pwd)
PULL_TO_DIR=$(dirname "${LOCAL_DIR}")
DIR_NAME=${LOCAL_DIR##*/}
REMOTE_DIR="${REMOTE_ROOT_DIR}/${DIR_NAME}"

# usage function を定義
function usage() {
    cat <<EOF
usage: remotesync [command]
command: push    copy files at local to remote
         pull    copy files at remote to local
         status  show infomation of local-remote synchronization
         ls      show all remote directories
         rm      remove an remote directory
         clean   remove all remote directories
EOF
    exit 1
}

# 引数のハンドリング
if [ ! $# -eq 1 ]; then
    usage
elif [ ! "$1" = 'push' ] && [ ! "$1" = 'pull' ] && [ ! "$1" = 'status' ] && [ ! "$1" = 'ls' ] && [ ! "$1" = 'rm' ] && [ ! "$1" = 'clean' ]; then
    usage
fi

# push の処理 
if [ "$1" = 'push' ]; then
    # rsync dry run
    rsync -auvh --delete --dry-run "${LOCAL_DIR}" "${REMOTE_SERVER}":"${REMOTE_ROOT_DIR}"
    # 実行の可否を問う
    echo -n 'Do you really want to run synchronization? [yes/no]: '
    read -r input
    if [ "$input" = 'no' ]; then 
        exit 0
    elif [ "$input" = 'yes' ]; then
        # rsync 実行
        rsync -auvh --delete "${LOCAL_DIR}" "${REMOTE_SERVER}":"${REMOTE_ROOT_DIR}"
    else
        echo "remotesync: $input: input yes or no"
        exit 1
    fi
# pull の処理
elif [ "$1" = 'pull' ]; then
    # rsync dry run
    rsync -auvh --delete --dry-run "${REMOTE_SERVER}":"${REMOTE_DIR}" "${PULL_TO_DIR}"
    # 実行の可否を問う
    echo -n 'Do you really want to run synchronization? [yes/no]: '
    read -r input
    if [ "$input" = 'no' ]; then 
        exit 0
    elif [ "$input" = 'yes' ]; then
        # rsync 実行
        rsync -auvh --delete "${REMOTE_SERVER}":"${REMOTE_DIR}" "${PULL_TO_DIR}"
    else
        echo "remotesync: $input: input yes or no"
        exit 1
    fi
# status の処理
elif [ "$1" = 'status' ]; then
    LOCAL_NUMBER=$(tree -a "${LOCAL_DIR}" | tail -n 1)
    LOCAL_UPDATE_TIME=$(ls -alFR --time-style=+'%Y-%m-%d %H:%M:%S' "${LOCAL_DIR}" | awk '$6!=""&&!/\/$/{print $6,$7}' | sort -r | head -n 1)
    REMOTE_NUMBER=$(ssh "${REMOTE_SERVER}" tree -a "${REMOTE_DIR}" | tail -n 1)
    REMOTE_UPDATE_TIME=$(ssh "${REMOTE_SERVER}" ls -alFR --time-style=+'%Y-%m-%d\ %H:%M:%S' "${REMOTE_DIR}" | awk '$6!=""&&!/\/$/{print $6,$7}' | sort -r | head -n 1)
    echo "dir name: ${DIR_NAME}"
    echo "local:    ${LOCAL_NUMBER}"
    echo "          updated at ${LOCAL_UPDATE_TIME}"
    echo "remote:   ${REMOTE_NUMBER}"
    echo "          updated at ${REMOTE_UPDATE_TIME}"
    exit 0
# ls の処理 
elif [ "$1" = 'ls' ]; then
    ssh "${REMOTE_SERVER}" ls -al "${REMOTE_ROOT_DIR}"
# rm の処理
elif [ "$1" = 'rm' ]; then
    # 実行の可否を問う
    echo -n "Do you really want to remove remote directory: ${REMOTE_DIR}? [yes/no]: "
    read -r input
    if [ "$input" = 'no' ]; then 
        exit 0
    elif [ "$input" = 'yes' ]; then
        ssh "${REMOTE_SERVER}" rm -rf "${REMOTE_DIR}"
    else
        echo "remotesync: $input: input yes or no"
        exit 1
    fi
# clean の処理
else
    # 実行の可否を問う
    echo -n 'Do you really want to remove all remote directories? [yes/no]: '
    read -r input
    if [ "$input" = 'no' ]; then 
        exit 0
    elif [ "$input" = 'yes' ]; then
        ssh "${REMOTE_SERVER}" rm -rf "${REMOTE_ROOT_DIR:?}"/*
    else
        echo "remotesync: $input: input yes or no"
        exit 1
    fi
fi
 
