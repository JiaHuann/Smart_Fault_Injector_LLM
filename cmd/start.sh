#!/bin/bash

BIN_DIR="../build/bin"
LOG_FILE="../logs/process_log_$(date '+%Y%m%d_%H%M%S').log"

if [ ! -d "$BIN_DIR" ]; then
    echo -e "\e[31mError: 目录 $BIN_DIR 不存在！你是否已经选择了注入点？.\e[0m" | tee -a "$LOG_FILE"
    exit 1
fi

# 退出信号捕捉
trap 'echo -e "\e[31m$(date +"%Y-%m-%d %H:%M:%S") - Terminating all running processes...\e[0m" | tee -a "$LOG_FILE"; kill $(jobs -p); wait; echo -e "\e[31m$(date +"%Y-%m-%d %H:%M:%S") - All processes terminated.\e[0m" | tee -a "$LOG_FILE"; exit' SIGINT SIGTERM

declare -A running_processes
declare -A finished_processes
MAX_EXECUTION_TIME=0  # Default to no time limit

# 运行单个注入点，并让其挂起
run_executable() {
    local executable="$1"
    echo -e "\e[32m$(date +"%Y-%m-%d %H:%M:%S") - Preloading $executable...\e[0m" | tee -a "$LOG_FILE"
    sudo "$executable" &
    pid=$!  # 获取pid
    running_processes[$pid]="$executable"
    kill -STOP $pid  # 暂时挂起进程
}

# 一次性注入
run_once_strategy() {
    # 预加载所有可执行文件
    for executable in "$BIN_DIR"/*; do
        if [ -f "$executable" ] && [ -x "$executable" ]; then
            run_executable "$executable"
        else
            echo -e "\e[31m$(date +"%Y-%m-%d %H:%M:%S") - Skipping $executable (not an executable file)\e[0m" | tee -a "$LOG_FILE"
        fi
    done

    # 所有进程都已加载，开始恢复运行
    echo -e "\e[32m$(date +"%Y-%m-%d %H:%M:%S") - All processes preloaded. Starting all processes...\e[0m" | tee -a "$LOG_FILE"
    for pid in "${!running_processes[@]}"; do
        kill -CONT $pid  # 恢复运行进程
        echo -e "\e[32m$(date +"%Y-%m-%d %H:%M:%S") - Process ${running_processes[$pid]} (PID $pid) is now running.\e[0m" | tee -a "$LOG_FILE"
    done

    # 监控进程状态
    monitor_processes
}

# 生命周期检查 以及输出
monitor_processes() {
    start_time=$(date +%s)
    while [ ${#running_processes[@]} -gt 0 ]; do
        for pid in "${!running_processes[@]}"; do
            if ps -p $pid > /dev/null; then
                echo -e "\e[32m$(date +"%Y-%m-%d %H:%M:%S") - Process ${running_processes[$pid]} (PID $pid) is still running.\e[0m" | tee -a "$LOG_FILE"
            else
                wait $pid
                exit_status=$?
                if [ $exit_status -eq 0 ]; then
                    echo -e "\e[32m$(date +"%Y-%m-%d %H:%M:%S") - Process ${running_processes[$pid]} (PID $pid) finished successfully.\e[0m" | tee -a "$LOG_FILE"
                else
                    echo -e "\e[31m$(date +"%Y-%m-%d %H:%M:%S") - Process ${running_processes[$pid]} (PID $pid) exited with status $exit_status.\e[0m" | tee -a "$LOG_FILE"
                fi
                finished_processes[$pid]="${running_processes[$pid]} (Exited with status $exit_status)"
                unset running_processes[$pid]  # Remove finished process from array
            fi
        done

        # 检查是否超过最大执行时间
        if [ $MAX_EXECUTION_TIME -gt 0 ]; then
            current_time=$(date +%s)
            elapsed_time=$((current_time - start_time))
            if [ $elapsed_time -ge $MAX_EXECUTION_TIME ]; then
                echo -e "\e[31m$(date +"%Y-%m-%d %H:%M:%S") - Maximum execution time of $MAX_EXECUTION_TIME seconds reached. Terminating all processes...\e[0m" | tee -a "$LOG_FILE"
                kill $(jobs -p)  # Terminate all running jobs
                wait
                break
            fi
        fi

        sleep 2  # Wait 2 seconds before rechecking
    done
    echo "$(date +"%Y-%m-%d %H:%M:%S") - All executables have been run." | tee -a "$LOG_FILE"
}

# 渐进式注入，每五秒进行一次
run_progressive_strategy() {
    for executable in "$BIN_DIR"/*; do
        if [ -f "$executable" ] && [ -x "$executable" ]; then
            run_executable "$executable"
            sleep 5  # Wait 5 seconds before starting the next executable
        else
            echo -e "\e[31m$(date +"%Y-%m-%d %H:%M:%S") - Skipping $executable (not an executable file)\e[0m" | tee -a "$LOG_FILE"
        fi
    done
    monitor_processes
}


parse_param_and_run() {
    # 检查时间参数并转换为秒
    if [[ "$2" =~ ^[0-9]+[smhd]$ ]]; then
        unit="${2: -1}"
        value="${2:0:-1}"
        case $unit in
            s) MAX_EXECUTION_TIME=$((value)) ;;
            m) MAX_EXECUTION_TIME=$((value * 60)) ;;
            h) MAX_EXECUTION_TIME=$((value * 3600)) ;;
            d) MAX_EXECUTION_TIME=$((value * 86400)) ;;
            *) echo -e "\e[31mInvalid time unit provided. Use s for seconds, m for minutes, h for hours, or d for days.\e[0m" | tee -a "$LOG_FILE"; exit 1 ;;
        esac
    elif [ -n "$2" ]; then
        echo -e "\e[31mInvalid time format. Please use a number followed by s, m, h, or d.\e[0m" | tee -a "$LOG_FILE"
        exit 1
    fi
    if [ "$1" == "once" ]; then
        run_once_strategy
    elif [ "$1" == "progressive" ]; then
        run_progressive_strategy
    else
        echo -e "\e[31mUsage: $0 {once|progressive} [time]\e[0m" | tee -a "$LOG_FILE"
        exit 1
    fi
}

redirect_trace_pipe(){
    ./redirect.sh & > /dev/null
}


parse_param_and_run "$1" "$2"
 


