This container sets up an Nginx webserver with built-in letsencrypt client that automates free SSL server certificate generation and renewal processes. It is based on scripts from [linuxserver/letsencrypt](https://hub.docker.com/r/linuxserver/letsencrypt/) with some major differences:

* Does not contain **s6-overlay**.
* Does not contain **PHP**.
* Does not contain **fail2ban**.
* Does not restart **NGINX** when renewing. certificate.
* Contains newer version of **Certbot** (*0.14.0* vs *0.9.3*).

## Usage

```
docker create \
  --name=nginx-letsencrypt \
  -p 443:443 -p 80:80 \
  -v <path to data>:/var/lib/nginx-letsencrypt \
  -v <path to letsencrypt>:/etc/letsencrypt \
  -e EMAIL=<email> \
  -e DOMAINS=<domains> \
  -e DHLEVEL=2048
  -e TZ=<timezone> \
  chernetsov0/nginx-letsencrypt
```

## Parameters

* `-p 80 -p 443` - the port(s) used by **NGINX**.
* `-v <path to data>:/var/lib/nginx-letsencrypt` - dhparams file and previous `DOMAINS` and `DHLEVEL` value reside here.
* `-v <path to letsencrypt>:/etc/letsencrypt` - all files letsencrypt generates and uses reside here (including certificate).
* `-e DOMAINS` - domains for letsencrypt to get certificate for.

_Optional:_
* `-e EMAIL` - your e-mail address for cert registration and notifications
* `-e DHLEVEL` - dhparams bit value, can be set to `1024`, `2048` or `4096`.
* `-e TZ` - timezone ie. `America/New_York`.

## Setting up the application

* Before running this container, make sure that all domains in `DOMAINS` are properly forwarded to this container's host, and that ports 80 and 443 are not being used by another service on the host.
* The container detects changes to `DOMAINS`, revokes existing certificate and generates new one during start. It also detects changes to the `DHLEVEL` parameter and replaces the dhparams file.
