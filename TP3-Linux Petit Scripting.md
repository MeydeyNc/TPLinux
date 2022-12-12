# TP3-Linux Petit Scripting

## I. Script Carte d'identité. 

Voici ce que donne le script une fois lancé : 
````
[mmederic@michel ~]$ /srv/idcard/idcard.sh
Machine Name : michel
OS : Rocky Linux echo and kernel version is 5.14.0-162.6.1.el9_1.0.1.x86_64
IP : 10.1.2.5/24
RAM : 475Mi echo memory available on 764Mi total memory
Disk : 5.0G space left
Top 5 processes by RAM usage :
 6.3 /usr/bin/python3 -s /usr/sbin/firewalld --nofork --nopid
 2.4 /usr/sbin/NetworkManager --no-daemon
 1.9 /usr/lib/systemd/systemd --switched-root --system --deserialize 27
 1.7 /usr/lib/systemd/systemd --user
 1.5 sshd: mmederic [priv]
Listening ports :
Netid State  Recv-Q Send-Q Local Address:Port Peer Address:PortProcess
udp   UNCONN 0      0          127.0.0.1:323       0.0.0.0:*    users:(("chronyd",pid=711,fd=5))
udp   UNCONN 0      0              [::1]:323          [::]:*    users:(("chronyd",pid=711,fd=6))
tcp   LISTEN 0      128          0.0.0.0:22        0.0.0.0:*    users:(("sshd",pid=728,fd=3))
tcp   LISTEN 0      128             [::]:22           [::]:*    users:(("sshd",pid=728,fd=4))
Here is your random cat : ./super_cat.jpg
````

Vous pourrez trouver le script ici : [idcard.sh](idcard.sh)

## II. Script Youtube-dl. 

