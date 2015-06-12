CentOS VM Setup
===============

Open http port ( 80 ) in iptables on CentOS
	http://www.binarytides.com/open-http-port-iptables-centos/


Allow HTTP (port 80) on eth1 (the host-only adapter)
```bash
iptables -I INPUT 5 -i eth1 -p tcp --dport 80 -m state --state NEW,ESTABLISHED -j ACCEPT
```

Save the changes to iptables so it survives reboot
```bash
service iptables save
```

This works for in this initial setup, but in the future we should consider a [method to define entire iptables config](http://blog.astaz3l.com/2015/03/06/secure-firewall-for-centos/).








