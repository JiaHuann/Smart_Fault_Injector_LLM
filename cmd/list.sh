#!/bin/bash

# 检查是否传递了目标参数
if [ -z "$1" ]; then
    echo "Usage: $0 {recommend|select|verified}"
    exit 1
fi

# 根据目标参数选择日志文件
if [ "$1" == "recommend" ]; then
    log_file="../logs/targetFunc.log"
elif [ "$1" == "select" ]; then
    log_file="../logs/selectedFunc.log"
elif [ "$1" == "verified" ]; then
    log_file="../logs/verifiedFunc.log"
else
    echo "Invalid target specified. Use 'recommend' or 'select'."
    exit 1
fi

# 检查日志文件是否存在
if [ ! -f "$log_file" ]; then
    echo "Log file $log_file not found!"
    exit 1
fi

# 读取并格式化显示日志内容
echo "Reading log file: $log_file"

# 格式化并通过 less 命令翻页显示
{
    echo "FILE PATH                                                                                        FUNCTION NAME                        ERROR TYPES                           REASON"
    echo "------------------------------------------------------------------------------------------------ ----------------------------------- ------------------------------------- ------------------------------------------------"
    awk -F'$' '{printf "%-100s %-35s %-37s %-s\n", $1, $2, $3, $4}' "$log_file"
} | less -S
