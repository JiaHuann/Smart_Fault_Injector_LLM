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
