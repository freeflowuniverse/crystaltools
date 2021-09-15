# Install

generic way how to get the publishtools in your computer or gitpod using an install script

```bash
#if you need specific branch for your installer & publishtools
export PBRANCH=development_scriptsnew
curl https://raw.githubusercontent.com/freeflowuniverse/crystaltools/$PBRANCH/install.sh > /tmp/install.sh
bash /tmp/install.sh
#use your environment
source /workspace/env.sh
#next will check publishtools are installed and usable
check
# example for running development server wiki, go to wiki
cd wiki_config
publishtools develop
publishtools flatten 
# example to run install/run website based on gridsome
# cd a_website_dir
web_install
website_install
website_run
```

## Platform Specific

- [GITPOD for a website](install_gitpod_website)
- [GITPOD for a wiki](install_gitpod_wiki)
- [OSX](install_osx)