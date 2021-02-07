# tools to run ThreeFold web env

starting point to run all wiki's and websites on your local machine

- wiki's
- websites

## to install

copy the folling in your terminal

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/crystaluniverse/publishtools/master/scripts/install.sh)"
```

## Requirements

Make sure your ssh-key is loaded and you have it in your github account

## quick instructions

```bash
#install the publishtools
publishtools install
#re-install (if something is wrong, do an install -reset)
publishtools install -reset
#re-install and pull newest website code in
publishtools install -reset -pull
#list the know sites
publishtools list
#start development mode of website cloud (specify part of name of website is good enough)
#is using gridsome
publishtools develop cloud
#run the webserver for the wiki's
publishtools develop
#build all websites, will take long time
publishtools build
#specify to build for 1 specific websote
publishtools build cloud
```

> remark: this will checkout all relevant repo's on ~/codewww <BR>

## work with your ssh keys

see [instructions](docs/sshkey.md)

## advanced usage

```bash
#will go over all repo's and update the repo's after cleaning up e.g. the wiki's
#a lot of automation happens here, be careful
publishtools install -clean
```
