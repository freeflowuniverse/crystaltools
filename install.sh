set -e
if [[ -z "${PBRANCH}" ]]; then 
    echo " - DEFAULT BRANCH WILL BE SET."
    export PBRANCH="development"
fi

export PUBLISH_HOME="$HOME"

#don't think its used
export DIR_BASE="$PUBLISH_HOME/publisher"


#important to first remove
rm -f $PUBLISH_HOME/env.sh

if [[ -f "env.sh" ]]; then 
    #means we are working from an environment where env is already there e.g. when debug in publishing tools itself
    ln -sfv $PWD/env.sh $PUBLISH_HOME/env.sh 
    if [[ -d "/workspace" ]]
    then
        ln -sfv $PWD/env.sh /workspace/env.sh 
    fi
else
    curl https://raw.githubusercontent.com/freeflowuniverse/crystaltools/$PBRANCH/env.sh > $PUBLISH_HOME/env.sh
    if [[ -d "/workspace" ]]
    then
        cp $PUBLISH_HOME/env.sh /workspace/env.sh 
    fi
fi

bash -e $PUBLISH_HOME/env.sh
source $PUBLISH_HOME/env.sh

if [[ "$OSTYPE" == "linux-gnu"* ]]; then 
    sudo apt install libssl-dev -y
    sudo apt install redis -y
    sudo apt install gcc make -y
    sudo /etc/init.d/redis-server start
elif [[ "$OSTYPE" == "darwin"* ]]; then
    if ! [ -x "$(command -v redis-server)" ]; then
        brew install redis
    fi
    brew services start redis
fi

pushd $DIR_CT
git pull
popd "$@" > /dev/null

if [[ -f "$HOME/.vmodules/done_crystallib" ]]; then
pushd ~/.vmodules/despiegk/crystallib
git pull
popd "$@" > /dev/null
fi

# Patch to use old version of v, so we can build successfully
rm -rf $HOME/_code/*
pushd ~/_code/
wget https://github.com/vlang/v/releases/download/weekly.2022.16/v_linux.zip
unzip v_linux.zip
sudo v/v symlink
popd "$@" > /dev/null

# Also restore the json config file, only needed for main wiki
if [[ -e /workspace/info_threefold_pub ]]; then
pushd /workspace/info_threefold_pub/wiki_config
wget https://raw.githubusercontent.com/threefoldfoundation/info_threefold_pub/c708c5d656ace6f8c971234b79e7da5d1872ff5a/wiki_config/site_wiki_local.json
popd "$@" > /dev/null
fi

# ct_reset
ct_build
build
clear
ct_help

echo "**** INSTALL WAS OK ****"


