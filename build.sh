set -ex
cd publishtools
# v -prod  publishtools.v
v  publishtools.v

cp publishtools /usr/local/bin/publishtools
   
if [[ "$OSTYPE" == "darwin"* ]]; then
    cp publishtools ~/Downloads/publishtools_osx
fi
