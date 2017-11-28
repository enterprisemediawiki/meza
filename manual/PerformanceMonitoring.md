Performance Monitoring
======================

Meza provides the following basic performance monitoring functions. Future versions of meza hope to include more fully-featured options.

* Basic performance monitoring (response time and number of hits) is available at: `https://<domain-name-or-IP-address>/ServerPerformance/index.php`
* Disk space in the `/opt` directory is monitored, and can be viewed at: `https://<domain-name-or-IP-address>/ServerPerformance/space.php`
* Viewing Apache [mod_status](https://httpd.apache.org/docs/2.4/mod/mod_status.html) is possible if using [SAML authentication](SetupSAML.md): `https://<domain-name-or-IP-address>/ServerPerformance/mod_status.php`
  * It is also possible to access the data without authentication locally at: http://localhost:8090/server-status
* If `enable_haproxy_stats` is set to `true` in `/opt/conf-meza/public/public.yml`, see the HAProxy stats page at: `https://<domain-name-or-IP-address>:1936`
