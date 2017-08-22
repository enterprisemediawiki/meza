Setting up a multi-server environment
=====================================

Below is the basic procedure for setting up a multi-server environment.

## Definitions

* Controller: The server running the commands telling other servers what to do
* Minions: The other servers. These will end up being MediaWiki application servers, database servers, Node.js servers, Elasticsearch servers, etc.

## Setup controller

At this time **it is recommended that your controller also be an app-server.** This recommendation will be removed eventually.

```
sudo yum install -y git
sudo git clone https://github.com/enterprisemediawiki/meza /opt/meza
sudo bash /opt/meza/src/scripts/getmeza.sh
```

## On each minion
```
curl -Lf https://raw.github.com/enterprisemediawiki/meza/master/src/scripts/ssh-users/setup-minion-user.sh > minion
sudo bash minion
```

## Back on the controller
```
sudo bash /opt/meza/src/scripts/ssh-users/transfer-master-key.sh
# See *Troubleshooting* below if the transfer shows 'Permission denied' errors.
sudo meza setup env <your env name>

# Edit your inventory (aka "hosts") file as required
sudo vim /opt/conf-meza/secret/<your env name>/hosts

# Edit your secret config as required. This is more complicated because it
# is encrypted automatically. You're editing using the `ansible-vault`
# command making use of the password file that was generated in user
# `meza-ansible`'s home directory. Note: any users created by meza do not
# have their home directory under `/home` to avoid collision with Active
# Directory and such.
meza_env=<your env name>
sudo ansible-vault edit "/opt/conf-meza/secret/$meza_env/secret.yml" --vault-password-file "/opt/conf-meza/users/meza-ansible/.vault-pass-$meza_env.txt"

sudo meza deploy <your env name>
```

## Troubleshooting
If the `sudo bash /opt/meza/src/scripts/ssh-users/transfer-master-key.sh` gives you something like 
`Permission denied (publickey,gssapi-keyex,gssapi-with-mic).` It may have to do with ssh-agent forwarding and access to the minion.  Assuming you can `ssh` to the minion, here's how to perform this step manually.
```
# on the controller
sudo su - meza-ansible
cat .ssh/id_rsa.pub
#highlight that text and copy it to your clipboard
# on each minion
sudo su - meza-ansible
sudo vi .ssh/authorized_keys
# paste content from clipboard; save file
sudo chmod go-w .ssh/authorized_keys
# back on the controller
# test SSH as the meza-ansible user
ssh meza-ansible@<minion-ip>
<Ctrl+D> to logout
# re-run the transfer script because it ALSO is responsible for removing the password for the meza-ansible user
sudo bash /opt/meza/src/scripts/ssh-users/transfer-master-key.sh
```
