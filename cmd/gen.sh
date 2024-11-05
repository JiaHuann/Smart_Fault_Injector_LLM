check_env() {
    if [ -d "../.venv" ]; then
        echo "Virtual environment already exists. Skipping virtual environment creation."
        source ../.venv/bin/activate
    else
        echo "=======Creating virtual environment...======="
        python -m venv ../.venv
        source ../.venv/bin/activate
        pip install -r ../requirements.txt
            if [ $? -ne 0 ]; then
            echo "Error creating virtual environment. Exiting..."
            exit 1
        fi
    fi
}

check_env
cd ../src/client
python ./genEbpf.py