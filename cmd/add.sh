#!/bin/bash

# 清理 ../build/bin/ 目录中的可执行程序
cleanup_previous_builds() {
    echo "Cleaning up previous executable files in ../build/bin/..."
    find ../build/bin/ -type f -executable -exec rm {} \;

    echo "Cleaning up files in ../build/src/libbpf-bootstrap/examples/c/ except for Makefile..."
    find ../build/src/libbpf-bootstrap/examples/c/ -type f ! -name 'Makefile' -exec rm {} \;

    echo "Cleaning up log files in ../logs/..."
    sudo rm -rf ../logs/*.log 

    echo "Cleaning previous uploads in ../uploads/..."
    rm -r ../uploads/*.c 

    makefile_path="../build/src/libbpf-bootstrap/examples/c/Makefile"
    if [ -f "$makefile_path" ]; then
        # 使用 sed 清除 APPS = 行中的内容，但保留 APPS += $(BZS_APPS)
        sed -i '/^APPS =/s/=.*/=/' "$makefile_path"
        echo "Cleared APPS variable in $makefile_path"
    else
        echo "Makefile not found at $makefile_path"
    fi

}

# 激活虚拟环境
activate_virtual_environment() {
    echo "Activating Python virtual environment..."
    pwd
    source ../.venv/bin/activate
}

# 进入客户端目录
change_to_client_directory() {
    cd ../src/client || { echo "Failed to change directory to ../src/client. Exiting..."; exit 1; }
}

# 处理单个文件
process_file() {
    local file_path="$1"
    if [ -f "$file_path" ]; then
        echo "Processing file: $file_path"
        python getSingleFile.py "$file_path"
        if [ $? -ne 0 ]; then
            echo "Error processing $file_path with getSingleFile.py. Exiting..."
            exit 1
        fi
    else
        echo "Invalid path: $file_path. Please check the file path and try again."
        exit 1
    fi
}

process_multiple_files() {
    shift  # 移除 'multi' 参数
    if [ "$#" -eq 0 ]; then
        echo "No files provided. Please provide at least one file path."
        exit 1
    fi

    # 启用 globstar 以支持 '**' 递归匹配
    shopt -s globstar

    file_paths=()

    # 处理每个文件路径或通配符
    for file_path in "$@"; do
        # 展开通配符模式并递归查找
        expanded_files=$(echo $file_path)
        for expanded_file in $expanded_files; do
            if [ -f "$expanded_file" ]; then
                file_paths+=("$expanded_file")
            else
                echo "Warning: No matching files for pattern '$file_path'"
            fi
        done
    done

    if [ "${#file_paths[@]}" -eq 0 ]; then
        echo "No valid files found."
        exit 1
    fi

    # 处理所有有效的文件路径
    for file_path in "${file_paths[@]}"; do
        process_file "$file_path"
    done

    # 关闭 globstar（可选）
    shopt -u globstar
}




# 选择函数(交互式)
run_choose_script_interact() {
    echo "=====Running choose.py with interact mode...======"
    python choose.py -i
    if [ $? -ne 0 ]; then
        echo "Error running choose.py. Exiting..."
        exit 1
    fi
}

# 选择函数(默认式)
run_choose_script_default() {
    echo "=====Running choose.py with default mode...======="
    python choose.py default
    if [ $? -ne 0 ]; then
        echo "Error running choose.py. Exiting..."
        exit 1
    fi
}

check_env() {
    if [ -d "../.venv" ]; then
        echo "Virtual environment already exists. Skipping virtual environment creation."
    else
        echo "Creating virtual environment..."
        python3 -m venv../.venv
        if [ $? -ne 0 ]; then
            echo "Error creating virtual environment. Exiting..."
            exit 1
        fi
    fi
}

# 主函数
main() {
    check_env

    activate_virtual_environment
    if [ "$1" == "maunal" ]; then
        change_to_client_directory
        python add-maunal.py
        exit 1
    fi    

    if [ "$1" == "multi" ]; then
        cleanup_previous_builds
        change_to_client_directory
        process_multiple_files "$@"
        run_choose_script_interact
    fi

    if [ "$1" == "default" ]; then
        cleanup_previous_builds
        change_to_client_directory
        process_multiple_files "$@"
        run_choose_script_default
    else
        echo "Usage Error: Please use 'multi' or 'default' followed by one or more file paths."
        echo "Example: ./add.sh [multi | default] /path/to/file1.c /path/to/file2.c"
        exit 1
    fi

    echo "Script completed successfully!"
}

main "$@"
