# Closed Work
This is a list of things that were probably dead ends and didn't get incorporated into the plan. It's stuf that was written down during the development process but that we don't think we need to configure. It's kept here in case we're wrong and it is needed.

## Edit (create) /etc/network/interfaces

Edit the following file:

```
vi /etc/network/interfaces
```

And configure it as follows:
```
# The loopback network interface
auto lo
iface lo inet loopback

# NAT interface
auto eth0
iface eth0 inet dhcp

# Host-only interface
auto eth1
iface eth1 inet static
        address         192.168.56.20
        netmask         255.255.255.0
        network         192.168.56.0
        broadcast       192.168.56.255
```

### A perhaps sort-of-initial condition

Basically initial but after bridge setup: /etc/sysconfig/network-scripts/ifcfg-eth0

DEVICE=eth0
HWADDR=<DONT CHANGE>
TYPE=Ethernet
UUID=<LONG STRING>
ONBOOT=yes
NM_CONTROLLED=no
BOOTPROTO=dhcp
