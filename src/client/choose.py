import os
import ast
import sys

# 读取文件内容并解析
def read_functions_log(file_path):
    functions = []
    with open(file_path, 'r') as file:
        for line in file:
            parts = line.strip().split('$')
            file_name = parts[0]
            func_name = parts[1]
            try:
                has_errors = ast.literal_eval(parts[2]) if parts[2] else []
            except (SyntaxError, ValueError):
                has_errors = parts[2].strip("[]").replace("'", "").split(", ")
            reason = parts[3]
            target_error = parts[4] if len(parts) > 4 else ''
            functions.append({
                'file_name': file_name,
                'func_name': func_name,
                'has_errors': has_errors,
                'reason': reason,
                'target_error': target_error
            })
    return functions

# 打印函数列表供用户选择
def display_functions(functions):
    print("Available functions:")
    for idx, func in enumerate(functions):
        errors_display = ', '.join(func['has_errors']) if func['has_errors'] else 'No errors available'
        print(f"{idx + 1}: {func['func_name']} ({errors_display})")

# 获取用户选择的函数
def get_user_function_selection(functions):
    selected_funcs = []
    while True:
        try:
            choice = input("Select function(s) by number (comma-separated for multiple, 'q' to quit): ")
            if choice.lower() == 'q':
                break
            indices = [int(i) - 1 for i in choice.split(',')]
            for index in indices:
                if 0 <= index < len(functions):
                    selected_funcs.append(functions[index])
                else:
                    print(f"Invalid choice: {index + 1}")
        except ValueError:
            print("Please enter valid numbers.")
    return selected_funcs

# 获取用户选择的错误类型及频率
def get_user_error_selection(func):
    print(f"\nSelecting error type and frequency for function: {func['func_name']}")
    selected_errors = []
    total_frequency = 0

    for idx, error in enumerate(func['has_errors']):
        print(f"{idx + 1}: {error}")
    while total_frequency < 100:
        try:
            choice = int(input("Select error type by number (or 0 to finish): ")) - 1
            if choice == -1:
                break
            if 0 <= choice < len(func['has_errors']):
                remaining = 100 - total_frequency
                frequency = int(input(f"Enter frequency for {func['has_errors'][choice]} (remaining: {remaining}): "))
                if 0 < frequency <= remaining:
                    selected_errors.append((func['has_errors'][choice], frequency))
                    total_frequency += frequency
                else:
                    print(f"Frequency must be between 1 and {remaining}.")
            else:
                print("Invalid choice.")
        except ValueError:
            print("Please enter a valid number.")

    return selected_errors

# 默认选择：15%概率，以及指定第一个错误
def select_func_default(functions):
    selected_results = []

    for func in functions:
        if func['has_errors']:
            # 为每个错误类型设置概率为 5%
            selected_errors = [(error, 5) for error in func['has_errors']]
            selected_results.append({
                'file_name': func['file_name'],
                'func_name': func['func_name'],
                'errors': selected_errors
            })
        else:
            print(f"No errors available for function: {func['func_name']}")

    return selected_results


    

# 主函数
def main():
    log_file_path = '../../logs/targetFunc.log'
    new_log_file_path = '../../logs/selectedFunc.log'  # 新的日志文件路径

    # 检查参数
    if len(sys.argv) != 2 or sys.argv[1] not in ['-i', 'default']:
        print("Usage: script.py [-i | default]")
        print("  -i        Run in interactive mode")
        print("  default   Run with default settings")
        return

    # 读取函数数据
    functions = read_functions_log(log_file_path)

    if not functions:
        print("No functions found in the log.")
        return

    # 检查是否是交互式模式
    if sys.argv[1] == '-i':
        # 显示函数并获取用户选择
        display_functions(functions)
        selected_funcs = get_user_function_selection(functions)

        if not selected_funcs:
            print("No functions selected.")
            return

        # 获取用户为每个函数选择的错误类型及频率
        selected_results = []
        for func in selected_funcs:
            if func['has_errors']:
                selected_errors = get_user_error_selection(func)
                if selected_errors:
                    selected_results.append({
                        'file_name': func['file_name'],
                        'func_name': func['func_name'],
                        'errors': selected_errors
                    })
            else:
                print(f"No errors available for function: {func['func_name']}")
    else:
        # 执行默认逻辑
        selected_results = select_func_default(functions)

    if not selected_results:
        print("No errors selected for any functions.")
        return

    # 创建目录（如果不存在）
    os.makedirs(os.path.dirname(new_log_file_path), exist_ok=True)

    # 输出用户选择结果
    print("\nSelected functions, errors, and frequencies:")
    for result in selected_results:
        errors_output = ",".join([f"{err[0]},{err[1]}" for err in result['errors']])
        print(f"{result['file_name']},{result['func_name']},{errors_output}")

    # 将选择结果保存到新的日志文件中
    try:
        with open(new_log_file_path, 'w') as file:
            for result in selected_results:
                errors_output = ",".join([f"{err[0]},{err[1]}" for err in result['errors']])
                file.write(f"{result['file_name']},{result['func_name']},{errors_output}\n")
        print(f"\nNew log file created at {new_log_file_path}.")
    except Exception as e:
        print(f"Failed to write to log file: {e}")

if __name__ == "__main__":
    main()
