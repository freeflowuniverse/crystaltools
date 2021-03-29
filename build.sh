set -ex
cd publishtools

#cp publishermod/index_root.html .
#cp publishermod/errors.html .

v -gc boehm -prod publishtools.v

#v  publishtools.v

rm -f index_root.html
rm -f errors.html

cp publishtools /usr/local/bin/publishtools 
   
if [[ "$OSTYPE" == "darwin"* ]]; then
    cp publishtools ~/Downloads/publishtools_osx
fi


rm publishtools