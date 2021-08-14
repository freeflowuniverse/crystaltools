if [[ -d "/workspace" ]]
then
    export DIR_BUILD="/workspace/build"
    if [[ -d "/workspace/crystaltools" ]]; then
        export DIR_CT="/workspace/crystaltools"
    else
        export DIR_CT="/workspace/code/crystaltools"
    fi
    export DIR_BASE="/workspace/publisher"    
    export HOME="/workspace"
else
    export DIR_BUILD="/tmp"
    export DIR_BASE="$HOME/.publisher"
    export DIR_CT="$HOME/code/crystaltools"
fi


export DIR_CODE="$HOME/code"
export DIR_CODEWIKI="$HOME/codewiki"
export DIR_CODE_INT="$HOME/_code"
export DIR_BIN="/usr/local/bin"

export PATH=$DIR_CT/scripts:$PATH

