
set -e
set +x

# INSTALL CRYSTAL TOOLS

rm -f /usr/local/bin/publishtools

if [[ "$OSTYPE" == "linux-gnu"* ]]; then 
    # sudo /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/crystaluniverse/crystaltools/master/tools/install.sh)"
    echo "no release for linux yet"
    exit 1
elif [[ "$OSTYPE" == "darwin"* ]]; then
    # /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/crystaluniverse/crystaltools/master/tools/install.sh)"
    curl -L https://github.com/crystaluniverse/publishtools/releases/download/first/publishtools_osx > /usr/local/bin/publishtools
fi

chmod 770 /usr/local/bin/publishtools

echo " - INSTALL DONE"


