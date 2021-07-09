set -ex
cd /workspace/publishtools/publishtools


#cp publisher_core/index_root.html .
#cp publisher_core/errors.html .

sudo rm -f /usr/local/bin/publishtools


# v -d static_boehm  -gc boehm -cflags -static publishtools.v
# v -d static_boehm  -gc boehm publishtools.v

v -gc boehm publishtools.v

#v  publishtools.v

rm -f index_root.html
rm -f errors.html

sudo cp publishtools /usr/local/bin/publishtools 
   

rm publishtools

