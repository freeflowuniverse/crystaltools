
set -e

#Check v already exists, if not then compile
if [ -d "~/.vmodules" ]
then
    sudo chown -R gitpod:gitpod ~/.vmodules
fi

if ! [ -x "$(command -v v)" ]; then
  echo 'Error: vlang is not installed.' >&2
  sudo rm -rf /workspace/v
fi

#Check v already exists, if not then compile
if [ -d "/workspace/v" ]
then
    echo "Directory /workspace/v exists."
else
    pushd /workspace
    sudo rm -rf /workspace/v
    sudo apt update
    sudo apt install libgc-dev -y
    git clone https://github.com/vlang/v
    cd v
    sudo make
    sudo ./v symlink
    popd "$@" > /dev/null
fi


#CHECK IF DIR EXISTS, IF NOT CLONE
if [ -d "/workspace/crystallib" ] 
then
    echo "Directory /workspace/crystallib exists." 
else
    pushd /workspace
    git clone https://github.com/crystaluniverse/crystallib
    cd crystallib
    git checkout refactor_publish_config
    # git switch -c origin/refactor_publish_config
    cd ..
    sudo rm -rf ~/.vmodules
    mkdir -p ~/.vmodules/despiegk/
    popd "$@" > /dev/null
fi

rm -rf ~/.vmodules
mkdir -p ~/.vmodules/despiegk
ln -s /workspace/crystallib ~/.vmodules/despiegk/crystallib

v install patrickpissurno.redis
v install despiegk.crystallib
v install nedpals.vex

# ssh-keyscan github.com >> ~/.ssh/known_hosts

if [ -d "/workspace/publishtools" ] 
then
    echo "Directory /workspace/publishtools exists, no reason to clone." 
else
    pushd /workspace
    git clone https://github.com/crystaluniverse/publishtools
    popd "$@" > /dev/null
fi


