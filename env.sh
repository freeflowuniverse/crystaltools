#!/usr/bin/env bash
# set -x

if [[ -z "${PBRANCH}" ]]; then 
export PBRANCH="development"
fi

function crystal_tools_get {
    mkdir -p $DIR_CODE/github/freeflowuniverse
    if [[ -d "$DIR_CODE/github/freeflowuniverse/crystaltools" ]]
    then
        pushd $DIR_CODE/$2 2>&1 >> /dev/null
        # git pull
        popd 2>&1 >> /dev/null
    else
        pushd $DIR_CODE/github/freeflowuniverse 2>&1 >> /dev/null
        git clone https://github.com/freeflowuniverse/crystaltools.git
        popd 2>&1 >> /dev/null
    fi
    if [[ -z "${PBRANCH}" ]]; then 
    echo ' - no branch set'
    else
        if [[ "$PBRANCH" == "development" ]]; then 
            echo
        else
            echo ' - switch to branch ${PBRANCH} for publishtools'
            pushd $DIR_CODE/github/freeflowuniverse/crystaltools 2>&1 >> /dev/null
            git checkout $PBRANCH
            git pull
            popd 2>&1 >> /dev/null
        fi
    fi
}


export PUBLISH_HOME="$HOME"

export DIR_BASE="$PUBLISH_HOME/publisher"
export DIR_BUILD="/tmp"
export DIR_CODE="$PUBLISH_HOME/code"
export DIR_CODEWIKI="$PUBLISH_HOME/codewiki"
export DIR_CODE_INT="$PUBLISH_HOME/_code"
export DIR_BIN="/usr/local/bin"

mkdir -p $DIR_CODE
mkdir -p $DIR_CODE_INT
mkdir -p $DIR_BUILD

git config --global pull.rebase false


if [[ -d "/workspace/crystaltools" ]]
then
    #this means we are booting in gitpod from crystal tools itself
    export DIR_CT="/workspace/crystaltools"
else    
    export DIR_CT="$DIR_CODE/github/freeflowuniverse/crystaltools"
    #get the crystal tools
    crystal_tools_get
fi

export PATH=$DIR_CT/scripts:$PATH

