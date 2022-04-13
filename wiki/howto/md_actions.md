
# Markdown Instructions

there is a very cool feature to give instructions to publishing tools to do stuff

imagine

```
# This is a wiki page
!!wiki name:manual url:'https://github.com/threefoldfoundation/info_manual3/tree/development/wiki'

can have any markdown content

!!wiki name:test path:'../wiki'
!!publish path:'/tmp/mdbooks/wiki'
```

the !!... are the instructions to do something, think above is self explanatory

this wiki page is somewhere e.g. in this case on

- ```https://github.com/freeflowuniverse/crystaltools/tree/development_a5/wiki_config_simple```

To make sure all wiki pages as in above repo dir are executed do the following

```bash
export PUBSITE='https://github.com/freeflowuniverse/crystaltools/tree/development_a5/wiki_config_simple'
publishtools run
```

thats it, its very simple, it will execute all actions as specified in the markdown files.

