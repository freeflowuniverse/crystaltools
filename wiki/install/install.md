# Install

generic way how to get the publishtools in your computer or gitpod using an install script

```bash
curl https://raw.githubusercontent.com/freeflowuniverse/crystaltools/development/installscripts/install.sh > /tmp/install.sh
bash /tmp/install.sh
#use your environment
source ~/env.sh
```

if it fails Theory
```bash
ct_reset
```

if it ok you should server
```bash
*** INSTALL WAS OK ***
```


## Get your first wiki

```bash
export PUBSITE=https://github.com/threefoldfoundation/info_threefold_pub/tree/development/wiki_config
publishtools develop
```

- what happens here is you specify the configuration location of your wiki

## Platform Specific

<!-- - [GITPOD for a website](install_gitpod_website)
- [GITPOD for a wiki](install_gitpod_wiki) -->
- [OSX](install_osx)

## Remarks

- info comes from https://github.com/freeflowuniverse/crystaltools 