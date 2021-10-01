## step 1: create ssh key

in terminal do:

```bash
#remplace sam to your name
ssh-keygen -t ed25519 -f ~/.ssh/sam
```

- give meaningful name
- put in right location !!! ~/.ssh/sam (dont forget ~/.ssh)

> MAKE SURE TO USE A PASSPHRASE

![](img/ssh1_.jpg)

see instructions above

to add your ssh to the agent

```
ssh-add ~/.ssh/sam
```

to see if it succeeded

```
ssh-add -l
2048 SHA256:olDf62/m6YOwIxYWUzrB6/XE4J4CalsxnaMpPuIEQpk /Users/sam/.ssh/sam (RSA)
```

> important: make sure there is passphrase on your ssh key <br>
> make sure sshkey loaded in github account

## step 2: add to github 

![](img/ssh2_.jpg)

this needs to be added in https://github.com/settings/keys

see screen what needs to be done, basically just upload your previously generated key

to see your key do

```bash
#make sure to use the public key
cat ~/.ssh/sam.pub
```

select the 1line represeing your key and paste in github

## more info

- more info see
  - https://docs.github.com/en/github/authenticating-to-github/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent
  - https://docs.github.com/en/github/authenticating-to-github/adding-a-new-ssh-key-to-your-github-account
- note: make sure you are in your terminal and have your prompt, don't type the $ sign at front of the commands, this is part of your prompt