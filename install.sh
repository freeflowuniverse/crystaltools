


if [[ "$OSTYPE" == "darwin"* ]]; then
    # brew install libgc
    brew install bdw-gc
else
    sudo apt install libgc-dev -y
    git clone https://github.com/vlang/v
    cd v
    make
    sudo ./v symlink
fi

