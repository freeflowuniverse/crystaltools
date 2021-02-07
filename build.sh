set -ex
cd publishtools
v -prod  publishtools.v

cp publishtools /usr/local/bin/publishtools
   
if [[ "$OSTYPE" == "darwin"* ]]; then
    cp publishtools ~/Downloads/publishtools_osx
fi
