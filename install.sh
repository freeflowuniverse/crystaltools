set -e
sudo /etc/init.d/redis-server start
curl https://raw.githubusercontent.com/crystaluniverse/crystaltools/development/env.sh > /workspace/env.sh
bash -x /workspace/env.sh
source /workspace/env.sh
ct_build
publtools_build
clear
ct_help
