Using Vagrant
=============

## Prerequisites

1. [Git](https://git-scm.com/)
2. [Virtual Box](https://www.virtualbox.org/wiki/VirtualBox)
3. [Vagrant](https://www.vagrantup.com/)

## Basic install

Launch your terminal (or, on Windows, open Git Bash) and run the following to clone the meza repository and change directory into it:

```
git clone https://github.com/enterprisemediawiki/meza.git
cd meza
```

Next, setup a virtual machine and do the initial setup of meza by running:

```
vagrant up
```

With the virtual machine set up, SSH into it:

```
vagrant ssh
```

Finally, deploy meza onto the machine:

```
sudo meza deploy vagrant
```

### Modifying your vagrant config

Within the meza repository, the file `vagrantconf.default.yml` is used by default. To use a custom config, copy that file:

```
cp vagrantconf.default.yml vagrantconf.yml
```

Prior to modifying this file, however, make sure you destroy any existing meza servers managed by vagrant. This is destructive. See [Vagrant docs regarding packaging boxes](https://www.vagrantup.com/docs/cli/package.html) for how to save your work.

```
# WARNING: This is destructive. See above.
vagrant destroy -f
```

You can then edit this file and make changes like number of CPUs or amount of RAM, or uncomment the `app2` or `db2` sections to add second app or database servers, respectively.

When you have the happy with the config, save the file and run:

```
vagrant up
vagrant ssh
sudo meza deploy vagrant
```
