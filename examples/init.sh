#/bin/bash

rm {builder,docker,publisher,texttools,gittools,process,myconfig,tmux,vredis2,hostsfile}
ln -s ../lib/{builder,docker,publisher,texttools,gittools,process,tmux,vredis2,hostsfile} .
ln -s ../publishtools/myconfig .