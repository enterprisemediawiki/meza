### RAM = 2GB or less?

If you run into memory errors during play execution, you can set the `forks` option in Ansible to `1` by either editing the system-wide config in `/etc/ansible/ansible.cfg`, or the Meza-specific config at `/opt/meza/config/core/ansible.cfg`.

For more discussion on performance tuning Meza, see https://github.com/enterprisemediawiki/meza/issues/867 and
https://discourse.equality-tech.com/t/how-do-i-optimize-apache/115
