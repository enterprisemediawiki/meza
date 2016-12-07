#!/bin/sh

# Get host-only IP address, write to config.local.sh for install steps
meza prompt server_ip_address "Enter your desired IP address (follow meza VirtualBox Networking steps)" "192.168.56.56"
