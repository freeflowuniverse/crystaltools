
set -e
set +x

# INSTALL CRYSTAL TOOLS

rm -f /usr/local/bin/publishtools

if [[ "$OSTYPE" == "linux-gnu"* ]]; then 
    curl -L https://github.com/crystaluniverse/publishtools/releases/download/first/publishtools_linux > /usr/local/bin/publishtools
elif [[ "$OSTYPE" == "darwin"* ]]; then
    curl -L https://github.com/crystaluniverse/publishtools/releases/download/first/publishtools_osx > /usr/local/bin/publishtools
fi

chmod 770 /usr/local/bin/publishtools

echo " - INSTALL DONE"


