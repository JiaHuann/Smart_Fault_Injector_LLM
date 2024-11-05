#!/bin/bash

# 杀掉已有的 faultInjectionLLM_Monitor 会话
tmux kill-session -t faultInjectionLLM_Monitor 2>/dev/null

# 定义 tmux 会话名称
SESSION_NAME="faultInjectionLLM_Monitor"

# 检查 tmux 是否安装
if ! command -v tmux &> /dev/null; then
    echo "tmux is not installed. Please install tmux first."
    exit 1
fi

# 检查是否已存在同名 tmux 会话
tmux has-session -t $SESSION_NAME 2>/dev/null

if [ $? != 0 ]; then
    # 创建新的 tmux 会话，命名为 $SESSION_NAME
    tmux new-session -d -s $SESSION_NAME

    # 传递所有参数给 start.sh
    tmux send-keys -t $SESSION_NAME "./start.sh $*; tmux kill-session -t $SESSION_NAME" C-m

    # 在右侧窗格创建新面板并运行命令
    tmux split-window -h -t $SESSION_NAME
    tmux send-keys -t $SESSION_NAME "sudo dmesg -w " C-m

    # 选择第一个窗格（左侧）
    tmux select-pane -t 0

    # 启动 tmux 会话
    tmux attach-session -t $SESSION_NAME

    # 在会话结束时清除所有 tmux 会话
    tmux kill-server
else
    echo "Session $SESSION_NAME already exists. Please close it or use another name."
    exit 1
fi
