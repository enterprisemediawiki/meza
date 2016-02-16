# Elasticsearch Plugins

At present there are four Elasticsearch plugins installed:

* [Kopf](https://github.com/lmenezes/elasticsearch-kopf)
* [Elasticsearch-head](https://mobz.github.io/elasticsearch-head/)
* [Bigdesk](http://bigdesk.org/)
* [Inquisitor](https://github.com/polyfractal/elasticsearch-inquisitor)

## Enabling access

By default Elasticsearch is not accessible from outside the server. In order to access it you need to create an authenticated user by performing the following command:

```
sudo htpasswd -c /etc/httpd/.htpasswd <username>
```

You will then be prompted to enter a password. Make sure this is a strong password. If you want to create additional users perform the same command without the `-c` option:

```
sudo htpasswd /etc/httpd/.htpasswd <username>
```

Note that this connection is read-only. You can only perform GET requests to Elasticsearch.

## Accessing each plugin

To access each plugin, navigate to the following URIs:

* Kopf: http://<your-domain>:8008/_plugin/kopf
* Head: http://<your-domain>:8008/_plugin/elasticsearch-head
* Bigdesk: http://<your-domain>:8008/_plugin/bigdesk
* Inquisitor: http://<your-domain>:8008/_plugin/inquisitor

