rm -f /usr/local/bin/publishtools

set -ex
cd publishtools



#cp publishermod/index_root.html .
#cp publishermod/errors.html .

rm -f /usr/local/bin/publishtools

# v -gc boehm -prod publishtools.v
if [[ "$OSTYPE" == "darwin"* ]]; then
    # brew install libgc
    v -d static_boehm  -gc boehm -prod publishtools.v
else
    v -d static_boehm  -gc boehm -cflags -static -prod publishtools.v
fi


# v -d static_boehm  -gc boehm publishtools.v

#v  publishtools.v

rm -f index_root.html
rm -f errors.html

cp publishtools /usr/local/bin/publishtools 
   
if [[ "$OSTYPE" == "darwin"* ]]; then
    cp publishtools ~/Downloads/publishtools_osx
fi


rm publishtools

