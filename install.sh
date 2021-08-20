set -ex
sudo /etc/init.d/redis-server start
if [[ -z "${PBRANCH}" ]]; then 
echo " - DEFAULT BRANCH WILL BE SET."
export PBRANCH="development"
fi
curl https://raw.githubusercontent.com/crystaluniverse/crystaltools/$PBRANCH/env.sh > /workspace/env.sh
bash -ex /workspace/env.sh
source /workspace/env.sh
ct_build
publtools_build
clear
ct_help
