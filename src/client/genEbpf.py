import os
import shutil
import subprocess

# Path to the selected log file
selected_log_file = "../../logs/verifiedFunc.log"

# Template for eBPF program
ebpf_template = """
#include "vmlinux.h"
#include <bpf/bpf_helpers.h>
#include <bpf/bpf_tracing.h>
#include "bpf/bpf_core_read.h"
#include <errno.h>

SEC("kprobe/{func_name}")
int kprobe_{func_name}(struct pt_regs *ctx) {{
    u32 pid = bpf_get_current_pid_tgid() >> 32;

    u64 timestamp = bpf_ktime_get_ns();
    char comm[TASK_COMM_LEN];
    bpf_get_current_comm(comm, TASK_COMM_LEN);

    u64 random_value = timestamp % 100;

    {error_injection_logic}

    return 0;
}}

char _license[] SEC("license") = "GPL";
"""

# Template for user-space program
user_space_template = """
// SPDX-License-Identifier: (LGPL-2.1 OR BSD-2-Clause)
/* Copyright (c) 2021 Sartura
 * Based on minimal.c by Facebook */

#include <stdio.h>
#include <unistd.h>
#include <signal.h>
#include <string.h>
#include <errno.h>
#include <sys/resource.h>
#include <bpf/libbpf.h>
#include "{func_name}.skel.h"

static int libbpf_print_fn(enum libbpf_print_level level, const char *format, va_list args)
{{
    return vfprintf(stderr, format, args);
}}

static volatile sig_atomic_t stop;

static void sig_int(int signo)
{{
    stop = 1;
}}

int main(int argc, char **argv)
{{
    struct {func_name}_bpf *skel;
    int err;

    /* Set up libbpf errors and debug info callback */
    libbpf_set_print(libbpf_print_fn);

    /* Open load and verify BPF application */
    skel = {func_name}_bpf__open_and_load();
    if (!skel) {{
        fprintf(stderr, "Failed to open BPF skeleton\\n");
        return 1;
    }}

    /* Attach tracepoint handler */
    err = {func_name}_bpf__attach(skel);
    if (err) {{
        fprintf(stderr, "Failed to attach BPF skeleton\\n");
        goto cleanup;
    }}

    if (signal(SIGINT, sig_int) == SIG_ERR) {{
        fprintf(stderr, "can't set signal handler: %s\\n", strerror(errno));
        goto cleanup;
    }}

    printf("Successfully started! Please run `sudo cat /sys/kernel/debug/tracing/trace_pipe` "
           "to see output of the BPF programs.\\n");

    while (!stop) {{
        fprintf(stderr, ".");
        sleep(1);
    }}

cleanup:
    {func_name}_bpf__destroy(skel);
    return -err;
}}
"""

NULL_OVERRIDE_VALUE='0'

# Function to generate eBPF program
def generate_ebpf_program(func_name, error_injection_logic):
    return ebpf_template.format(func_name=func_name, error_injection_logic=error_injection_logic)

# Function to generate user-space program
def generate_user_space_program(func_name):
    return user_space_template.format(func_name=func_name)

# Path to the Makefile
makefile_path = "../../build/src/libbpf-bootstrap/examples/c/Makefile"

# Function to update the Makefile
def update_makefile(func_name):
    with open(makefile_path, 'r') as file:
        makefile_content = file.read()
    
    # Update the APPS variable
    if f" {func_name}" not in makefile_content:
        new_content = makefile_content.replace("APPS =", f"APPS = {func_name} ")
        with open(makefile_path, 'w') as file:
            file.write(new_content)
        print(f"Updated Makefile with {func_name}")
    else:
        print(f"{func_name} is already in the Makefile")

# Read selected functions and errors from the log file
def read_selected_functions(log_file):
    selected_functions = []
    with open(log_file, 'r') as file:
        for line in file:  # 逐行读取文件
            line = line.strip()  # 去除每行的前后空白字符
            if line:  # 确保行不为空
                parts = line.split(',')
                if len(parts) >= 4 and len(parts) % 2 == 0:
                    file_path, func_name = parts[0], parts[1]
                    errors = [(parts[i], int(parts[i+1])) for i in range(2, len(parts), 2)]
                    selected_functions.append({
                        'file_path': file_path,
                        'func_name': func_name,
                        'errors': errors
                    })
    return selected_functions


# Generate error injection logic based on probabilities
def generate_error_injection_logic(func_name, errors):
    logic_lines = []
    cumulative_prob = 0
    for error, probability in errors:
        cumulative_prob += probability
        override_value = NULL_OVERRIDE_VALUE if error == "NULL" else error
        logic_lines.append(f"if (random_value < {cumulative_prob}) {{")
        logic_lines.append(f"    bpf_printk(\"[ERR_INJECTION] ---- <{func_name}> Intercepted with {error} ----\");")
        logic_lines.append(f"    bpf_override_return(ctx, {override_value});")
        logic_lines.append("} else ")
    logic_lines[-1] = logic_lines[-1].replace(" else ", "")  # Remove trailing "else"
    return "\n".join(logic_lines)




# Main script logic
selected_functions = read_selected_functions(selected_log_file)

if not selected_functions:
    print(f"No functions found in {selected_log_file}.")
    exit(1)

# Generate programs and update the Makefile
for entry in selected_functions:
    func_name = entry["func_name"]
    errors = entry["errors"]

    # Generate the error injection logic
    error_injection_logic = generate_error_injection_logic(func_name,errors)

    # Generate and save eBPF program
    ebpf_program = generate_ebpf_program(func_name, error_injection_logic)
    with open(f"../../build/src/libbpf-bootstrap/examples/c/{func_name}.bpf.c", "w") as file:
        file.write(ebpf_program)
    print(f"Generated eBPF program for {func_name}")
    
    # Generate and save user-space program
    user_space_program = generate_user_space_program(func_name)
    with open(f"../../build/src/libbpf-bootstrap/examples/c/{func_name}.c", "w") as file:
        file.write(user_space_program)
    print(f"Generated user-space program for {func_name}")
    
    # Update Makefile
    update_makefile(func_name)

# Compile the programs
subprocess.run(["make", "-j", "12", "-C", "../../build/src/libbpf-bootstrap/examples/c/"])

# Move the executables to the build/bin directory
bin_directory = "../../build/bin"
if not os.path.exists(bin_directory):
    os.makedirs(bin_directory)

executables_path = "../../build/src/libbpf-bootstrap/examples/c/"
executables = [f for f in os.listdir(executables_path) if os.path.isfile(os.path.join(executables_path, f)) and not f.endswith(('.c', '.o', '.bpf.c', '.skel.h','Makefile'))]

for executable in executables:
    shutil.move(os.path.join(executables_path, executable), os.path.join(bin_directory, executable))
    print(f"Moved {executable} to {bin_directory}")

print("Programs generated and compiled successfully.")
