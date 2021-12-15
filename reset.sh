
cd ~

export PUBLISH_HOME="$HOME"
export DIR_BASE="$PUBLISH_HOME/publisher"

mkdir -p $DIR_BASE

#important to first remove
sudo rm -f $PUBLISH_HOME/env.sh
sudo rm -rf $PUBLISH_HOME/.vmodules
sudo rm -rf $PUBLISH_HOME/v
sudo rm -rf $PUBLISH_HOME/codewiki
sudo rm -rf $PUBLISH_HOME/codewiki
sudo rm /usr/local/bin/publishtools
suro rm -rf $PUBLISH_HOME/code/github/freeflowuniverse/crystaltools




