set -ex
sudo /etc/init.d/redis-server start
curl https://raw.githubusercontent.com/crystaluniverse/crystaltools/development_scriptsnew/env.sh > /workspace/env.sh
bash -ex /workspace/env.sh
source /workspace/env.sh
ct_build
publtools_build
clear
ct_help
