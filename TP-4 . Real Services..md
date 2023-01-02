# TP-4 . Real Services. 

## Partie 1 : Partitionnement. 

 - On localise notre nouveau Disk : 
````
[mmederic@storage ~]$ lsblk
NAME        MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
sda           8:0    0    8G  0 disk
├─sda1        8:1    0    1G  0 part /boot
└─sda2        8:2    0    7G  0 part
  ├─rl-root 253:0    0  6.2G  0 lvm  /
  └─rl-swap 253:1    0  820M  0 lvm  [SWAP]
sdb           8:16   0    2G  0 disk
sr0          11:0    1 1024M  0 rom
````
 - On crée notre PV et on vérifie qu'il ait bien été créé : 
````
[mmederic@storage ~]$ sudo pvcreate /dev/sdb
[sudo] password for mmederic:
  Physical volume "/dev/sdb" successfully created.
[mmederic@storage ~]$ pvs
  WARNING: Running as a non-root user. Functionality may be unavailable.
  /run/lock/lvm/P_global:aux: open failed: Permission denied
[mmederic@storage ~]$ sudo !!
sudo pvs
  Devices file sys_wwid t10.ATA_____VBOX_HARDDISK___________________________VBc6cc6c1d-b91078a8_ PVID Izf4XPAd1T82xPLDFDcX3kQfOXTTTnbh last seen on /dev/sda2 not found.
  PV         VG Fmt  Attr PSize PFree
  /dev/sdb      lvm2 ---  2.00g 2.00g
````

 - On crée un VG et on le vérifie : 
````
[mmederic@storage ~]$ sudo vgcreate datastorage /dev/sdb
  Volume group "datastorage" successfully created
[mmederic@storage ~]$ sudo vgs
  Devices file sys_wwid t10.ATA_____VBOX_HARDDISK___________________________VBc6cc6c1d-b91078a8_ PVID Izf4XPAd1T82xPLDFDcX3kQfOXTTTnbh last seen on /dev/sda2 not found.
  VG          #PV #LV #SN Attr   VSize  VFree
  datastorage   1   0   0 wz--n- <2.00g <2.00g
````

 - On s'occupe du LV et on vérifie : 
````
[mmederic@storage ~]$ sudo lvcreate -l 100%FREE datastorage -n tp4
  Logical volume "tp4" created.
[mmederic@storage ~]$ sudo lvs
  Devices file sys_wwid t10.ATA_____VBOX_HARDDISK___________________________VBc6cc6c1d-b91078a8_ PVID Izf4XPAd1T82xPLDFDcX3kQfOXTTTnbh last seen on /dev/sda2 not found.
  LV   VG          Attr       LSize  Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
  tp4  datastorage -wi-a----- <2.00g
````

 - On va formater notre partition : 
````
[mmederic@storage ~]$ mkfs -t ext4 /dev/datastorage/tp4
mke2fs 1.46.5 (30-Dec-2021)
mkfs.ext4: Permission denied while trying to determine filesystem size
[mmederic@storage ~]$ sudo !!
sudo mkfs -t ext4 /dev/datastorage/tp4
mke2fs 1.46.5 (30-Dec-2021)
Creating filesystem with 523264 4k blocks and 130816 inodes
Filesystem UUID: b56eb620-e531-4a1f-ad6c-5368845652bc
Superblock backups stored on blocks:
        32768, 98304, 163840, 229376, 294912

Allocating group tables: done
Writing inode tables: done
Creating journal (8192 blocks): done
Writing superblocks and filesystem accounting information: done
````

 - On vérifie : 
````
[mmederic@storage ~]$ sudo lvdisplay
  Devices file sys_wwid t10.ATA_____VBOX_HARDDISK___________________________VBc6cc6c1d-b91078a8_ PVID Izf4XPAd1T82xPLDFDcX3kQfOXTTTnbh last seen on /dev/sda2 not found.
  --- Logical volume ---
  LV Path                /dev/datastorage/tp4
  LV Name                tp4
  VG Name                datastorage
  LV UUID                LClJFu-qw32-LV7F-ZjOe-K3Rc-OzVq-rBMfWT
  LV Write Access        read/write
  LV Creation host, time storage, 2022-12-13 11:29:36 +0100
  LV Status              available
  # open                 0
  LV Size                <2.00 GiB
  Current LE             511
  Segments               1
  Allocation             inherit
  Read ahead sectors     auto
  - currently set to     256
  Block device           253:2
````

 - Maintenant on monte la partition : 
````
[mmederic@storage ~]$ sudo mount /dev/datastorage/tp4 /mnt/storage/
````
 - On vérifie : 
````
[mmederic@storage ~]$ df -h | tail -n 1
/dev/mapper/datastorage-tp4  2.0G   24K  1.9G   1% /mnt/storage
````

 - On essaie de créer un fichier dans la partition : 
````
[mmederic@storage ~]$ ls /mnt/storage/
lost+found  yeet
````

 - Notre fichier fstab : 
````
[mmederic@storage ~]$ sudo cat /etc/fstab | tail -n 1
/dev/mapper/datastorage-tp4     /mnt/storage/           ext4    defaults        0 0
````

## Partie 2 : Serveur de partage de fichiers. 

 * Les commandes réalisées sur le serveur: 
````    
[mmederic@storage ~]$ cat /etc/exports
/var/nfs/general        10.1.2.11(rw,sync,no_subtree_check)
/home                   10.1.2.11(rw,sync,no_root_squash,no_subtree_check)
````

 * Les commandes réalisées sur le client : 
````
[mmederic@web ~]$ cat /etc/fstab

#
# /etc/fstab
# Created by anaconda on Thu Dec  8 11:27:32 2022
#
# Accessible filesystems, by reference, are maintained under '/dev/disk/'.
# See man pages fstab(5), findfs(8), mount(8) and/or blkid(8) for more info.
#
# After editing this file, run 'systemctl daemon-reload' to update systemd
# units generated from this file.
#
/dev/mapper/rl-root     /                       xfs     defaults        0 0
UUID=96d55648-53b7-4799-a5ae-8765c493feb7 /boot                   xfs     defaults        0 0
/dev/mapper/rl-swap     none                    swap    defaults        0 0
10.1.2.10:/var/nfs/general      /nfs/general    nfs auto,nofail,noatime,nolock,intr,tcp,actimeo=1800 0 0
10.1.2.10:/home                 /nfs/home       nfs auto,nofail,noatime,nolock,intr,tcp,actimeo=1800 0 0
````

## Partie 3 : Serveur web. 

### 2. NGINX Install. 

 * On installe NGINX : 
```` 
[mmederic@web ~]$ sudo dnf install nginx
Installed:
  nginx-1:1.20.1-13.el9.x86_64    nginx-core-1:1.20.1-13.el9.x86_64    nginx-filesystem-1:1.20.1-13.el9.noarch    rocky-logos-httpd-90.13-1.el9.noarch

Complete!
````
 ### 3. Analyse. 

 * Ici on peut voir que le service nginx tourne sous root. Le PPID étant le 4377 sous UID root.

````
[mmederic@web ~]$ ps -eFly | grep nginx
S root        4377       1  0  80   0   956  2521 -        1 17:51 ?        00:00:00 nginx: master process /usr/sbin/nginx
S nginx       4378    4377  0  80   0  4988  3469 -        0 17:51 ?        00:00:00 nginx: worker process
S nginx       4379    4377  0  80   0  4988  3469 -        1 17:51 ?        00:00:00 nginx: worker process
````
 
 * Nous pouvons voir le port d'écoute actuel : 

````
[mmederic@web ~]$ ss -latpu | grep nfs
tcp   LISTEN 0      64              0.0.0.0:nfs         0.0.0.0:*
tcp   ESTAB  0      0             10.1.2.11:nmap      10.1.2.10:nfs
tcp   LISTEN 0      64                 [::]:nfs            [::]:*
[mmederic@web ~]$ ss -lantpu | grep 80
tcp   LISTEN 0      511             0.0.0.0:80         0.0.0.0:*
tcp   LISTEN 0      511                [::]:80            [::]:*
````

 * Localisation de la racine du dossier web :
````
[mmederic@web ~]$ cat /etc/nginx/nginx.conf | grep root
        root         /usr/share/nginx/html;
````

Nous avons également bien les autorisations de lecture sur les fichiers concernés : 
````
[mmederic@web ~]$ ls -l /etc/nginx/ | grep nginx
-rw-r--r--. 1 root root 2334 Oct 31 16:37 nginx.conf
-rw-r--r--. 1 root root 2656 Oct 31 16:37 nginx.conf.default
````

### 4. Visite du service web. 

 * Nous allons donc permettre l'accès à ce port : 
````
[mmederic@web ~]$ ss -lantpu | grep 80
tcp   LISTEN 0      511             0.0.0.0:80         0.0.0.0:*
tcp   LISTEN 0      511                [::]:80            [::]:*
````
Nous venons ainsi de le faire et on vérifie avec ces commandes-ci : 
````
[mmederic@web ~]$ sudo firewall-cmd --add-port=80/tcp --permanent
success
[mmederic@web ~]$ sudo firewall-cmd --list-all
public (active)
  target: default
  icmp-block-inversion: no
  interfaces: enp0s3 enp0s8
  sources:
  services: cockpit dhcpv6-client http ssh
  ports: 80/tcp
  protocols:
  forward: yes
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:
  ````

 * Nous avons pu curl : 
 ````
 $ curl 10.1.2.11:80
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0<!doctype html>

````

 * Nous vérifions les logs d'accès : 
 ````
 [mmederic@web ~]$ sudo tail -n 3 /var/log/nginx/access.log
10.1.2.1 - - [02/Jan/2023:10:47:25 +0100] "GET / HTTP/1.1" 200 7620 "-" "Mozilla/5.0 (Windows NT; Windows NT 10.0; fr-FR) WindowsPowerShell/5.1.19041.2364" "-"
10.1.2.1 - - [02/Jan/2023:10:49:48 +0100] "GET / HTTP/1.1" 200 7620 "-" "Mozilla/5.0 (Windows NT; Windows NT 10.0; fr-FR) WindowsPowerShell/5.1.19041.2364" "-"
10.1.2.1 - - [02/Jan/2023:10:51:08 +0100] "GET / HTTP/1.1" 200 7620 "-" "curl/7.85.0" "-"
````

### 5. Modif de la conf du serveur web 

Nous modifions donc le port d'écoute de nginx et nous vérifions : 
````
[mmederic@web ~]$ sudo nano /etc/nginx/nginx.conf
[mmederic@web ~]$ systemctl restart nginx
Failed to restart nginx.service: Access denied
See system logs and 'systemctl status nginx.service' for details.
[mmederic@web ~]$ sudo !!
sudo systemctl restart nginx
[mmederic@web ~]$ sudo systemctl status nginx
● nginx.service - The nginx HTTP and reverse proxy server
     Loaded: loaded (/usr/lib/systemd/system/nginx.service; enabled; vendor preset: disabled)
     Active: active (running) since Mon 2023-01-02 11:05:26 CET; 6s ago
    Process: 2001 ExecStartPre=/usr/bin/rm -f /run/nginx.pid (code=exited, status=0/SUCCESS)
    Process: 2002 ExecStartPre=/usr/sbin/nginx -t (code=exited, status=0/SUCCESS)
    Process: 2003 ExecStart=/usr/sbin/nginx (code=exited, status=0/SUCCESS)
   Main PID: 2004 (nginx)
      Tasks: 3 (limit: 4636)
     Memory: 2.8M
        CPU: 30ms
     CGroup: /system.slice/nginx.service
             ├─2004 "nginx: master process /usr/sbin/nginx"
             ├─2005 "nginx: worker process"
             └─2006 "nginx: worker process"

Jan 02 11:05:25 web systemd[1]: Starting The nginx HTTP and reverse proxy server...
Jan 02 11:05:26 web nginx[2002]: nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
Jan 02 11:05:26 web nginx[2002]: nginx: configuration file /etc/nginx/nginx.conf test is successful
Jan 02 11:05:26 web systemd[1]: Started The nginx HTTP and reverse proxy server.
````
 * Le changement a bien pris effet : 
 ````
 [mmederic@web ~]$ sudo ss -lnatpu | grep 8080
tcp   LISTEN 0      511             0.0.0.0:8080       0.0.0.0:*     users:(("nginx",pid=2006,fd=6),("nginx",pid=2005,fd=6),("nginx",pid=2004,fd=6))
tcp   LISTEN 0      511                [::]:8080          [::]:*     users:(("nginx",pid=2006,fd=7),("nginx",pid=2005,fd=7),("nginx",pid=2004,fd=7))
````
 
 * On ferme l'ancien port et ouvre le nouveau et on verifie : 
````
[mmederic@web ~]$ sudo firewall-cmd --remove-port=80/tcp --permanent
success
[mmederic@web ~]$ sudo firewall-cmd --add-port=8080/tcp --permanent
success
[mmederic@web ~]$ sudo firewall-cmd --reload
success
[mmederic@web ~]$ sudo firewall-cmd --list-all
public (active)
  target: default
  icmp-block-inversion: no
  interfaces: enp0s3 enp0s8
  sources:
  services: cockpit dhcpv6-client http ssh
  ports: 8080/tcp
  protocols:
  forward: yes
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:
  ````

* Le changement fonctionne, nous pouvons curl : 
````
$ curl 10.1.2.11:8080
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0<!doctype html>
````

* Nous créons un nouvel utilisateur : 
````
[mmederic@web ~]$ useradd michel -s /bin/sh -u 6969 -d /home/web -p root
useradd: Permission denied.
useradd: cannot lock /etc/passwd; try again later.
[mmederic@web ~]$ sudo !!
sudo sudo useradd michel -s /bin/sh -u 6969 -d /home/web -p root
````

* On modifie l'utilisateur de nginx : 
````
[mmederic@web ~]$ sudo vim /etc/nginx/nginx.conf
 84L, 2339B written
[mmederic@web ~]$ cat /etc/nginx/nginx.conf | grep user
user michel;
````

* C'est bien notre nouvel utilisateur qui est sur nginx : 
````
[mmederic@web ~]$ sudo ps -eFly | grep nginx
S root        2132       1  0  80   0   952  2521 sigsus   0 11:30 ?        00:00:00 nginx: master process /usr/sbin/nginx
S michel      2133    2132  0  80   0  4808  3469 ep_pol   0 11:30 ?        00:00:00 nginx: worker process
S michel      2134    2132  0  80   0  4808  3469 ep_pol   1 11:30 ?        00:00:00 nginx: worker process
S mmederic    2138    1273  0  80   0  1972   969 pipe_r   0 11:30 pts/0    00:00:00 grep --color=auto nginx
````
* Nous venons de créer notre nouvel index.html bidon. On remplace la racine web : 
````
[mmederic@web ~]$ cat /etc/nginx/nginx.conf | grep root
        root         /var/www/site_web_1/;
````

* La modification a bien pris effet : 
````
$ curl 10.1.2.11:8080
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100    17  100    17    0     0  12292      0 --:--:-- --:--:-- --:--:-- 17000

LET'S GOOOOOO
````

### 6. Deux sites web sur un seul serveur. 

* Nous venons de repérer la ligne qui nous intéresse pour le fichier conf.d : 
````
[mmederic@web ~]$ cat /etc/nginx/nginx.conf | grep conf.d
    # Load modular configuration files from the /etc/nginx/conf.d directory.
    include /etc/nginx/conf.d/*.conf;
````

* Nous avons bien nos 2 fichiers dans le conf.d : 
````
[mmederic@web ~]$ ls /etc/nginx/conf.d/
site_web_1.conf  site_web_2.conf
````

* Nous avons bien modifié la racine web du deuxième fichier : 
````
[mmederic@web ~]$ cat /etc/nginx/conf.d/site_web_2.conf | grep root
        root         /var/www/site_web_2/;
````
* Ajoutez les ports d'écoutes : 
````
[mmederic@web ~]$ cat /etc/nginx/conf.d/site_web_2.conf | grep listen
        listen       8888;
        listen       [::]:8888;
````
* Et nous l'avons autorisé sur le pare-feu : 
````
[mmederic@web ~]$ sudo firewall-cmd --add-port=8888/tcp --permanent
success
[mmederic@web ~]$ sudo firewall-cmd --reload
success
[mmederic@web ~]$ sudo firewall-cmd --list-all
public (active)
  target: default
  icmp-block-inversion: no
  interfaces: enp0s3 enp0s8
  sources:
  services: cockpit dhcpv6-client http ssh
  ports: 8080/tcp 8888/tcp
  protocols:
  forward: yes
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:
````

* Nous avons pris la liberté de modifier le fichier html du deuxième site web : 
````
[mmederic@web ~]$ sudo vim /var/www/site_web_2/index.html
````

* Nous pouvons curl les deux sites : 
````
Initi@DESKTOP-IM5I5BK MINGW64 ~
$ curl 10.1.2.11:8080
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100    17  100    17    0     0  10793      0 --:--:-- --:--:-- --:--:-- 17000

LET'S GOOOOOO


Initi@DESKTOP-IM5I5BK MINGW64 ~
$ curl 10.1.2.11:8888
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100    14  100    14    0     0   3835      0 --:--:-- --:--:-- --:--:--  4666

LET'S GOO 2
````
