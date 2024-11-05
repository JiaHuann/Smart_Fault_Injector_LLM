set -x
check_env() {
    if [ -d "../.venv" ]; then
        echo "Virtual environment already exists. Skipping virtual environment creation."
        source ../.venv/bin/activate
    else
        echo "=======Creating virtual environment...======="
        python3 -m venv ../.venv
        source ../.venv/bin/activate
        pip install -r ../requirements.txt -i https://bytedpypi.byted.org/simple
            if [ $? -ne 0 ]; then
            echo "Error creating virtual environment. Exiting..."
            exit 1
        fi
    fi
}

check_env

cd /usr/share/faultInjectionLLM/src/server
python server.py