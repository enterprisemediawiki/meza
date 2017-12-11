Performance Monitoring
======================

Meza provides the following basic performance monitoring functions. Future versions of meza hope to include more fully-featured options.

* Basic performance monitoring (response time and number of hits) is available at: `https://<domain-name-or-IP-address>/ServerPerformance/index.php`
* Disk space in the `/opt` directory is monitored, and can be viewed at: `https://<domain-name-or-IP-address>/ServerPerformance/space.php`
* Any user with the `viewserverstatus` right (sysops by default) can view `Special:Serverstatus` to see Apache `mod_status`, Apache `mod_info`, and `phpinfo` pages.
* If `enable_haproxy_stats` is set to `true` in `/opt/conf-meza/public/public.yml`, see the HAProxy stats page at: `https://<domain-name-or-IP-address>:1936`
