# Setting up VirtualBox

## Downloading and configuring VirtualBox
@todo: start this section

## Setting up the VirtualBox Machine
@todo: add a lot more content

Add steps for how to configure the VM. Add info about 32-bit requirement for James' laptop.

Make sure your networks are setup so Adapter 1 is NAT and Adapter 2 is Host-Only. These will correspond to eth0 and eth1, respectively.

### Port Forwarding
In order to allow SSH from your computer to the virtual machine client you need to setup port forwarding. 

Go to VirtualBox settings for your client, and go to the "Network" settings. Select Adapter 1 (which should have "Attached to" = "NAT") and click the "Port Forwarding" button. Your configuration should be:

* Name: ssh
* Protocol: TCP
* Host IP: leave blank
* Host Port: 3022
* Guest IP: leave blank
* Guest Port: 22