# Travail autour de la solution NextCloud. 

## Module 1. Reverse Proxy. 

### 1. Setup. 

 On installe nginx : 
````
[mmederic@proxy ~]$ sudo dnf install nginx
Installed:
  nginx-1:1.20.1-13.el9.x86_64    nginx-core-1:1.20.1-13.el9.x86_64    nginx-filesystem-1:1.20.1-13.el9.noarch    rocky-logos-httpd-90.13-1.el9.noarch

Complete!
````

On lance le service : 
````
[mmederic@proxy ~]$ sudo systemctl enable nginx
Created symlink /etc/systemd/system/multi-user.target.wants/nginx.service → /usr/lib/systemd/system/nginx.service.
[mmederic@proxy ~]$ sudo systemctl start nginx
[mmederic@proxy ~]$ sudo systemctl is-enabled nginx
enabled
[mmederic@proxy ~]$ sudo systemctl status nginx
● nginx.service - The nginx HTTP and reverse proxy server
     Loaded: loaded (/usr/lib/systemd/system/nginx.service; enabled; vendor preset: disabled)
     Active: active (running) since Tue 2023-01-17 14:28:43 CET; 20s ago
````


On localise le port d'écoute de nginx : 
````
[mmederic@proxy ~]$ sudo ss -lntapu | grep nginx
tcp   LISTEN 0      511             0.0.0.0:80        0.0.0.0:*     users:(("nginx",pid=1679,fd=6),("nginx",pid=1678,fd=6),("nginx",pid=1677,fd=6))
tcp   LISTEN 0      511                [::]:80           [::]:*     users:(("nginx",pid=1679,fd=7),("nginx",pid=1678,fd=7),("nginx",pid=1677,fd=7))
````

On ouvre le port 80 pour nginx, on relance et on vérifie : 
````
[mmederic@proxy ~]$ sudo firewall-cmd --add-port=80/tcp --permanent
success
[mmederic@proxy ~]$ sudo firewall-cmd --reload
success
[mmederic@proxy ~]$ sudo firewall-cmd --list-all
public (active)
  target: default
  icmp-block-inversion: no
  interfaces: enp0s3 enp0s8
  sources:
  services: cockpit dhcpv6-client ssh
  ports: 80/tcp
  protocols:
  forward: yes
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:
````

On détermine l'utilisateur de nginx : 
````
[mmederic@proxy ~]$ sudo ps -ef | grep nginx
root        1677       1  0 14:28 ?        00:00:00 nginx: master process /usr/sbin/nginx
nginx       1678    1677  0 14:28 ?        00:00:00 nginx: worker process
nginx       1679    1677  0 14:28 ?        00:00:00 nginx: worker process
````

On curl grâce à gitbash : 
````
Initi@DESKTOP-IM5I5BK MINGW64 ~
$ curl 10.105.1.13:80
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0<!doctype html>
<html>
  <head>
    <meta charset='utf-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1'>
    <title>HTTP Server Test Page powered by: Rocky Linux</title>
````
Nous avons aussi vérifié l'accès de la page web sur navigateur. 


 * On va configurer NGINX : 
````
[mmederic@web ~]$ sudo cat /var/www/tp5_nextcloud/config/config.php
[sudo] password for mmederic:
<?php
$CONFIG = array (
  'instanceid' => 'occttztu9i23',
  'passwordsalt' => 'SmLA8qNUDIJ1EQaYUSUPwu874vOngj',
  'secret' => 'gC82lWkYaozAy9eTt8QELA69WM+dZByk597RzjNujjduFM66',
  'trusted_domains' =>
  array (
    0 => '10.105.1.11', 1 => '10.105.1.13'
  ),
````

* On crée notre fichier proxy dans la conf de nginx : 
````
[mmederic@proxy conf.d]$ sudo vim proxy.conf

[mmederic@proxy conf.d]$ sudo cat proxy.conf
[sudo] password for mmederic:
server {
    # On indique le nom que client va saisir pour accéder au service
    # Pas d'erreur ici, c'est bien le nom de web, et pas de proxy qu'on veut ici !
    server_name www.nextcloud.tp6;

    # Port d'écoute de NGINX
    listen 80;

    location / {
        # On définit des headers HTTP pour que le proxying se passe bien
        proxy_set_header  Host $host;
        proxy_set_header  X-Real-IP $remote_addr;
        proxy_set_header  X-Forwarded-Proto https;
        proxy_set_header  X-Forwarded-Host $remote_addr;
        proxy_set_header  X-Forwarded-For $proxy_add_x_forwarded_for;

        # On définit la cible du proxying
        proxy_pass http://10.105.1.11:80;
    }

    # Deux sections location recommandés par la doc NextCloud
    location /.well-known/carddav {
      return 301 $scheme://$host/remote.php/dav;
    }

    location /.well-known/caldav {
      return 301 $scheme://$host/remote.php/dav;
    }
}
````

 Voici la ligne que nous ajoutons dans notre fichier hosts sur windows :
````
	10.105.1.13	www.nextcloud.tp6	#VMTP6LinuxLeoProxy
````

 On va utiliser une commande pour autoriser les connexions depuis le proxy : 
````
[mmederic@web ~]$ sudo firewall-cmd --permanent --add-rich-rule=rule family=ipv4 source address=10.105.1.13 accept 
````
On va ensuite bloquer tous les pings vers web. : 
````
sudo firewall-cmd --add-rich-rule='rule protocol value=icmp reject'
[sudo] password for mmederic:
success
[mmederic@web ~]$ sudo firewall-cmd --list-all
public (active)
  target: default
  icmp-block-inversion: no
  interfaces: enp0s3 enp0s8
  sources:
  services: cockpit dhcpv6-client http https ssh
  ports: 3306/tcp
  protocols:
  forward: yes
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:
        rule family="ipv4" source address="10.105.1.13" accept
        rule protocol value="icmp" reject
````

On essaie : 
```` 
PS C:\Users\Initi> ping 10.105.1.11

Envoi d’une requête 'Ping'  10.105.1.11 avec 32 octets de données :
Réponse de 10.105.1.11 : Impossible de joindre le port de destination.
Réponse de 10.105.1.11 : Impossible de joindre le port de destination.
Réponse de 10.105.1.11 : Impossible de joindre le port de destination.
Réponse de 10.105.1.11 : Impossible de joindre le port de destination.

Statistiques Ping pour 10.105.1.11:
    Paquets : envoyés = 4, reçus = 4, perdus = 0 (perte 0%),
````

On essaie sur proxy : 
````
PS C:\Users\Initi> ping 10.105.1.13

Envoi d’une requête 'Ping'  10.105.1.13 avec 32 octets de données :
Réponse de 10.105.1.13 : octets=32 temps<1ms TTL=64
Réponse de 10.105.1.13 : octets=32 temps<1ms TTL=64
Réponse de 10.105.1.13 : octets=32 temps<1ms TTL=64
Réponse de 10.105.1.13 : octets=32 temps<1ms TTL=64
````

## II. HTTPS 

````
[mmederic@proxy certificats]$ sudo openssl genrsa -out ssl_certificate.key 2048
[mmederic@proxy certificats]$ sudo openssl req -new -x509 -key ssl_certificate.key -out ssl_certificate.crt -days 365
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Country Name (2 letter code) [XX]:fr
State or Province Name (full name) []:NA
Locality Name (eg, city) [Default City]:Brdx
Organization Name (eg, company) [Default Company Ltd]:Ynov
Organizational Unit Name (eg, section) []:BA
Common Name (eg, your name or your server's hostname) []:Web
Email Address []:.
[mmederic@proxy certificats]$ ls
ssl_certificate.crt  ssl_certificate.key
````

Voici un cat de notre fichier nginx.conf : 
````
    server {
        listen       80;
        server_name  web.tp6.linux;
        return 301 https://$host$request_uri;
    }

# Settings for a TLS enabled server.

    server {
       listen       443 ssl http2;
       listen       [::]:443 ssl http2;
       server_name  web.tp6.linux;
       root         /usr/share/nginx/html;

       ssl_certificate "/etc/nginx/certs/ssl_certificate.crt";
       ssl_certificate_key "/etc/nginx/certs/ssl_certificate.key";

       location / {
        proxy_set_header  Host $host;
        proxy_set_header  X-Real-IP $remote_addr;
        proxy_set_header  X-Forwarded-Proto https;
        proxy_set_header  X-Forwarded-Host $remote_addr;
        proxy_set_header  X-Forwarded-For $proxy_add_x_forwarded_for;

        proxy_pass http://10.105.1.13:80;

       }

        location /.well-known/carddav {
        return 301 $scheme://$host/remote.php/dav;
    }

        location /.well-known/caldav {
        return 301 $scheme://$host/remote.php/dav;
    }
````
On s'assure ensuite de bien ouvrir le port 443 : 
````
[mmederic@proxy nginx]$ sudo firewall-cmd --add-port=443/tcp --permanent
success
[mmederic@proxy nginx]$ sudo firewall-cmd --reload
success
[mmederic@proxy nginx]$ sudo firewall-cmd --list-all
public (active)
  target: default
  icmp-block-inversion: no
  interfaces: enp0s3 enp0s8
  sources:
  services: cockpit dhcpv6-client ssh
  ports: 80/tcp 443/tcp
  protocols:
  forward: yes
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:
````

voici ce que nous avons quand on curl depuis git bash : 
````
$ curl https://www.nextcloud.tp6
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
curl: (60) SSL certificate problem: self signed certificate
More details here: https://curl.se/docs/sslcerts.html

curl failed to verify the legitimacy of the server and therefore could not
establish a secure connection to it. To learn more about this situation and
how to fix it, please visit the web page mentioned above.
````


# Backup du Serveur. 

## 1. Script de Backup. 

On vient de créer un script. 

Script en question : [tp6_backup.sh]($tp6_backup.sh)

voici un cat de notre script : 
````
#!/bin/bash

#This a script written by Mederic MARQUIE from B1A Ynov in Bordeaux.

# The goal of this script is to create a backup save for our nextcloud solution.


Maintenance_Mode_on="$(sudo -u mmederic php occ maintenance:mode --on) Going Maintenance Mode"
Maintenance_Mode_off="$(sudo -u mmederic php occ maintenance:mode --off) Going Live Mode"
Backup_folders="$(sudo rsync -Aavx /srv/ nextcloud-dirbkp_`date +"%Y%m%d"`.zip/) Creating backup folders. . ."
Data_folders="$(sudo mysqldump --single-transaction --skip-column-statistics -h 10.105.1.12 -u nextcloud -p > nextcloud-sqlbkp_`date +"%Y%m%d"`.bak)"
Move_backup_folders="$(sudo mv nextcloud* /srv/)"


echo "Launching Backup Procedure..."

echo ${Maintenance_Mode_on}

echo ${Backup_folders}

echo ${Data_folders}

echo ${Move_Data_folders}

echo ${Maintenance_Mode_off}

echo "Backup Process done."
````

On crée un user pour la suite : 
````
[mmederic@web ~]$ sudo useradd backup -d /srv/backup/ -s /usr/bin/nologin
useradd: Warning: missing or non-executable shell '/usr/bin/nologin'
useradd: warning: the home directory /srv/backup/ already exists.
useradd: Not copying any file from skel directory into it.
[mmederic@web ~]$ sudo chown backup /srv/backup/
[mmederic@web ~]$ cd /srv/
[mmederic@web srv]$ ls -al
total 8
drwxr-xr-x.  4 root     root     115 Feb  6 18:43 .
dr-xr-xr-x. 18 root     root     235 Dec  8 12:27 ..
drwxr-xr-x.  2 backup   root       6 Jan 31 14:07 backup
````


## 3. Créer un service. 

On crée un service : 
````
[mmederic@web system]$ sudo cat backup.service
[Unit]
Description=Backup service

[Service]
ExecStart=sh /srv/tp6_backup.sh
User=backup
Type=oneshot
````

Nous créons ensuite le timer pour le service correspondant : 
````
[mmederic@web system]$ cat backup.timer
[Unit]
Description=Run service X

[Timer]
OnCalendar=*-*-* 4:00:00

[Install]
WantedBy=timers.target
````

On active l'utilisation du timer : 
````
[mmederic@web system]$ sudo systemctl daemon-reload
[mmederic@web system]$ sudo systemctl start backup.timer
[mmederic@web system]$ sudo systemctl enable backup.timer
Created symlink /etc/systemd/system/timers.target.wants/backup.timer → /etc/systemd/system/backup.timer.
[mmederic@web system]$ sudo systemctl status backup.timer
● backup.timer - Run service X
     Loaded: loaded (/etc/systemd/system/backup.timer; enabled; vendor preset: disabled)
     Active: active (waiting) since Fri 2023-02-10 11:23:25 CET; 15s ago
      Until: Fri 2023-02-10 11:23:25 CET; 15s ago
    Trigger: Sat 2023-02-11 04:00:00 CET; 16h left
   Triggers: ● backup.service

Feb 10 11:23:25 web.tp5 systemd[1]: Started Run service X.
[mmederic@web system]$ sudo systemctl list-timers
NEXT                        LEFT          LAST                        PASSED       UNIT                         ACTIVATES
Fri 2023-02-10 11:27:36 CET 3min 41s left n/a                         n/a          systemd-tmpfiles-clean.timer systemd-tmpfiles-clean.service
Fri 2023-02-10 11:38:21 CET 14min left    n/a                         n/a          dnf-makecache.timer          dnf-makecache.service
Sat 2023-02-11 00:00:00 CET 12h left      Fri 2023-02-10 09:12:21 CET 2h 11min ago logrotate.timer              logrotate.service
Sat 2023-02-11 04:00:00 CET 16h left      n/a                         n/a          backup.timer                 backup.service

4 timers listed.
Pass --all to see loaded but inactive timers, too.
````

## II. NFS

### 1. Serveur NFS. 

Nous venons de créer notre VM. 

On crée ensuite nos fichiers qui vont être partagés. 
````
[mmederic@storage ~]$ sudo mkdir /srv/nfs_shares
[sudo] password for mmederic:
[mmederic@storage ~]$ sudo mkdir /srv/nfs_shares/web.tp6.linux
````

On change l'ownerhip de nos fichiers pour permettre à l'autre vm de les manipuler aussi. 
````
[mmederic@storage srv]$ chown nobody /srv/nfs_shares/web.tp6.linux/
chown: changing ownership of '/srv/nfs_shares/web.tp6.linux/': Operation not permitted
[mmederic@storage srv]$ sudo !!
sudo chown nobody /srv/nfs_shares/web.tp6.linux/
````

Notre fichier exports : 
````
[mmederic@storage srv]$ cat /etc/exports
/srv/nfs_shares/web.tp6.linux   10.105.1.11(rw,sync,no_subtree_check)
/home                           10.105.1.11(rw,sync,no_root_squash,no_subtree_check)
````

On mount nos fichiers de partage.

````
[mmederic@web system]$ sudo mount 10.105.1.11:/srv/nfs_shares/web.tp6.linux/ /nfs/genral/
[mmederic@web system]$ df -h | grep tp6
10.105.1.14:/srv/nfs_shares/web.tp6.linux  5.6G  1.2G  4.5G  21% /srv/backup
````
### 2. Client NFS.

````
[mmederic@web ~]$ sudo cat /etc/fstab | grep tp6
10.105.1.14:/srv/nfs_shares/web.tp6.linux /nfs/general nfs auto,nofail,noatime,nolock,intr,tcp,actimeo=1800 0 0
````

On test la restauration des données :

````
[mmederic@web backup]$ sudo unzip nextcloud-dirbkp_20230117.zip
````
````
[mmederic@web nextcloud-dirbkp_20230117]$ sudo mv nextcloud-sqlbkp_20230117.bak /srv/backup/
[mmederic@web backup]$ sudo mv nextcloud-dirbkp_20230117/ /srv/backup/
````
````
[mmederic@web backup]$ sudo rsync -Aax nextcloud-dirbkp_20230117 nextcloud/
````
````
[mmederic@web backup]$ mysql -h 10.105.1.12 -u nextcloud -p nuagesuivant -e "DROP DATABASE nextcloud"
mysql: [Warning] Using a password on the command line interface can be insecure.
[mmederic@web backup]$ mysql -h 10.105.1.12 -u nextcloud -p nuagesuivant -e "CREATE DATABASE nextcloud"
mysql: [Warning] Using a password on the command line interface can be insecure.
[mmederic@web backup]$ mysql -h 10.105.1.12 -u nextcloud -p nuagesuivant nextcloud < nextcloud-sqlbkp_20230117.bak 
mysql: [Warning] Using a password on the command line interface can be insecure.
````


# 3. Fail2ban 

