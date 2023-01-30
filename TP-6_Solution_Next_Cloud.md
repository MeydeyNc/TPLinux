# Travail autour de la solution NextCloud. 

## Module 1. Reverse Proxy. 

### 1. Setup. 

* On installe nginx : 
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

* Voici la ligne que nous ajoutons dans notre fichier hosts sur windows :
````
	10.105.1.13	www.nextcloud.tp6	#VMTP6LinuxLeoProxy
````

* On va utiliser une commande pour autoriser les connexions depuis le proxy : 
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


