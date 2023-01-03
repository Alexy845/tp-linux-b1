# TP5 linux

## Partie 1

### 1. Installation

🌞 Installer le serveur Apache

```
[alexy@web ~]$ sudo dnf install httpd

[alexy@web ~]$ sudo vim /etc/httpd/conf/httpd.conf
```

🌞 Démarrer le service Apache

```
[alexy@web ~]$ sudo systemctl start httpd
[alexy@web ~]$ sudo systemctl status httpd
● httpd.service - The Apache HTTP Server
     Loaded: loaded (/usr/lib/systemd/system/httpd.service; disabled; vendor preset: disabled)
     Active: active (running) since Tue 2023-01-03 15:02:31 CET; 11s ago
       Docs: man:httpd.service(8)
   Main PID: 1463 (httpd)
     Status: "Total requests: 0; Idle/Busy workers 100/0;Requests/sec: 0; Bytes served/sec:   0 B/sec"
      Tasks: 213 (limit: 5904)
     Memory: 41.2M
        CPU: 78ms
     CGroup: /system.slice/httpd.service
             ├─1463 /usr/sbin/httpd -DFOREGROUND
             ├─1464 /usr/sbin/httpd -DFOREGROUND
             ├─1465 /usr/sbin/httpd -DFOREGROUND
             ├─1466 /usr/sbin/httpd -DFOREGROUND
             └─1467 /usr/sbin/httpd -DFOREGROUND

Jan 03 15:02:30 web.linux.tp5 systemd[1]: Starting The Apache HTTP Server...
Jan 03 15:02:31 web.linux.tp5 httpd[1463]: Server configured, listening on: port 80
Jan 03 15:02:31 web.linux.tp5 systemd[1]: Started The Apache HTTP Server.

[alexy@web ~]$ sudo systemctl enable httpd
Created symlink /etc/systemd/system/multi-user.target.wants/httpd.service → /usr/lib/systemd/system/httpd.service.
[alexy@web ~]$ sudo systemctl is-enabled httpd
enabled

[alexy@web ~]$ sudo ss -tulpn | grep httpd
tcp   LISTEN 0      511                *:80              *:*    users:(("httpd",pid=1467,fd=4),("httpd",pid=1466,fd=4),("httpd",pid=1465,fd=4),("httpd",pid=1463,fd=4))

[alexy@web ~]$ sudo firewall-cmd --add-port=80/tcp --permanent
success
```

🌞 TEST

```
[alexy@web ~]$ curl -s 80 localhost | head -n 5
<!doctype html>
<html>
  <head>
    <meta charset='utf-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1'>
```

### 2. Avancer vers la maîtrise du service

🌞 Le service Apache...

```
[alexy@web ~]$ sudo cat /usr/lib/systemd/system/httpd.service
# See httpd.service(8) for more information on using the httpd service.

# Modifying this file in-place is not recommended, because changes
# will be overwritten during package upgrades.  To customize the
# behaviour, run "systemctl edit httpd" to create an override unit.

# For example, to pass additional options (such as -D definitions) to
# the httpd binary at startup, create an override unit (as is done by
# systemctl edit) and enter the following:

#       [Service]
#       Environment=OPTIONS=-DMY_DEFINE

[Unit]
Description=The Apache HTTP Server
Wants=httpd-init.service
After=network.target remote-fs.target nss-lookup.target httpd-init.service
Documentation=man:httpd.service(8)

[Service]
Type=notify
Environment=LANG=C

ExecStart=/usr/sbin/httpd $OPTIONS -DFOREGROUND
ExecReload=/usr/sbin/httpd $OPTIONS -k graceful
# Send SIGWINCH for graceful stop
KillSignal=SIGWINCH
KillMode=mixed
PrivateTmp=true
OOMPolicy=continue

[Install]
WantedBy=multi-user.target
```

🌞 Déterminer sous quel utilisateur tourne le processus Apache

```
[alexy@web ~]$ sudo cat /etc/httpd/conf/httpd.conf | grep -i user
User apache

[alexy@web ~]$ ps -ef | grep apache
apache      1464    1463  0 15:02 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
apache      1465    1463  0 15:02 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
apache      1466    1463  0 15:02 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
apache      1467    1463  0 15:02 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
alexy       1772    1052  0 15:21 pts/0    00:00:00 grep --color=auto apache

[alexy@web testpage]$ ls -al
total 12
drwxr-xr-x.  2 root root   24 Jan  3 14:49 .
drwxr-xr-x. 82 root root 4096 Jan  3 14:49 ..
-rw-r--r--.  1 root root 7620 Jul 27 20:05 index.html

```

🌞 Changer l'utilisateur utilisé par Apache

```
[alexy@web testpage]$ sudo adduser toto

[alexy@web testpage]$ cat /etc/passwd | tail -n 5
systemd-oom:x:992:992:systemd Userspace OOM Killer:/:/usr/sbin/nologin
alexy:x:1000:1000:alexy:/home/alexy:/bin/bash
tcpdump:x:72:72::/:/sbin/nologin
apache:x:48:48:Apache:/usr/share/httpd:/sbin/nologin
toto:x:1001:1001::/home/toto:/bin/bash/nologin

[alexy@web testpage]$ sudo cat /etc/httpd/conf/httpd.conf | grep -i user
User toto

[alexy@web testpage]$ sudo systemctl restart httpd

[alexy@web testpage]$ ps -ef | grep toto
toto        2278    2276  0 15:42 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
toto        2279    2276  0 15:42 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
toto        2280    2276  0 15:42 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
toto        2281    2276  0 15:42 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
alexy       2495    1052  0 15:42 pts/0    00:00:00 grep --color=auto toto
```

🌞 Faites en sorte que Apache tourne sur un autre port

```
[alexy@web testpage]$ sudo firewall-cmd --add-port=24543/tcp --permanent
success
[alexy@web testpage]$ sudo cat /etc/httpd/conf/httpd.conf | grep Listen
Listen 24543
[alexy@web testpage]$ sudo firewall-cmd --remove-port=80/tcp --permanent
success
[alexy@web testpage]$ sudo systemctl restart httpd
[alexy@web testpage]$ sudo ss -tulpn | grep httpd
tcp   LISTEN 0      511                *:24543            *:*    users:(("httpd",pid=2523,fd=4),("httpd",pid=2522,fd=4),("httpd",pid=2521,fd=4),("httpd",pid=2519,fd=4))

[alexy@web testpage]$ curl -s localhost:24543 | head -n 5
<!doctype html>
<html>
  <head>
    <meta charset='utf-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1'>
```

## Partie 2 : Mise en place et maîtrise du serveur de base de données

🌞 Install de MariaDB sur db.tp5.linux

```
[alexy@db ~]$ sudo dnf install mariadb-server

[alexy@db ~]$ sudo systemctl enable mariadb
Created symlink /etc/systemd/system/mysql.service → /usr/lib/systemd/system/mariadb.service.
Created symlink /etc/systemd/system/mysqld.service → /usr/lib/systemd/system/mariadb.service.
Created symlink /etc/systemd/system/multi-user.target.wants/mariadb.service → /usr/lib/systemd/system/mariadb.service.

[alexy@db ~]$ sudo systemctl start mariadb

[alexy@db ~]$ sudo systemctl is-enabled mariadb
enabled
```

🌞 Port utilisé par MariaDB

```
[alexy@db ~]$ sudo ss -tulnp | grep mariadb
tcp   LISTEN 0      80                 *:3306            *:*    users:(("mariadbd",pid=13078,fd=19))

[alexy@db ~]$  sudo firewall-cmd --add-port=3306/tcp --permanent
success
[alexy@db ~]$ sudo firewall-cmd --reload
success
[alexy@db ~]$ sudo mysql_secure_installation
```

🌞 Processus liés à MariaDB

```
[alexy@db ~]$ ps -ef | grep mariadb
mysql      13078       1  0 16:31 ?        00:00:00 /usr/libexec/mariadbd --basedir=/usr
alexy      13198     985  0 16:41 pts/1    00:00:00 grep --color=auto mariadb
```

## Partie 3 : Configuration et mise en place de NextCloud

### 1. Base de données

🌞 Préparation de la base pour NextCloud

