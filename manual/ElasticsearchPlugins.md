# Elasticsearch Plugins

## Installed plugins

At present there are four Elasticsearch plugins installed:

* [Kopf](https://github.com/lmenezes/elasticsearch-kopf)
* [Elasticsearch-head](https://mobz.github.io/elasticsearch-head/)

**WARNING: all pre-installed plugins may be removed in future versions of meza**

## Enabling access

At present meza does not have a built in method to enable access to Elasticsearch and plugins from a remote web browser. For now, do the following:

**WARNING: This method opens Elasticsearch up completely. Anyone will be able to view and modify your indexes. This should be used in development only!**

Open firewal port 8008:

```
sudo firewall-cmd --zone=public --add-port=8008/tcp --permanent
sudo firewall-cmd --reload
```

Add HAProxy rule for 8008 --> 9200 by editing `/etc/haproxy/haproxy.cfg`, and add the following:

```
frontend elastic-front
	bind *:8008
	mode http
	default_backend elastic-back

backend elastic-back
	mode http
	option forwardfor
	balance source
	option httpclose
	server es1 127.0.0.1:9200 weight 1 check inter 1000 rise 5 fall 1
```

Restart HAProxy: `sudo systemctl restart haproxy`

Use browser to access: `http://<your domain or IP address>:8008`

**WARNING: This method opens Elasticsearch up completely. Anyone will be able to view and modify your indexes. This should be used in development only!**

## Accessing each plugin

To access each plugin, navigate to the following URIs:

* Kopf: `http://<your-domain>:8008/_plugin/kopf`
* Head: `http://<your-domain>:8008/_plugin/elasticsearch-head`

