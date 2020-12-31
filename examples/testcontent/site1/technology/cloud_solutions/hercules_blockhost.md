# Hercules Blockhost

![](./img/bh1.png)

## What is Hercules Blockhost

Blockchain protocols (of which there are many, to name a few, Ethereum, EOS.IO, Ripple, Steem etc) have to make a choice on how to actually run their blockchain nodes to operate their protocol.  There is a spectrum of options to choose from but the two most common ones are the following ones:

*   Create a software package (source code or binaries) that can be downloaded and run on virtual machines or  containers on public clouds.  Examples of public cloud are Amazon Web Services, Google Cloud Platform  and Microsoft Azure.
*   Create the same software package and rely on people to run this software on their laptop or home / office server or on specified mining equipment.

Both options come with a number of disadvantages.  Using the public cloud presents ease of deployment and hassle free operations but comes with a price:  the actual purpose of blockchain protocols is lost as clouds do not build decentralized deployments.  For example [ethereum runs for almost 60% on public cloud services](https://thenextweb.com/hardfork/2019/09/23/ethereum-nodes-cloud-services-amazon-web-services-blockchain-hosted-decentralization/).  

On the other hand there is a  desire to have individuals select and operate their own (specific) hardware setups. But there is a huge barrier for doing so (knowledge, capital requirements etc.) which makes the blockchain protocols vulnerable to pooling of capacities by large organizations [finetuning their capabilities to run these protocols](https://www.newsbtc.com/2018/04/18/consolidation-in-cryptocurrency-mining-industry-to-pressure-the-price-of-bitcoin/).  This is also referred to as “cloud mining”.

Both options lead to sub-optimal operations of blockchain protocols and do not deliver on the promise of being decentralized, peer to peer and  by people for people.

The Hercules blockhost product allows blockchain protocols to take advantage of the decentralised and distributed nature of the TF Grid while still enjoying hassle free creation and operation of blockchain nodes. 

Also, if people are interested in operating their own blockchain nodes they can quite easily invest in some hardware, install the ThreeFold Zero-OS operating system to create a 3node creating new capacity to the TF grid.  This capacity can then be utilized to operate blockchain nodes. 

![](./img/bh2.png)


## Features
* Uses our other components
    - [ZOS Containers](zos_container.md)
    - [VDC Network](vdc_network.md)
    - [VDC Storage](vdc_storage.md)
    - [Hercules Blockhost](hercules_blockhost.md)
    - [Hercules Coder](hercules_coder.md)
*   Flexible
    * Choose to use existing nodes and deploy blockchain protocol nodes
    * Choose to deploy TF 3Nodes, farm TF Tokens and deploy blockchain protocol nodes.

## Main Benefits

!!!include:usp_reliable_secure
!!!include:usp_sustainable
!!!include:usp_manageable
!!!include:usp_scalable

## Architecture

The ThreeFold grid provides raw compute and storage utility by people for people, ideal to create independent blockchain node operations by people for the blockchain project network.


![](./img/bh3.png)



>TODO: need to describe the real difference here which is thanks to the smart contract layer