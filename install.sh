set -ex
if [[ -z "${PBRANCH}" ]]; then 
    echo " - DEFAULT BRANCH WILL BE SET."
    export PBRANCH="development"
fi

export PUBLISH_HOME="$HOME"

export DIR_BASE="$PUBLISH_HOME/publisher"

mkdir -p $DIR_BASE


if [[ -f "env.sh" ]]; then 
    #means we are working from an environment where env is already there e.g. when debug in publishing tools itself
    rm -f $PUBLISH_HOME/env.sh
    ln -sfv $PWD/env.sh $PUBLISH_HOME/env.sh 
    if [[ -d "/workspace" ]]
    then
        ln -sfv $PWD/env.sh /workspace/env.sh 
    fi
else
    rm -f  $PUBLISH_HOME/env.sh
    curl https://raw.githubusercontent.com/freeflowuniverse/crystaltools/$PBRANCH/env.sh > $PUBLISH_HOME/env.sh
    if [[ -d "/workspace" ]]
    then
        cp $PUBLISH_HOME/env.sh /workspace/env.sh 
    fi
fi

bash -e $PUBLISH_HOME/env.sh
source $PUBLISH_HOME/env.sh

if [[ "$OSTYPE" == "linux-gnu"* ]]; then 
    sudo /etc/init.d/redis-server start
elif [[ "$OSTYPE" == "darwin"* ]]; then
    if ! [ -x "$(command -v redis-server)" ]; then
        brew install redis
    fi
    brew services start redis
fi


# ct_build
build
clear
ct_help

