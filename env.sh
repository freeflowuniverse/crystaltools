if [[ -d "/workspace" ]]
then
    if [[ -z "${DIR_CODE}" ]]; then export DIR_CODE="/workspace/code"; fi
    if [[ -z "${DIR_CODE_INT}" ]]; then export DIR_CODE_INT="/workspace/_code"; fi
    if [[ -z "${DIR_BIN}" ]]; then export DIR_BIN="/usr/local/bin"; fi
    if [[ -z "${DIR_BUILD}" ]]; then export DIR_BUILD="/workspace/build"; fi
    if [[ -z "${DIR_CT}" ]]; then export DIR_CT="/workspace/crystaltools"; fi
else
    if [[ -z "${DIR_CODE}" ]]; then export DIR_CODE="$HOME/code"; fi
    if [[ -z "${DIR_CODE_INT}" ]]; then export DIR_CODE_INT="$HOME/_code"; fi
    if [[ -z "${DIR_BIN}" ]]; then export DIR_BIN="/usr/local/bin"; fi
    if [[ -z "${DIR_BUILD}" ]]; then export DIR_BUILD="/tmp"; fi
    if [[ -z "${DIR_CT}" ]]; then export DIR_CT="$HOME/code/crystaltools"; fi
fi

export PATH=$DIR_CT/scripts:$PATH

