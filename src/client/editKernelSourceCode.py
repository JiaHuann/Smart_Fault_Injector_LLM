# [deperated] will not be used 

import os

# 读取 selectedFunc.log 文件并解析
def read_selected_functions(log_file):
    selected_functions = []
    with open(log_file, 'r') as file:
        for line in file:
            parts = line.strip().split(',')
            if len(parts) == 3:
                file_path, func_name, error_value = parts
                selected_functions.append({
                    'file_path': file_path,
                    'func_name': func_name,
                    'error_value': error_value
                })
    return selected_functions

# 根据 error_value 决定宏的第二个参数
def determine_error_type(error_value):
    if error_value.startswith('-'):
        return "ERRNO"
    elif error_value.lower() == "true":
        return "TRUE"
    elif error_value.lower() == "false":
        return "TRUE"
    elif error_value.lower() == "NULL":
        return "0"
    else:
        return "ERRNO"  # 默认处理为 ERRNO

# 在文件末尾添加 ALLOW_ERROR_INJECTION 宏
def add_allow_error_injection(file_path, func_name, error_type):
    try:
        with open(file_path, 'a') as file:
            file.write(f"\nALLOW_ERROR_INJECTION({func_name}, {error_type});\n")
        print(f"[Kernel Source Code] Added ALLOW_ERROR_INJECTION({func_name}, {error_type}) to {file_path}")
    except Exception as e:
        print(f"Failed to update {file_path}: {e}")
        
def add_include(file_path):
    try:
        with open(file_path, 'a') as file:
            file.write(f"\n#include <asm-generic/error-injection.h>\n")
        print(f"[Kernel Source Code] Add <asm-generic/error-injection.h> include file.")
    except Exception as e:
        print(f"Failed to update {file_path}: {e}")

# 主函数逻辑
def main():
    log_file_path = "../../logs/selectedFunc.log"
    
    # 读取 selectedFunc.log 文件
    selected_functions = read_selected_functions(log_file_path)

    if not selected_functions:
        print(f"No functions found in {log_file_path}.")
        return
    
    first_iteration = True
    # 处理每个函数，添加宏定义
    for entry in selected_functions:        
        file_path = entry["file_path"]
        func_name = entry["func_name"]
        error_value = entry["error_value"]
        error_type = determine_error_type(error_value)
        
        if first_iteration:
            add_include(file_path)
            first_iteration = False
        # 在文件末尾添加 ALLOW_ERROR_INJECTION 宏
        add_allow_error_injection(file_path, func_name, error_type)

if __name__ == "__main__":
    main()
