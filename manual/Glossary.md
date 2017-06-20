Glossary
========

This file is a glossary of terms used in meza. Many of the terms are taken from MediaWiki, Ansible, or other software used within meza.

#### Environment

In the context of meza, "environment" means the specific meza installation you want to target. A meza [controller](#controller) can support multiple environments like "production", "staging", "test", and "dev". There is a special environment name called "monolith" that means the controller has all of the meza software (MediaWiki, database, Parsoid, etc) all installed on the same server. This special name simplifies the installation process. By initially saying `sudo meza deploy monolith` meza sets up an environment where all software components are directed to install on `localhost`. For any other environment you need to edit your `/opt/conf-meza/secret/hosts` file (AKA [inventory file](#inventory-file)) to tell each component where to install (e.g. Parsoid install on `192.168.56.2`, database master on `192.168.56.3`, etc).

#### Controller

The computer used to run meza commands (e.g. `meza deploy production`). This computer controls all other computers in your meza setup. In the simplest setups the controller will also be the "monolith" upon which all of meza is installed, but it could easily be a separate computer. At present it _probably_ needs to be running CentOS or RedHat 7, but it may be possible to use other systems. Hopefully it will be able to be run from a laptop eventually, running any OS supported as an Ansible controller.

#### (Ansible) Playbook

See Ansible playbook docs: http://docs.ansible.com/ansible/playbooks_intro.html

#### (Ansible) Role

See Ansible roles docs: http://docs.ansible.com/ansible/playbooks_roles.html

#### (Ansible) Task

See Ansible playbook docs: http://docs.ansible.com/ansible/playbooks_intro.html

#### (Docker) host

TBD

#### (Docker) container:

TBD

#### VM

Virtual Machine

#### Inventory file

File defining which software is installed on which servers within your meza installation. Also known as "hosts file". Both names are used in Ansible documentation. See also http://docs.ansible.com/ansible/intro_inventory.html

#### Hosts file

See [Inventory file](#inventory-file)
