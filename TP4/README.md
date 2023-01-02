# TP4 : Real services

## Partie 1 : Partitionnement du serveur de stockage

🌞 Partitionner le disque à l'aide de LVM

```bash
[alexy@storage ~]$ sudo pvcreate /dev/sdb
  Physical volume "/dev/sdb" successfully created.
[alexy@storage ~]$ sudo pvs
  PV         VG      Fmt  Attr PSize  PFree
  /dev/sdb   storage lvm2 a--  <2.00g    0

[alexy@storage ~]$ sudo vgcreate storage /dev/sdb
  Volume group "storage" successfully created
[alexy@storage ~]$ sudo vgs
  VG      #PV #LV #SN Attr   VSize  VFree
  storage   1   1   0 wz--n- <2.00g    0

[alexy@storage ~]$ sudo lvcreate -l 100%FREE storage -n lv_storage
  Logical volume "lv_storage" created.
[alexy@storage ~]$ sudo lvs
  lv_storage storage -wi-a----- <2.00g
```

🌞 Formater la partition

```bash
[alexy@storage ~]$ sudo mkfs -t ext4 /dev/storage/lv_storage
mke2fs 1.46.5 (30-Dec-2021)
Creating filesystem with 523264 4k blocks and 130816 inodes
Filesystem UUID: 26f8a59f-96ff-4bf9-a071-f813df56ef40
Superblock backups stored on blocks:
        32768, 98304, 163840, 229376, 294912

Allocating group tables: done
Writing inode tables: done
Creating journal (8192 blocks): done
Writing superblocks and filesystem accounting information: done

[alexy@storage ~]$ sudo lvdisplay
  Devices file sys_wwid t10.ATA_____VBOX_HARDDISK___________________________VB40e91214-eab74cd9_ PVID JQFx4MDHn2EBXRrfm1zSpBU2d5nCx1Cz last seen on /dev/sda2 not found.
  --- Logical volume ---
  LV Path                /dev/storage/lv_storage
  LV Name                lv_storage
  VG Name                storage
  LV UUID                ued09F-vDKG-vEJ9-tsAE-JgCx-8sT7-iNehwP
  LV Write Access        read/write
  LV Creation host, time storage.tp4.linux, 2022-12-13 11:27:34 +0100
  LV Status              available
  # open                 0
  LV Size                <2.00 GiB
  Current LE             511
  Segments               1
  Allocation             inherit
  Read ahead sectors     auto
  - currently set to     256
  Block device           253:2
  ```

🌞 Monter la partition

```bash
[alexy@storage ~]$ sudo mkdir /mnt/storage
[alexy@storage ~]$ sudo mount /dev/storage/lv_storage /mnt/storage/
[alexy@storage ~]$ df -h | grep mnt
/dev/mapper/storage-lv_storage  2.0G   24K  1.9G   1% /mnt/storage

[alexy@storage ~]$ cd /mnt/storage/

[alexy@storage storage]$ ls
lost+found  toto
[alexy@storage storage]$ cat toto
bijour

[alexy@storage /]$ sudo nano /etc/fstab
[alexy@storage /]$ sudo umount /mnt/storage/
[alexy@storage /]$ sudo mount -av
/                        : ignored
/boot                    : already mounted
none                     : ignored
mount: /mnt/storage does not contain SELinux labels.
       You just mounted a file system that supports labels which does not
       contain labels, onto an SELinux box. It is likely that confined
       applications will generate AVC messages and not be allowed access to
       this file system.  For more details see restorecon(8) and mount(8).
/mnt/storage/            : successfully mounted

```

## Partie 2 : Serveur de partage de fichiers


🌞 **Donnez les commandes réalisées sur le serveur NFS `storage.tp4.linux`**

- contenu du fichier `/etc/exports` dans le compte-rendu notamment

```
[alexy@storage /]$ sudo mkdir /storage/site_web_1 -p
```

```
[alexy@storage /]$ sudo mkdir /storage/site_web_2 -p
```

```
[alexy@storage /]$ ls -dl /storage/site_web_1
drwxr-xr-x. 2 root root 6 Dec 13 12:23 /storage/site_web_1/
```

```
[alexy@storage /]$ ls -dl /storage/site_web_2
drwxr-xr-x. 2 root root 6 Dec 13 12:23 /storage/site_web_2/
```

```
[alexy@storage /]$ sudo chown nobody /storage/site_web_1
```

```
[alexy@storage /]$ sudo chown nobody /storage/site_web_2
```

```
[alexy@storage /]$ cat /etc/exports
export/site_web_1      10.4.1.58(rw,sync,no_subtree_check)
export/site_web_2      10.4.1.58(rw,sync,no_subtree_check)
```

```
[alexy@storage /]$ sudo systemctl enable nfs-server
Created symlink /etc/systemd/system/multi-user.target.wants/nfs-server.service → /usr/lib/systemd/system/nfs-server.service.
```

```
[alexy@storage /]$ sudo systemctl start nfs-server
```

```
[alexy@storage /]$ sudo systemctl status nfs-server
● nfs-server.service - NFS server and services
     Loaded: loaded (/usr/lib/systemd/system/nfs-server.service; enabled; vendo>
    Drop-In: /run/systemd/generator/nfs-server.service.d
             └─order-with-mounts.conf
     Active: active (exited) since Tue 2022-12-13 12:03:36 CET; 7s ago
    Process: 11240 ExecStartPre=/usr/sbin/exportfs -r (code=exited, status=0/SU>
    Process: 11241 ExecStart=/usr/sbin/rpc.nfsd (code=exited, status=0/SUCCESS)
    Process: 11257 ExecStart=/bin/sh -c if systemctl -q is-active gssproxy; the>
   Main PID: 11257 (code=exited, status=0/SUCCESS)
        CPU: 13ms

Dec 13 12:03:36 storage.tp4.linux systemd[1]: Starting NFS server and services.>
Dec 13 12:03:36 storage.tp4.linux systemd[1]: Finished NFS server and services.
```

```
[alexy@storage /]$ sudo firewall-cmd --permanent --list-all |grep services  services: cockpit dhcpv6-client ssh
```

```
[alexy@storage /]$ sudo firewall-cmd --permanent --add-service=nfs
success
```

```
[alexy@storage /]$ sudo firewall-cmd --permanent --add-service=mountd
success
```

```
[alexy@storage /]$ sudo firewall-cmd --permanent --add-service=rpc-bind
success
```

```
[alexy@storage /]$ sudo firewall-cmd --reload
success
```

```
[alexy@storage /]$ sudo firewall-cmd --permanent --list-all |grep services
  services: cockpit dhcpv6-client mountd nfs rpc-bind ssh
```

🌞 **Donnez les commandes réalisées sur le client NFS `web.tp4.linux`**

- contenu du fichier `/etc/fstab` dans le compte-rendu notamment

```
[alexy@web /]$ sudo mkdir -p /var/www/site_web_1
```

```
[alexy@web /]$ sudo mkdir -p /var/www/site_web_2
```

```
[alexy@web /]$ sudo mount 10.4.1.60:/storage/site_web_1 /var/www/site_web_1
```

```
[alexy@web /]$ sudo mount 10.4.1.60:/storage/site_web_2 /var/www/site_web_2
```

```
[alexy@web /]$ df -h
Filesystem                     Size  Used Avail Use% Mounted on
devtmpfs                       462M     0  462M   0% /dev
tmpfs                          481M     0  481M   0% /dev/shm
tmpfs                          193M  4.8M  188M   3% /run
/dev/mapper/rl-root            6.5G  1.2G  5.4G  18% /
/dev/sda1                     1014M  210M  805M  21% /boot
tmpfs                           97M     0   97M   0% /run/user/1000
10.4.1.60:/storage/site_web_1  6.5G  1.2G  5.4G  18% /var/www/site_web_1
10.4.1.60:/storage/site_web_2  6.5G  1.2G  5.4G  18% /var/www/site_web_2
```

```
[alexy@web /]$ sudo touch /var/www/site_web_1/site_web_1.test
```

```
[alexy@web /]$ sudo touch /var/www/site_web_2/site_web_2.test
```

```
[alexy@web /]$ ls -l /var/www/site_web_1/site_web_1.test
-rw-r--r--. 1 nobody nobody 0 Jan  2 09:47 /var/www/site_web_1/site_web_1.test
```

```
[alexy@web /]$ ls -l /var/www/site_web_2/site_web_2.test
-rw-r--r--. 1 nobody nobody 0 Jan  2 09:48 /var/www/site_web_2/site_web_2.test
```

```
[alexy@web /]$ sudo nano /etc/fstab
[alexy@web /]$ cat /etc/fstab
10.4.1.60:/storage/site_web_1   /var/www/site_web_1     nfs auto,nofail,noatime,nolock,intr,tcp,actimeo=1800 0 0
10.4.1.60:/storage/site_web_2   /var/www/site_web_2     nfs auto,nofail,noatime,nolock,intr,tcp,actimeo=1800 0 0
```

## Partie 3 : Serveur web

### 2. Install

🌞 Installez NGINX
```
[alexy@web www]$ sudo dnf install nginx
```

### 3. Analyse

```
[alexy@web www]$ sudo systemctl start nginx
[alexy@web www]$ sudo systemctl status nginx
```

🌞 Analysez le service NGINX

```bash
[alexy@web www]$ ps aux | grep nginx
root       11132  0.0  0.0  10088   944 ?        Ss   10:40   0:00 nginx: master process /usr/sbin/nginx
nginx      11133  0.0  0.4  13856  4808 ?        S    10:40   0:00 nginx: worker process
nginx      11134  0.0  0.4  13856  4808 ?        S    10:40   0:00 nginx: worker process
alexy      11186  0.0  0.2   6412  2164 pts/0    S+   10:48   0:00 grep --color=auto nginx

[alexy@web www]$ sudo ss -tulpn | grep nginx

tcp   LISTEN 0      511          0.0.0.0:80        0.0.0.0:*    users:(("nginx",pid=11134,fd=6),("nginx",pid=11133,fd=6),("nginx",pid=11132,fd=6))
tcp   LISTEN 0      511             [::]:80           [::]:*    users:(("nginx",pid=11134,fd=7),("nginx",pid=11133,fd=7),("nginx",pid=11132,fd=7))

[alexy@web www]$ sudo cat /etc/nginx/nginx.conf | grep root
        root         /usr/share/nginx/html;

[alexy@web www]$ ls -l /usr/share/nginx/html
total 12
-rw-r--r--. 1 root root 3332 Oct 31 16:35 404.html
-rw-r--r--. 1 root root 3404 Oct 31 16:35 50x.html
drwxr-xr-x. 2 root root   27 Jan  2 10:40 icons
lrwxrwxrwx. 1 root root   25 Oct 31 16:37 index.html -> ../../testpage/index.html
-rw-r--r--. 1 root root  368 Oct 31 16:35 nginx-logo.png
lrwxrwxrwx. 1 root root   14 Oct 31 16:37 poweredby.png -> nginx-logo.png
lrwxrwxrwx. 1 root root   37 Oct 31 16:37 system_noindex_logo.png -> ../../pixmaps/system-noindex-logo.png

```

### 4. Visite du service web

🌞 Configurez le firewall pour autoriser le trafic vers le service NGINX
```
[alexy@web www]$ sudo firewall-cmd --add-port=80/tcp --permanent
success
```

🌞 Accéder au site web

```[alexy@web www]$ curl -s http://192.168.56.104:80 | head -n 5
<!doctype html>
<html>
  <head>
    <meta charset='utf-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1'>
```

🌞 Vérifier les logs d'accès
```
[alexy@web log]$ sudo cat /var/log/nginx/access.log | tail -n 3
192.168.56.104 - - [02/Jan/2023:11:21:19 +0100] "GET / HTTP/1.1" 200 7620 "-" "curl/7.76.1" "-"
192.168.56.104 - - [02/Jan/2023:11:21:31 +0100] "GET / HTTP/1.1" 200 7620 "-" "curl/7.76.1" "-"
192.168.56.104 - - [02/Jan/2023:11:21:38 +0100] "GET / HTTP/1.1" 200 7620 "-" "curl/7.76.1" "-"
```

### 5. Modif de la conf du serveur web

🌞 Changer le port d'écoute
```
[alexy@web log]$ sudo cat /etc/nginx/nginx.conf | grep 8080
        listen       8080;
        listen       [::]:8080;

[alexy@web log]$ sudo systemctl restart nginx
[alexy@web log]$ systemctl status nginx
● nginx.service - The nginx HTTP and reverse proxy server
     Loaded: loaded (/usr/lib/systemd/system/nginx.service; enabled; vendor>
     Active: active (running)

[alexy@web log]$ sudo ss -tulpn | grep nginx
tcp   LISTEN 0      511          0.0.0.0:8080      0.0.0.0:*    users:(("nginx",pid=11343,fd=6),("nginx",pid=11342,fd=6),("nginx",pid=11341,fd=6))
tcp   LISTEN 0      511             [::]:8080         [::]:*    users:(("nginx",pid=11343,fd=7),("nginx",pid=11342,fd=7),("nginx",pid=11341,fd=7))
[alexy@web log]$ sudo firewall-cmd --remove-port=80/tcp --permanent
success
[alexy@web log]$ sudo firewall-cmd --add-port=8080/tcp --permanent
success

[alexy@web log]$ curl -s http://192.168.56.104:8080 | head -n 5
<!doctype html>
<html>
  <head>
    <meta charset='utf-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1'>
 ```


🌞 Changer l'utilisateur qui lance le service

```
[alexy@web log]$ sudo nano /var/www/site_web_1/index.html
[alexy@web log]$ sudo cat /var/www/site_web_1/index.html

bijour
[alexy@web log]$ sudo cat /etc/nginx/nginx.conf | grep root
        root         /var/www/site_web_1/index.html;

[alexy@web log]$ sudo systemctl restart nginx

[alexy@web log]$ curl -s http://192.168.56.104:8080 | head -n 5
<html>
<head><title>404 Not Found</title></head>
<body>
<center><h1>404 Not Found</h1></center>
<hr><center>nginx/1.20.1</center>
```
### 6. Deux sites web sur un seul serveur

🌞 Repérez dans le fichier de conf

```
[alexy@web log]$ sudo cat /etc/nginx/nginx.conf  | grep conf.d
    include /etc/nginx/conf.d/*.conf;

```