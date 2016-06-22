# Setup Digital Ocean

This manual describes how to prepare [Digital Ocean](https://digitalocean.com) for meza install. It assumes you already have a Digital Ocean account.

## Create droplet

1. Click "create droplet"
1. Choose a "droplet hostname", which can really be anything that identifies this droplet from the others. For example, if you're just testing out meza you may choose "meza_test_2015-07-26".
1. Choose any droplet size with at least 1 GB RAM
1. Select a region close the people who will be using your service
1. Under "select image" select the CentOS operatings system, then under "version" select "7.x x64"
1. No additional settings required at this time
1. It is highly recommended you setup SSH keys on your computer, and put the public key on Digital Ocean. See [this tutorial](https://help.github.com/articles/generating-ssh-keys/) explaining how to setup SSH keys.
1. Once SSH keys are setup, choose yours for this droplet
1. Click "create droplet"
1. Wait about a minute for the droplet to be created

## Optional user setup

If you'd like to setup a user other than root, perform the following:

1. `adduser your_username`
1. `passwd your_username`
1. `visudo`
	1. The file that appears is being edited with a program called "vi". If you're familiar with vi skip to the last two steps of this procedure
	1. Hit the down arrow until you find a line like "root    ALL=(ALL)       ALL". Alternatively learn to [search in vi](http://www.felixgers.de/teaching/emacs/vi_search_replace.html)
	1. Put your cursor at the end of that line, then press "i" to enter "insert" mode.
	1. Hit "enter" to create a new line, then type a copy of the line above but replacing "root" for your username
	1. Hit "escape" to exit the "insert" mode
	1. Type ":wq" to write (save) the changes to the file and quit the editor
	1. You can now exit your SSH session (type "exit") and start a new one with your new user

## Run meza install

You're done setting up your Digital Ocean server. You can now do the steps in the main [README](../README.md).
