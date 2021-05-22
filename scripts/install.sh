
set -e
set +x

# INSTALL PUBLISH TOOLS

rm -f /usr/local/bin/publishtools

if [[ "$OSTYPE" == "linux-gnu"* ]]; then 
    curl -L https://github.com/crystaluniverse/publishtools/releases/download/first/publishtools_linux > /usr/local/bin/publishtools  
elif [[ "$OSTYPE" == "darwin"* ]]; then
    if [[ `uname -m` == 'arm64' ]]; then
        curl -L https://github.com/crystaluniverse/publishtools/releases/download/first/publishtools_osx_arm > /usr/local/bin/publishtools
    else
        curl -L https://github.com/crystaluniverse/publishtools/releases/download/first/publishtools_osx > /usr/local/bin/publishtools
    fi
fi

chmod 770 /usr/local/bin/publishtools
chmod +x /usr/local/bin/publishtools

echo " - INSTALL DONE"


