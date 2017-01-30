meza ansible
============

temporary scratchpad for switching to ansible...

now run command like

```
cd /opt/meza/ansible
sudo sudo -u meza-ansible ansible-playbook site.yml -i env/prod/hosts


## Want to be able to setup configuration like

```
meza install control
meza get-local-config production https://gitlab.jsc.nasa.gov/NASAWiki/local-config.git production
meza get-secure-config production https://gitlab.jsc.nasa.gov/NASAWiki/secure-config.git production
```

## modifying production should have a prompt like

> "To process this request against production servers, type the following and press ENTER: x2sAt"

## Logging

each run of a meza-ansible command should write to a log like:

```
YYYYMMDDHHIISS ansible-playbook site.yml --limit db-master
	meza-ansible version ae235f12bc3 remote https://github.com/enterprisemediawiki/meza
	inventory production
	local config 64345f343a remote https://gitlab.jsc.nasa.gov/NASAWiki/local-config.git
	secure config 323aeb3c56 remote https://gitlab.jsc.nasa.gov/NASAWiki/secure-config.git
```

## what do people want to change?
	their Logo
	generic localsettings
	specific localsettings
