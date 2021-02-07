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
#re-install
publishtools install -reset
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

### To Run e.g. for www_threefold_farming

```
cd ~/code/github/threefoldfoundation/www_threefold_farming
sh run.sh
```

this will start a local dev server at http://localhost:8080

to now see your website, copy `http://localhost:8080` in your browser

### List of repo's which are cloned

it could be you don't have access to all of them

```bash
ct git pull -u git@github.com:threefoldfoundation/www_threefold_cloud.git
ct git pull -u git@github.com:threefoldfoundation/www_threefold_farming.git
ct git pull -u git@github.com:threefoldfoundation/www_threefold_twin.git
ct git pull -u git@github.com:threefoldfoundation/www_tfnow.git
ct git pull -u git@github.com:threefoldfoundation/www_tfgrid.git
ct git pull -u git@github.com:threefoldfoundation/info_foundation.git
ct git pull -u git@github.com:threefoldtech/info_tftech.git
ct git pull -u git@github.com:threefoldfoundation/data_threefold.git
```

## work with your ssh keys

- important to start in publishingtools dir otherwise it will not start the blog
- best to have your sshkey loaded see
  - https://docs.github.com/en/github/authenticating-to-github/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent
  - https://docs.github.com/en/github/authenticating-to-github/adding-a-new-ssh-key-to-your-github-account
- note: make sure you are in your terminal and have your prompt, don't type the $ sign at front of the commands, this is part of your prompt

![](img/sshgen.png)

to manually add your ssh to the agent

```
ssh-add ~/.ssh/id_rsa
```

to see if it succeeded

```
ssh-add -l
2048 SHA256:olDf62/m6YOwIxYWUzrB6/XE4J4CalsxnaMpPuIEQpk /Users/despiegk/.ssh/id_rsa (RSA)
```

## troubeshooting

### OSX

- once brew installed do

```
brew update
brew upgrade
```

and try again, see if brew worked well
