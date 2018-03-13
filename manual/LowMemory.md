### RAM = 2GB or less?

If you run into memory errors during play execution, you can set the `forks` option in Ansible to `1` by either editing the system-wide config in `/etc/ansible/ansible.cfg`, or the Meza-specific config at `/opt/meza/config/core/ansible.cfg`.

It's also worth mentioning that if your server doesn't have any swap partition,
then you should add one.

For more discussion on performance tuning Meza, see https://github.com/enterprisemediawiki/meza/issues/867 and
https://discourse.equality-tech.com/t/how-do-i-optimize-apache/115

Some functions may not work with the default amount of memory allocated. 

```php
// SVG thumbnailing requires more memory
// Maximum amount of virtual memory available to shell processes in KB.
$wgMaxShellMemory = 1024*300; // 307200K is 300M
```
