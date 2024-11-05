import json
import os
import shutil
import requests
import subprocess
import sys

# 检查是否提供了文件路径参数
if len(sys.argv) < 2:
    print("Usage: python script_name.py <file_path>")
    sys.exit(1)

# 从命令行参数读取文件路径
file_path = sys.argv[1]

# 检查文件是否存在
if not os.path.isfile(file_path):
    print(f"Error: File {file_path} not found.")
    sys.exit(1)

# API endpoint
api_url = "http://localhost:8000/generate"

# Open the file in binary mode for upload
with open(file_path, 'rb') as file:
    files = {'file': file}
    
    # Send POST request with the file
    response = requests.post(api_url, files=files)

# Check if the request was successful
if response.status_code == 200:
    data = response.json()
    with open("../../logs/resp.log", "w+") as log_file:
        json.dump(data, log_file, indent=4)

    # Generate programs and update the Makefile
    for function in data["result"]["functions"]:
        func_name = function["funcName"]
        has_error = function.get("hasError", "N/A")
        reason = function.get("Reason", "N/A")

        # Log the information in targetFunc.log
        with open(f"../../logs/targetFunc.log", "a") as file:
            file.write(f"{file_path}${func_name}${has_error}${reason},\n")

    print("Processing completed successfully.")
else:
    print(f"Failed to get response from the API. Status code: {response.status_code}")
