# TFGrid release 2.1

![](./img/roadmap.png)

- [details on github of the project](https://github.com/orgs/threefoldtech/projects/93)

## Highlights

- Resource pool reservation
    - Reservation is now for capacity only
    - This is a super important feature to allow to reserve a pool of capacity, pricing is adjusted in relation to duration of the reservation.
    - Deployment of a workload happens as part of a reservation
    - As long as there is available capacity in the reservation a workload can be stopped, started, ...
    - This allows flexibility around doing live cycle management of apps
- Support for farming on IPv4 networks (using an IPv6 overlay networking technology, probably [yggdrasil](https://yggdrasil-network.github.io/))
- [S3 storage improvements](https://github.com/threefoldtech/home/issues/720)
    - Monitoring integration
    - Users can make the S3 solution self healing if required (experts only)
- Building of applications directly on the TFGrid
    - Mechanism with example to show how continuous integration can be done on the TFGrid without having to use docker on your own computer
    - The result is a flist, which is the low level description of the IT workload which can be started as a container inside a resource pool reservation (see above)
- Lots of small fixes
    - Bug fixes, maintenance, ...
