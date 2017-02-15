Database Setup
==============

There are many different options for database configuration.

Is there a database server on the main application server? Is it the only database server, or are there other database servers? If there are others, is the one on the application server the master or a slave?

In order to minimize variation between each setup, the following will be done for all servers that have a database:

1. Setup `root` account
  1. All servers will have the same `root` password
  2. The `root` user will only be allowed to access locally, not from other servers
2. Setup `wiki_app_user` account
  1. Password the same on all databases (master and slave). This may be changed at another time.
  2. `wiki_app_user` will be setup to be able to access from all application servers plus localhost
3. Configure `bind-address` in `/etc/my.cnf`
  1. If is `appserver`, do nothing
  2. If not, bind-address=the server's IP address
4. Configure firewall to allow MySQL through. FIXME: This should specifically allow the appservers only...maybe

Examples
--------

Option 1:
```
db_master=192.168.56.60
db_slaves=192.168.56.61,appserver
```

Option 2:
```
db_servers=192.168.56.60,192.168.56.61,appserver
```
