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

[alexy@TP2 ssh]$ [alexy@TP2 ssh]$ sudo cat sshd_config | grep Port
Port 4653
#GatewayPorts no
```
