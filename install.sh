set -ex
sudo /etc/init.d/redis-server start
export PBRANCH="development_scriptsnew"
curl https://raw.githubusercontent.com/crystaluniverse/crystaltools/$PBRANCH/env.sh > /workspace/env.sh
bash -ex /workspace/env.sh
source /workspace/env.sh
ct_build
publtools_build
clear
ct_help
