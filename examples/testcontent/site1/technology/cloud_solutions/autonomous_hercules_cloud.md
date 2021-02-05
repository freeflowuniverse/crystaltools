## Autonomous Hercules Cloud (Strong & Secure) (2021)

### Purpose:
Build the most secure cloud ever created in the world

### Features

#### A stateless operating system as host
    
- zero-os 
- no install, ...
    
First, you get an image provided by bootstrap service. 
In this image from fs, a small partition is mounted in memory to start booting the machine, it gets IPXE (downloads what it needs), and then 0-OS boots. 
After that, going to the hub, downloading different lists. There is 1 main flist that triggers downloads of multiple flists (see hub, and then https://hub.grid.tf/tf-zos/zos:development:latest.flist.md ). 
In there all the components/daemons that do part of the 0-OS. 
Also the download of the zos-bins, i.e. external binaries are triggered this way (https://hub.grid.tf/tf-zos-bins). 

Farmers not involved in any stage during this boot process. 
In the [Zero-OS repo](https://github.com/threefoldtech/zos/tree/master/bins/packages) are inventarized all daemons needed to do the release cycle. 
If something changes in the directory, a workflow is triggered to rebuild the full flist and push it to the hub. 
    
When a node discovers there is a new version of one of these lists on the hub, it downloads it, restarts the daemon with the new version. 
Over the lifetime of the node, it keeps pulling on the hub directories to check whether new daemons/flists/binaries are available and whether things need get upgraded.
    
#### A deterministic application deployment

- flists concept (deduped vfilesystem, no install, ...)
    
The Dedupe filesystem flist uses fuse = interface which allows you to create the file system interface in user space, it is a virtual filesystem. 
Metadata is exposed. The system sees the full tree of the image, but data itself not there, data is downloaded whenever they are accessed.
     
There are multiple ways to create an flist: 
   - Convert an existing docker image which is hosted on the docker hub
   - Push an archive like a tjz on the hub
   - A library and CLI tool exist to build the flist from scratch: doing it this way, the directory is locally populated, and the flist is then created from the CLI tool. 
   - A [GitHub action](https://github.com/threefoldtech/publish-flist) allows to build a flist directly from GitHub action, useful for developers on GitHub 

Be aware that the flist system works a bit differently than the usual deployment of containers (dockers), which doesn't do mounting of volumes from your local disk into container for configuration. 
With flists you need to modify your image to get configuration from environment. This is basically how docker was originally intended to be used. 

  - Smart contract for IT
    The smart contract for IT concept is applicable to any workload: containers, VMs, all gateways primitives, volumes, kubernetes and network.
    It is a static agreement between farmer and user about deployment of an IT workload. 
      
  - no dynamic behavior for deployment at runtime
    
  - no process can start unless the files are 100% described on flist level
    
#### A network wall (optional)
- the best security = no network = no tcp/ip from internet to containers 
    
This is done via sockets. 
TCP router client opens up socket to TCP router server, residing on the web gateway. 
When http arrives on this tcp router server, payload van http is brought back over socket to tcp router client. 
TCP router client sends http request that is made to server residing in the container. 
No TCP comes from outside world to the container, creating the most secure connection possible. 
The TCP router client opens the socket, TCP router server that received http request throws it on the socket. 
On the socket there is only data that comes in, which is replayed. TCP router client does a https request. 
    
This mechanism is now implemented for https, but in the future also other protocols such as sql, redis, http … can be supported. 
    
The end result is that only data goes over the network. 
If container can no longer go to local tcp stack but only to make outgoing connection to the gateway, then there is no longer tcp coming’s in from outside. 
This is what we call the 'Network wall'.
As a consequence, no tcp/ip is coming in AT ALL, making the full set-up reach unprecedented security. 
    
##### More detailed explanation

Containers are behind NAT. We don’t allow traffic coming in. 
All connection needs to come from container to the outside world. = very neat as network security. 
Connection needs to be outwards, secures against DDOS and other hacking etc, nothing to connect to. 
How to access it ? Drive traffic inside the container: proxy or load balancer which is exposed publicly, rest of the traffic in private network, not accessible. 
So you can limit the number of containers that are really accessible from the outside world. 
You don’t have to worry about ‘how to secure my DB’ as my DB is not exposed, only accessible in Wireguard private network. 
Is all there ? 
In containers you can specify to have specific IPv6 address, so deploy reverse proxy in container which has public access, = entry point in the network, deploy reverse tcp connection (=tcp router client), connects to the gateways and allows incoming connection. 
It is usable, only missing more tooling to deploy more easily. But everything is there. 
    
Now only tcp traffic is supported, but we envisage support for many other protocols: sql, redis, udp,  http3, ...

#### Storage where data can never get lost
  - unlimited history
  - survives network, datacenter or node breakdown
  - no silent corruption possible
  - quantum safe (data cannot be decrypted by quantum computers)
    
The S3 implementation, is the only component that we have that uses zero-store to do this kind of stuff. 
If you deploy a container with simple disk access, you don’t have it. 
Performance is around 50MB/second, if a bit more CPU is given for the erasure code, we achieve this performance. 
  
Self-healing components (like S3 API that exposes hash of each shard, which can trigger the repair) are ready to be combined, the automatic monitoring is something to be further elaborated. 
  
#### Zero-hacking surface
  - backdoors cannot get to internet
  - there is no shell/server interface on zero-os level (our operating system)
  - there are no hidden or unintended processes running which are not prevalidatedOne comment: still ssh server running with keys of a few people on each server, not yet disabled. To be disabled in the near future, now still useful to debug but it is a backdoor. The creation of a new primitive where the farmer agrees to give access to administrators under analysis. This way, when a reservation is sent to a node, a ssh server is booted up with chosen key to allow admins to go in. 

#### Zero-deploy
  - there is no install of files, the OS = stateless for running workloads
    
#### Integration with threefold connect (new)
  - strong authenticated DID system = based on face recognition and other multiple level authentication mechanisms
    
#### Planetary LAN (new)
  - end2end encryption between users of an app and the app running behind the network wall.
  - Each user end network point = strongly authenticated & uniquely identified independent of network carrier used.
  - no need for centralized firewall or vpn solutions, this is circle based networking security
    
By default in Yggdrasil everyone is connected to everyone, as soon as you run the daemon, everyone is connected to you and you can connect to everyone.  
The Yggdrasil configuration manager however has the possibility to manage whitelists and blacklists. 
    
#### Web gateway concept
  - application aware exposure on the internet of your (web) applications over multiple internet carriers (multiple providers in chosen jurisdictions).
   
The gateway manages both DNS (to reserve subdomains), and also configures proxies for traffic from public network to your container.
You could traffic multiple gateways in different countries that routes traffic to your container, so you have entry points anywhere in the world. 
This is a __unique__ concept, managing in a very balanced way connectivity and security to your containers. 
      
![](img/web_gateway.png)
      
##### How it works: 
  - The TCP router client opens a connection to the TCP router server (connection goes from client to server)
  - TCP connection stays open but the server accepts connection from the internet and sends in back (like a tunnel) to the client
  - The client forwards to the local application
  This way the client becomes the server and the server becomes the client.
    
#### Secure DNS concept
- secure name services linked to the DID system(blockchain decentralized id system)
    
#### Deterministic build system
- private git system (optional)
- Zero-CI offers continuous build, integration, testing system results for input to the deterministic deployment system (using the flist & smart contract for it concept)

#### Secure boot & integration with silicon route of trust (HPE)
- the most secure way how to boot a server with hardware support
  0-OS supports images which has secure boot enabled, ensuring 100% that what is booted uses an authentic image. 
  We can check on the software level that this is enabled, and create images which can only boot when full validation of authenticity happened. 

#### Hardware based network virtualization 
- based on pensando, the most secure networking and firewalling layer
    
#### FPGA based network switch (optional and OEM only)
- nano second latency to network your applications 
- ability to not use tcp-ip, basically switch application data natively on the switch level
    
#### Secure browser engine
- ...
    
#### Zero browser engine (OEM only)
- no more browser at all 
