import os

# 获取用户输入的函数名称、错误类型及频率
def get_user_defined_functions():
    functions = []

    while True:
        func_name = input("Enter the function name (or 'q' to finish): ").strip()
        if func_name.lower() == 'q':
            break
        if not func_name:
            print("Function name cannot be empty.")
            continue

        errors = []
        total_frequency = 0

        while total_frequency < 100:
            error_type = input("Enter error type (or 'q' to stop adding errors for this function): ").strip()
            if error_type.lower() == 'q':
                break
            if not error_type:
                print("Error type cannot be empty.")
                continue

            remaining = 100 - total_frequency
            try:
                frequency = int(input(f"Enter frequency for {error_type} (remaining: {remaining}): "))
                if 0 < frequency <= remaining:
                    errors.append((error_type, frequency))
                    total_frequency += frequency
                else:
                    print(f"Frequency must be between 1 and {remaining}.")
            except ValueError:
                print("Please enter a valid number.")

        if errors:
            functions.append({
                'file_name': '',  # Path is not provided, so it's left empty
                'func_name': func_name,
                'errors': errors
            })

    return functions

# 主函数
def main():
    new_log_file_path = '../../logs/selectedFunc.log'  # 新的日志文件路径

    # 获取用户定义的函数、错误类型及频率
    selected_functions = get_user_defined_functions()

    if not selected_functions:
        print("No functions added.")
        return

    # 创建目录（如果不存在）
    os.makedirs(os.path.dirname(new_log_file_path), exist_ok=True)

    # 输出用户选择结果
    print("\nSelected functions, errors, and frequencies:")
    for result in selected_functions:
        errors_output = ",".join([f"{err[0]},{err[1]}" for err in result['errors']])
        print(f"{result['file_name']},{result['func_name']},{errors_output}")

    # 将选择结果保存到新的日志文件中
    try:
        with open(new_log_file_path, 'w') as file:
            for result in selected_functions:
                errors_output = ",".join([f"{err[0]},{err[1]}" for err in result['errors']])
                file.write(f"{result['file_name']},{result['func_name']},{errors_output}\n")
        print(f"\nNew log file created at {new_log_file_path}.")
    except Exception as e:
        print(f"Failed to write to log file: {e}")

if __name__ == "__main__":
    main()
