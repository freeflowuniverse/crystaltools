# Tools to run ThreeFold web environment

- [PLANNING/ISSUES SEE HERE](https://circles.threefold.me/project/despiegk-product_publisher/issues)

## Getting Started, Deploy Publishingtools

```bash
curl https://raw.githubusercontent.com/freeflowuniverse/crystaltools/development/install.sh | bash
```


to get a specific wiki environment

```bash
export PUBSITE=https://github.com/threefoldfoundation/info_threefold/tree/development/wiki_config
publishtools develop
```
<!-- 
## Develop/Play in gitpod

- install gitpod extension to your browser
- click on the gitpod logo, it will give you this development environment

> to test do: ```./wiki_develop``` in the terminal, you will see the wiki in your browser

## to install

https://info.threefold.io/info/publishtools#/publishtools__install

short

```bash
curl https://raw.githubusercontent.com/freeflowuniverse/crystaltools/development/scripts/ct_init > /tmp/ct_init
source /tmp/ct_init
ct_help
```

will print which commands are available.

oneliner:

```bash
curl https://raw.githubusercontent.com/freeflowuniverse/crystaltools/development/scripts/ct_init > /tmp/ct_init && source /tmp/ct_init && ct_help
```
 -->


### for more info, see crystaltools documentation

https://info.threefold.io/info/crystaltools



### how to work with branches

- call install.sh on other branch (the script above in branch)
- adjust install.sh to point to other branch for 
- adjust env.sh in git_get to pull the right branch

## when sudo install

```bash
#or if sudo needed
curl https://raw.githubusercontent.com/freeflowuniverse/crystaltools/development/install.sh > /tmp/install.sh
sudo bash /tmp/install.sh
```



