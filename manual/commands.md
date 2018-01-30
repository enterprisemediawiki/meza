# Help
Once installed, if you run the `meza` command all by itself, it will display *help* like the following:
```bash
Mediawiki EZ Admin

Usage: meza COMMAND [directives]

To setup a multi-server environment, do:

$ meza setup env # Setup the environment, following prompts
# Edit config as required:
$ sudo vi /opt/conf-meza/secret/<env-name>/hosts
$ sudo vi /opt/conf-meza/secret/<env-name>/secret.yml
$ sudo meza deploy <env-name>

Commands    Directives           Description
---------------------------------------------------------------
install     dev-networking       Setup networking on VM
            monolith             Install server on this machine
            docker               Install Docker (CentOS only)
deploy      <environment name>   Deploy your server
setup       env                  Setup an environment
            dev                  Setup dev features (Git, FTP)
create      wiki                 Create a wiki
            wiki-promptless      Create a wiki without prompts
backup      <environment name>   Create a backup of an env
docker      run                  (experimental) Start container
            exec                 Execute command on container

Every command has directives. If you run any command without
directives it will provide help for that command.
```

# Passthru
Meza ultimately passes through options and arguments to [Ansible](https://www.ansible.com/quick-start-video)'s `ansible-playbook` command.  
So, if there are `ansible-playbook` options that you wish to use, you can do so.  Particularly useful for getting to know **Meza** are the
`--list-tags`, `--list-tasks`; `--tags` and `--skip-tags` options.  The first two are options that do not actually run the playbook, but 
rather they tell you more about it. 

## Tags

`sudo meza deploy monolith --list-tags` ('monolith' is any suitable environment name such as 'dev', 'staging', 'production')
Will output something like the following:

First it shows you the actual invocation of `ansible-playbook` that is run:
sudo -u meza-ansible ansible-playbook /opt/meza/src/playbooks/site.yml -i /opt/conf-meza/secret/monolith/hosts --vault-password-file /opt/conf-meza/users/meza-ansible/.vault-pass-monolith.txt --extra-vars '{"env": "monolith"}' --list-tags

Followed by the number of plays, and the tags associated with each:
```
playbook: /opt/meza/src/playbooks/site.yml

  play #1 (localhost): localhost        TAGS: []
      TASK TAGS: []

  play #2 (app-servers): app-servers    TAGS: []
      TASK TAGS: []

  play #3 (all:!exclude-all:!load-balancers-unmanaged): all:!exclude-all:!load-balancers-unmanaged      TAGS: [base]
      TASK TAGS: [base, latest]

  play #4 (load-balancers): load-balancers      TAGS: [load-balancer]
      TASK TAGS: [load-balancer]

  play #5 (app-servers): app-servers    TAGS: [apache-php]
      TASK TAGS: [apache-php, latest]

  play #6 (app-servers): app-servers    TAGS: [gluster]
      TASK TAGS: [gluster]

  play #7 (memcached-servers): memcached-servers        TAGS: [memcached]
      TASK TAGS: [latest, memcached]

  play #8 (db-master): db-master        TAGS: [database]
      TASK TAGS: [database]

  play #9 (db-slaves): db-slaves        TAGS: [database]
      TASK TAGS: [database]

  play #10 (elastic-servers): elastic-servers   TAGS: [elasticsearch]
      TASK TAGS: [elasticsearch]

  play #11 (app-servers): app-servers   TAGS: [mediawiki]
      TASK TAGS: [composer-extensions, git-core-extensions, git-extensions, git-local-extensions, git-submodules, latest, mediawiki, search-index, smw-data, update.php, verify-wiki]

  play #12 (parsoid-servers): parsoid-servers   TAGS: [parsoid]
      TASK TAGS: [latest, parsoid, parsoid-deps]

  play #13 (logging-servers): logging-servers   TAGS: [logging]
      TASK TAGS: [logging]

  play #14 (all:!exclude-all:!load-balancers-unmanaged): all:!exclude-all:!load-balancers-unmanaged     TAGS: [cron]
      TASK TAGS: [cron]
  ```
  
## Tasks
There is a lot of detail in the **list-tasks** output.  This is for reference only, and will change constantly as development is ongoing.

In the task list, you can see **tags** that are associated at the task level.  Again, this command will **not** execute a deploy.
It will only show you the tasks that would be run.

`sudo meza deploy monolith --list-tasks`
Will output something like the following:
```
playbook: /opt/meza/src/playbooks/site.yml

  play #1 (localhost): localhost        TAGS: []
    tasks:
      Ensure no password on meza-ansible user on controller     TAGS: []
      Ensure controller has user alt-meza-ansible       TAGS: []
      Ensure user alt-meza-ansible .ssh dir configured  TAGS: []
      Copy meza-ansible keys to alt-meza-ansible        TAGS: []
      Copy meza-ansible known_hosts to alt-meza-ansible TAGS: []
      Ensure secret.yml encrypted       TAGS: []
      Ensure secret.yml owned by meza-ansible   TAGS: []

  play #2 (app-servers): app-servers    TAGS: []
    tasks:
      set-vars : Set meza-core path variables   TAGS: []
      set-vars : If using gluster (app-servers > 1), override m_uploads_dir     TAGS: []
      set-vars : Set meza local public variables        TAGS: []
      set-vars : Get individual wikis dirs from localhost       TAGS: []
      set_fact  TAGS: []
      set-vars : Set meza local secret variables        TAGS: []
      init-controller-config : Does controller have local config        TAGS: []
      init-controller-config : Get local config repo if set     TAGS: []
      init-controller-config : Does controller have local config        TAGS: []
      init-controller-config : Ensure m_local_public configured on controller   TAGS: []
      init-controller-config : Ensure m_local_public/wikis exists       TAGS: []
      init-controller-config : Ensure pre/post settings directories exists in config    TAGS: []
      init-controller-config : Ensure base files present, do NOT overwrite      TAGS: []

```
And so on...

At the very end of output, it shows you the underlying ansible command:

`sudo -u meza-ansible ansible-playbook /opt/meza/src/playbooks/site.yml -i /opt/conf-meza/secret/monolith/hosts --vault-password-file /opt/conf-meza/users/meza-ansible/.vault-pass-monolith.txt --extra-vars '{"env": "monolith"}' --list-tasks`

As a side note, you can use the 'aha' utility to easily create [an HTML file for reference](https://freephile.org/wiki/Aha).

`sudo meza deploy production --list-tasks | sudo tee > >(aha --black --title "Production Deploy Tasks" > /tmp/deploy.tasks.html)`

# Using Tags and Skipping Tags

To be written.  In our next update, we'll show you how to use and skip tags.  You can even combine listing and skipping.

`sudo meza deploy monolith --list-tasks --skip-tags cron` Will show you all the tasks that would be executed if you skipped the 
cron tasks.









