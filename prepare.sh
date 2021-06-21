set -ex
echo 1 > /tmp/log.txt
sudo apt install redis-server -y
bash install.sh
bash build.sh
echo 2 >> /tmp/log.txt
sudo /etc/init.d/redis-server start
echo 3 >> /tmp/log.txt
set +ex
publishtools flatten
echo 4 >> /tmp/log.txt
publishtools flatten
echo 5 >> /tmp/log.txt



