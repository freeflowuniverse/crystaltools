


if [[ "$OSTYPE" == "darwin"* ]]; then
    # brew install libgc
    brew install bdw-gc
else
    sudo apt install libgc-dev
    git clone https://github.com/vlang/v
    cd v
    make
    sudo ./v symlink
fi

v install patrickpissurno.redis
v install despiegk.crystallib
v install nedpals.vex
