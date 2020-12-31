![](./img/3Node_nice.png)

# 3Node & Zero-OS 

Computers (servers) are the low-level provider for the IT capacity of the Cloud, we call them TFGrid Nodes or in short a ```3Node```.

### Zero-OS

ZeroOS (ZOS) is the operating system which allows the 3Nodes to be used to provide IT capacity required by the solutions running on the TFGrid.

### 

3Nodes are servers which run the [Zero-OS](https://github.com/Threefoldtech/zos) software. 

They provide storage, compute & networking capacities. Together, 3Nodes make up the capacity layers for the TF Grid. 

Today we have about thousands of 3Nodes across the grid see our https://explorer.grid.tf

![](./img/tf_grid.png)

### Zero install

The Zero-OS is delivered to the 3Nodes over the internet network (network boot) and does not need to be installed.

### 3Node Install

1. Acquire a computer (server).
2. Configure a farm on the TFGrid explorer.
3. Download the bootloader and put on a USB stick or configure a network boot device.
4. Power on the computer and connect to the internet.
5. Boot! The computer will automatically download the components of the operating system (Zero-OS).

The actual bootloader is very small. It brings up the network interface of your computer and queries TFGeid for the remainder of the boot files needed. 

The operating system is not installed on any local storage medium (hard disk, ssd). Zero-OS is stateless.

The mechanism to allow this to work in a safe and efficient manner is a ThreeFold innovation called our container virtual filesystem. This is explained in more detail [here](architecture_flist.md)

### Properties of Zero-OS

Zero-OS is a very lightweight and efficient operating system. It supports a small number of _primitives_; the low-level functions it could perform natively in the operating system. 

There is no shell, local nor remote. 

It does not allow for inbound network connections to happen. 

If you are technical, you can learn more on our github repsitory: [Zero-OS](https://github.com/Threefoldtech/zos/tree/master/docs).
