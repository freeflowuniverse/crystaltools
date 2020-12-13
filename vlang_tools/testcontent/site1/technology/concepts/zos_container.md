# ZOS Container

ThreeFold native container technology as implemented in Zero-OS.

Uses capacity layer from Zero-OS and your virtual system administrator called 3bot does the orchestration.

The ZOS Container is not running in the Kubernetes part of the VDC, its running directly in the Zero-OS (ZOS) and can be integrated with the eVDC over the network.

![](./img/container_native.png)

## Features

*   import from docker (market std for containers)
*   integration with [zero-os overlay networking layer](vdc_network) (efficient, secure encrypted network between the containers)
*   can be easily deployed at the edge
*   integrated with scalable & capable monitoring system (prometheus based)
*   can be integrated with our advanced billing/charge back mechanism
*   Single-tenant!

## Main Benefits

### Reliable

*   [Hercules Protect](zos_protect): no hacking surface to the Zero-Nodes, integrate silicon route of trust
*   [Hercules P2P Network](vdc_network): encrypted overlay network connects the containers
*   [ZOS Filesystem ](zos_filesystem) (v2.x): dedupe, zero-install, hacker-proof for use in containers on kubernetes
*   [Hercules Web Gateway](web_gateway): intelligent connection between web (internet) and container services
*   [planetary network](planetary_network): a true global single backplane network connecting us all



