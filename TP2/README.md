# TP2 : Appréhender l'environnement Linux

## I. Service SSH

### 1. Analyse du service

🌞 S'assurer que le service sshd est démarré
        
 ```bash
[alexy@TP2 ~]$ systemctl status | grep sshd
    │ ├─sshd.service
    │ │ └─732 "sshd: /usr/sbin/sshd -D [listener] 0 of 10-100 startups"
        │ ├─885 "sshd: alexy [priv]"
        │ ├─889 "sshd: alexy@pts/0"
        │ └─933 grep --color=auto sshd
```


🌞 Analyser les processus liés au service SSH

```bash
[alexy@TP2 ~]$ ps -ef | grep sshd
root         732       1  0 11:57 ?        00:00:00 sshd: /usr/sbin/sshd -D [listener] 0 of 10-100 startups
root         885     732  0 12:00 ?        00:00:00 sshd: alexy [priv]
alexy        889     885  0 12:00 ?        00:00:00 sshd: alexy@pts/0
alexy        935     890  0 12:06 pts/0    00:00:00 grep --color=auto sshd
```

🌞 Déterminer le port sur lequel écoute le service SSH

```bash
[alexy@TP2 ~]$ ss | grep ssh
tcp   ESTAB  0      52                  192.168.56.104:ssh       192.168.56.1:oraclenames
```

🌞 Consulter les logs du service SSH

```bash
[alexy@TP2 log]$ sudo cat secure | grep ssh
Oct 14 12:40:36 localhost sshd[844]: Server listening on 0.0.0.0 port 22.
Oct 14 12:40:36 localhost sshd[844]: Server listening on :: port 22.
Oct 14 12:42:40 localhost sshd[844]: Received signal 15; terminating.
Oct 14 12:42:40 localhost sshd[29567]: Server listening on 0.0.0.0 port 22.
Oct 14 12:42:40 localhost sshd[29567]: Server listening on :: port 22.
Dec  5 11:46:42 localhost sshd[726]: Server listening on 0.0.0.0 port 22.
Dec  5 11:46:42 localhost sshd[726]: Server listening on :: port 22.
Dec  5 11:50:04 localhost sshd[732]: Server listening on 0.0.0.0 port 22.
Dec  5 11:50:04 localhost sshd[732]: Server listening on :: port 22.
Dec  5 11:53:46 localhost sshd[963]: Accepted password for alexy from 192.168.56.1 port 1430 ssh2
Dec  5 11:53:46 localhost sshd[963]: pam_unix(sshd:session): session opened for user alexy(uid=1000) by (uid=0)
Dec  5 11:55:48 localhost sshd[967]: Received disconnect from 192.168.56.1 port 1430:11: disconnected by user
Dec  5 11:55:48 localhost sshd[967]: Disconnected from user alexy 192.168.56.1 port 1430
Dec  5 11:55:48 localhost sshd[963]: pam_unix(sshd:session): session closed for user alexy
Dec  5 11:55:50 localhost sshd[997]: Accepted password for alexy from 192.168.56.1 port 1440 ssh2
Dec  5 11:55:50 localhost sshd[997]: pam_unix(sshd:session): session opened for user alexy(uid=1000) by (uid=0)
Dec  5 11:57:38 TP2 sshd[732]: Server listening on 0.0.0.0 port 22.
Dec  5 11:57:38 TP2 sshd[732]: Server listening on :: port 22.
Dec  5 11:58:04 TP2 sshd[860]: Accepted password for alexy from 192.168.56.1 port 1442 ssh2
Dec  5 11:58:04 TP2 sshd[860]: pam_unix(sshd:session): session opened for user alexy(uid=1000) by (uid=0)
Dec  5 11:58:33 TP2 sshd[864]: Received disconnect from 192.168.56.1 port 1442:11: disconnected by user
Dec  5 11:58:33 TP2 sshd[864]: Disconnected from user alexy 192.168.56.1 port 1442
Dec  5 11:58:33 TP2 sshd[860]: pam_unix(sshd:session): session closed for user alexy
Dec  5 12:00:10 TP2 sshd[885]: Accepted password for alexy from 192.168.56.1 port 1575 ssh2
Dec  5 12:00:10 TP2 sshd[885]: pam_unix(sshd:session): session opened for user alexy(uid=1000) by (uid=0)
```
🌞 Identifier le fichier de configuration du serveur SSH
```bash
[alexy@TP2 ssh]$ sudo cat sshd_config
```
🌞 Modifier le fichier de conf

```bash
[alexy@TP2 ssh]$ echo $RANDOM
4653
[alexy@TP2 ssh]$ sudo nano sshd_config
[alexy@TP2 ssh]$ sudo cat sshd_config | grep Port
Port 4653
#GatewayPorts no
[alexy@TP2 ssh]$ sudo firewall-cmd --remove-port=22/tcp --permanent
Warning: NOT_ENABLED: 22:tcp
success
[alexy@TP2 ssh]$ sudo firewall-cmd --add-port=4653/tcp --permanent
success

[alexy@TP2 ssh]$ sudo firewall-cmd --reload
success
[alexy@TP2 ssh]$ sudo systemctl restart sshd
[alexy@TP2 ssh]$ ss -alpnt
State        Recv-Q       Send-Q              Local Address:Port               Peer Address:Port       Process
LISTEN       0            128                       0.0.0.0:4563                      0.0.0.0:*
LISTEN       0            128                          [::]:4563                        [::]:*
[alexy@TP2 ssh]$ sudo firewall-cmd --list-all | grep port
  ports: 4563/tcp
  forward-ports:
  source-ports:
[alexy@TP2 ssh]$ exit
logout
Connection to 192.168.56.104 closed.
PS C:\WINDOWS\system32> ssh alexy@192.168.56.104 -p 4653
alexy@192.168.56.104's password:
Last login: Tue Dec  6 10:32:41 2022 from 192.168.56.104

```
## II. Service HTTP

### 1. Mise en place
🌞 Installer le serveur NGINX

```bash
[alexy@TP2 ~]$ sudo dnf install nginx
```
🌞 Démarrer le service NGINX
```bash
[alexy@TP2 ~]$ sudo systemctl enable nginx
[alexy@TP2 ~]$ sudo systemctl start nginx
```

🌞 Déterminer sur quel port tourne NGINX
```bash
[alexy@TP2 ~]$ sudo firewall-cmd --permanent --add-service=http
success
[alexy@TP2 ~]$ sudo firewall-cmd --permanent --list-all | grep services
  services: cockpit dhcpv6-client http ssh
```
```bash
[alexy@TP2 ~]$ sudo ss -alpnt | grep nginx
LISTEN 0      511          0.0.0.0:80        0.0.0.0:*    users:(("nginx",pid=11030,fd=6),("nginx",pid=11029,fd=6),(
nginx",pid=11028,fd=6))
LISTEN 0      511             [::]:80           [::]:*    users:(("nginx",pid=11030,fd=7),("nginx",pid=11029,fd=7),(
nginx",pid=11028,fd=7))
[alexy@TP2 ~]$ sudo firewall-cmd --add-port=80/tcp --permanent
[alexy@TP2 ~]$ sudo firewall-cmd --reload
success
```

🌞 Déterminer les processus liés à l'exécution de NGINX

```bash
[alexy@TP2 ~]$ ps -ef | grep NGINX
alexy      11161   11088  0 11:36 pts/0    00:00:00 grep --color=auto NGINX
```
🌞 Euh wait
```bash
[alexy@TP2 ~]$ curl http://192.168.56.104:80 | head -n 7
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  7620  100  7620    0     0  7441k      0 --:--:-- --:--:-- --:--:-- 7441k
<!doctype html>
<html>
  <head>
    <meta charset='utf-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1'>
    <title>HTTP Server Test Page powered by: Rocky Linux</title>
    <style type="text/css">
```

## 2. Analyser la conf de NGINX

🌞 Déterminer le path du fichier de configuration de NGINX

```bash 
[alexy@TP2 /]$ ls -al /etc/nginx/
total 84
drwxr-xr-x.  4 root root 4096 Dec  6 11:01 .
drwxr-xr-x. 78 root root 8192 Dec  6 11:01 ..
drwxr-xr-x.  2 root root    6 Oct 31 16:37 conf.d
drwxr-xr-x.  2 root root    6 Oct 31 16:37 default.d
-rw-r--r--.  1 root root 1077 Oct 31 16:37 fastcgi.conf
-rw-r--r--.  1 root root 1077 Oct 31 16:37 fastcgi.conf.default
-rw-r--r--.  1 root root 1007 Oct 31 16:37 fastcgi_params
-rw-r--r--.  1 root root 1007 Oct 31 16:37 fastcgi_params.default
-rw-r--r--.  1 root root 2837 Oct 31 16:37 koi-utf
-rw-r--r--.  1 root root 2223 Oct 31 16:37 koi-win
-rw-r--r--.  1 root root 5231 Oct 31 16:37 mime.types
-rw-r--r--.  1 root root 5231 Oct 31 16:37 mime.types.default
-rw-r--r--.  1 root root 2334 Oct 31 16:37 nginx.conf
-rw-r--r--.  1 root root 2656 Oct 31 16:37 nginx.conf.default
-rw-r--r--.  1 root root  636 Oct 31 16:37 scgi_params
-rw-r--r--.  1 root root  636 Oct 31 16:37 scgi_params.default
-rw-r--r--.  1 root root  664 Oct 31 16:37 uwsgi_params
-rw-r--r--.  1 root root  664 Oct 31 16:37 uwsgi_params.default
-rw-r--r--.  1 root root 3610 Oct 31 16:37 win-utf
```

🌞 Trouver dans le fichier de conf

```bash
[alexy@TP2 nginx]$ sudo cat nginx.conf | grep server -A 16
    server {
        listen       80;
        listen       [::]:80;
        server_name  _;
        root         /usr/share/nginx/html;

        # Load configuration files for the default server block.
        include /etc/nginx/default.d/*.conf;

        error_page 404 /404.html;
        location = /404.html {
        }

        error_page 500 502 503 504 /50x.html;
        location = /50x.html {
        }
    }

# Settings for a TLS enabled server.
#
#    server {
#        listen       443 ssl http2;
#        listen       [::]:443 ssl http2;
#        server_name  _;
#        root         /usr/share/nginx/html;
#
#        ssl_certificate "/etc/pki/nginx/server.crt";
#        ssl_certificate_key "/etc/pki/nginx/private/server.key";
#        ssl_session_cache shared:SSL:1m;
#        ssl_session_timeout  10m;
#        ssl_ciphers PROFILE=SYSTEM;
#        ssl_prefer_server_ciphers on;
#
#        # Load configuration files for the default server block.
#        include /etc/nginx/default.d/*.conf;
#
#        error_page 404 /404.html;
#            location = /40x.html {
#        }
#
#        error_page 500 502 503 504 /50x.html;
#            location = /50x.html {
#        }
#    }

}

[alexy@TP2 nginx]$ sudo cat nginx.conf | grep include
include /usr/share/nginx/modules/*.conf;
    include             /etc/nginx/mime.types;
    # See http://nginx.org/en/docs/ngx_core_module.html#include
    include /etc/nginx/conf.d/*.conf;
        include /etc/nginx/default.d/*.conf;
#        include /etc/nginx/default.d/*.conf;
```

## 3. Déployer un nouveau site web

🌞 Créer un site web

🌞 Adapter la conf NGINX

```bash
[alexy@TP2 conf.d]$ echo $RANDOM
25970

[alexy@TP2 conf.d]$ sudo firewall-cmd --add-port=25970/tcp --permanent
success

[alexy@TP2 conf.d]$  sudo firewall-cmd --reload
success
[alexy@TP2 conf.d]$  sudo systemctl restart nginx
```