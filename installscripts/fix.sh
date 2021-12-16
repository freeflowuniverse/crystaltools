
cd ~

export PUBLISH_HOME="$HOME"

export DIR_BASE="$PUBLISH_HOME/publisher"


if [[ "$OSTYPE" == "darwin"* ]]; then
    set +ex
    export iam=`whoami`
    sudo chown -R ${iam}:staff ~/code
fi