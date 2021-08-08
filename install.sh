set -e
curl https://raw.githubusercontent.com/crystaluniverse/crystaltools/development/scripts/ct_init > /tmp/init.sh
bash /tmp/init.sh
curl https://raw.githubusercontent.com/crystaluniverse/crystaltools/development/env.sh > /workspace/env.sh
source /workspace/env.sh
ct_build
clear
ct_help
