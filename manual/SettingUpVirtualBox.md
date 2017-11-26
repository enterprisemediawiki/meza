# Setting up meza on VirtualBox

## tl;dr

1. Setup a machine in Virtual Box with a NAT as network adapter 1 and a host-only as adapter 2.
2. Install CentOS minimum install on a virtual machine. This won't have networking enabled or SSH installed.
3. Boot your VM, and type these in (without SSH you can't copy-paste)
```bash
sudo ifup enp0s3
sudo yum install -y git
sudo git clone https://github.com/enterprisemediawiki/meza /opt/meza
sudo bash /opt/meza/src/scripts/getmeza.sh
sudo meza setup dev-networking
```
4. Now SSH into your machine and run `sudo meza deploy monolith`.

This will setup a demo wiki with the user `Admin` with password `adminpass`. Update this password or remove this user for production environments. To add wikis see [these docs](manual/AddingWikis.md).

## Detailed steps

Below are detailed steps to get meza running on your machine.

### Downloads and Installs
1. Download and install [VirtualBox](https://www.virtualbox.org/)
1. Install [Git](https://git-scm.com/)
  1. On Windows only, you also need to use this for the Git Bash terminal (once installed right click on any window and select "git bash here")
1. On Windows only, install [PuTTY](http://www.chiark.greenend.org.uk/~sgtatham/putty/download.html) (You probably want the "Windows MSI installer")
1. Download [CentOS 7 minimal install](http://isoredirect.centos.org/centos/7/isos/x86_64/) into your home directory (e.g. `echo $HOME`)
1. Clone the meza repository in your terminal: `cd $HOME && git clone https://github.com/enterprisemediawiki/meza`

### Create a new VM
5. Create a new Virtual Machine (VM) in VirtualBox:
  1. Change to meza's scripts directory: `cd meza/src/scripts`
  2. Run the Create VM script: `./create-vm.sh` and follow the prompts. You need at least 10GB of disk space for a basic install.
6. Install CentOS onto your new VM: Start the VM and follow the prompts.
  1. If you intend for this VM to have a large amount of wiki data (requiring >50 GB for the database, uploaded files, and any backup files from another server), you'll need to configure partioning at the "Installation Summary" screen, via "Installation Destination". Under "Other Storage Options", select "I will configure partitioning." Upon clicking "Done" you will be prompted to configure partition allocation. You can "Click here to create them automatically" and then make adjustments. For an example with 100 GiB total, if you allocate 1 GiB to `/home` you can then allocate 100 GiB to `/`. It will automatically adjust to allocate as much as possible from the remaining amount while leaving enough for `/boot` and `swap`.

### Configure the VM
7. Once installed, you'll need to get networking started. Unfortunately in these first few steps you can't copy/paste, so you'll have to type these manually.

```bash
sudo ifup enp0s3
sudo yum install -y git
sudo git clone https://github.com/enterprisemediawiki/meza /opt/meza
sudo bash /opt/meza/src/scripts/getmeza.sh
sudo meza setup dev-networking
```

These steps do the following:
1. Start networking
2. Get the meza setup script
3. Setup the `meza` command
4. Adds SSH, starts host-only network adapter

### Confirm SSH works
1. Assuming your VM's IP address is 192.168.56.56
2. For Mac/Linux/Unix, open your terminal and run `ssh root@192.168.56.56` or `ssh yourusername@192.168.56.56`
3. For Windows, open PuTTY and type 192.168.56.56 into the "Host Name (or IP address)" field and hit "Open" then login with your credentials

### Shutdown, snapshot
8. Shutdown your VM: `sudo shutdown -h now`
9. Take a snapshot and call it something like "baseline configuration". Click the "snapshots" icon in the top-right of VirtualBox and then click the camera icon. You'll be able to jump back to this point at any time.

### Install wiki server
1. Start your VM
2. SSH into the VM
3. Run `sudo meza deploy monolith` to install your wiki server.

This will setup a demo wiki with the user `Admin` with password `adminpass`. Update this password or remove this user for production environments. To add wikis see [these docs](./AddingWikis.md).

## Red Hat

Want to setup a Red Hat VM instead of CentOS? See [instructions](SetupRedHat.md).
