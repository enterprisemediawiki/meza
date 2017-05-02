## Use Sublime Text Over SSH
Follow these steps if you'd like to use Sublime Text to edit files you access via SSH:

1. Install [Package Control for Sublime Text (2 or 3)](https://packagecontrol.io/installation) 
1. Install the rsub package via two commands:
 1. `cd ~/Library/Application Support/Sublime Text 2/Packages` (change the "2" for "3" if you have ST3)
 1. `git clone git://github.com/henrikpersson/rsub.git rsub`
1. Restart Sublime Text
1. `vi  ~/.ssh/config`
1. Append the following to this file:
 1. `Host 192.168.56.56` (adjust IP as necessary)
 1. `RemoteForward 52698 127.0.0.1:52698`
1. Save the file
1. SSH to your VM
1. `sudo wget -O /usr/local/bin/rsub https://raw.github.com/aurora/rmate/master/rmate`
1. `sudo chmod +x /usr/local/bin/rsub`
1. Note: A reboot of the VM may be necessary
1. With Sublime Text open, run `rsub my_file.html`

### References
1. Instructive blog posts [1](http://log.liminastudio.com/writing/tutorials/sublime-tunnel-of-love-how-to-edit-remote-files-with-sublime-text-via-an-ssh-tunnel), [2](http://www.lleess.com/2013/05/how-to-edit-remote-files-with-sublime.html), & [3](https://wrgms.com/editing-files-remotely-via-ssh-on-sublimetext-3/)
1. [Rsub repo](https://github.com/henrikpersson/rsub)
