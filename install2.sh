
set -e
# set -x

# INSTALL PUBLISH TOOLS

rm -f /usr/local/bin/publishtools

if [[ "$OSTYPE" == "linux-gnu"* ]]; then 
    curl -L https://github.com/crystaluniverse/publishtools/releases/download/first/publishtools_linux > /usr/local/bin/publishtools  
    chmod +x /usr/local/bin/publishtools
elif [[ "$OSTYPE" == "darwin"* ]]; then

    if ! [ -x "$(command -v mc)" ]; then
        brew install mc
    fi

    if ! [ -x "$(command -v redis-server)" ]; then
        brew install redis
    fi
    
    if [[ `uname -m` == 'arm64' ]]; then
        rm -f /usr/local/bin/publishtools
        curl -L https://github.com/crystaluniverse/publishtools/releases/download/first/publishtools_osx_arm --output /opt/homebrew/bin/publishtools
        chmod 770 /opt/homebrew/bin/publishtools
    else
        rm -f /opt/homebrew/bin/publishtools
        curl -L https://github.com/crystaluniverse/publishtools/releases/download/first/publishtools_osx --output /usr/local/bin/publishtools
        chmod 770 /usr/local/bin/publishtools
    fi
fi



echo " - INSTALL DONE"

