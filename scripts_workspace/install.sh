
set -ex

#Check v already exists, if not then compile
if [ -d "/workspace/v" ]
then
    echo "Directory /workspace/v exists."
else
    pushd /workspace
    sudo rm -rf /workspace/v
    sudo apt install libgc-dev -y
    git clone https://github.com/vlang/v
    cd v
    sudo make
    sudo ./v symlink
    popd
fi


#CHECK IF DIR EXISTS, IF NOT CLONE
if [ -d "/workspace/crystallib" ] 
then
    echo "Directory /workspace/crystallib exists." 
else
    pushd /workspace
    git clone https://github.com/crystaluniverse/crystallib
    git checkout refactor_publish_config
    rm -rf ~/.vmodules
    mkdir -p ~/.vmodules/despiegk/
    popd
fi

rm -rf ~/.vmodules/despiegk/crystallib
ln -s /workspace/crystallib ~/.vmodules/despiegk/crystallib

v install patrickpissurno.redis
v install despiegk.crystallib
v install nedpals.vex

# ssh-keyscan github.com >> ~/.ssh/known_hosts

if [ -d "/workspace/publishtools" ] 
then
    echo "Directory /workspace/publishtools exists." 
else
    pushd /workspace
    git clone https://github.com/crystaluniverse/publishtools
    popd
fi


