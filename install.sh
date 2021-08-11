set -e
curl https://raw.githubusercontent.com/crystaluniverse/crystaltools/development/scripts/ct_init > /tmp/init.sh
bash /tmp/init.sh
sudo /etc/init.d/redis-server start
curl https://raw.githubusercontent.com/crystaluniverse/crystaltools/development/env.sh > /workspace/env.sh
source /workspace/env.sh
ct_build
publtools_build
clear
ct_help
