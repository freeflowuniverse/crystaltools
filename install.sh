set -ex
if [[ -z "${PBRANCH}" ]]; then 
echo " - DEFAULT BRANCH WILL BE SET."
export PBRANCH="development"
fi

#means we are in gitpod
if [[ -d "/workspace" ]]
then
    export PUBLISH_HOME="/workspace"
else
    export PUBLISH_HOME="$HOME"
fi
export DIR_BASE="$PUBLISH_HOME/publisher"

mkdir -p $DIR_BASE

if [[ -f "env.sh" ]]; then 
rm -f $DIR_BASE/env.sh
ln -sfv $PWD/env.sh $DIR_BASE/env.sh 
else
curl https://raw.githubusercontent.com/crystaluniverse/crystaltools/$PBRANCH/env.sh > $DIR_BASE/env.sh
fi

bash -ex $DIR_BASE/env.sh
source $DIR_BASE/env.sh

ct_build
publtools_build
clear
ct_help
