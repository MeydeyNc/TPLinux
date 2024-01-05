# TP-2 Linux

## I. Service SSH 
#### 1. Analyse du Service

* Nous avons préparé notre VM en complétant la checklist. 
* Le service sshd est bien démarré : 
````
[mmederic@localhost ~]$ systemctl status sshd
 - sshd.service - OpenSSH server daemon
     Loaded: loaded (/usr/lib/systemd/system/sshd.service; enabled; vendor preset: enabled)
     Active: active (running) since Thu 2022-12-08 13:25:00 CET; 22min ago
````

* Voici ce que j'ai pu récupérer afin d'analyser les proccesus liés à sshd : 
````
[mmederic@localhost ~]$ ps -U root -u root u | grep ssh
root         723  0.0  1.2  16148  9576 ?        Ss   13:25   0:00 sshd: /usr/sbin/sshd -D [listener] 0 of 10-100 startups
root        1279  0.0  1.5  19384 11916 ?        Ss   13:30   0:00 sshd: mmederic [priv]
````
Nous avons deux lignes distinctes, une première notant un process en écoute "[listener]". Une deuxième ligne notant la connexion direct du ssh avec le username utilisé. (?). 

 * On détermine le port d'écoute du SSH : 
````
[mmederic@localhost ~]$ ss | grep ssh
tcp   ESTAB  0      52                        10.1.2.15:ssh           10.1.2.1:51602
````
On peut dire ici que le port d'écoute est le ssh ou 22. 

* Nous allons consulter les logs via la commande journalctl : 
````
[mmederic@localhost ~]$ journalctl | grep ssh
Dec 08 13:24:58 localhost systemd[1]: Created slice Slice /system/sshd-keygen.
Dec 08 13:24:59 localhost systemd[1]: Reached target sshd-keygen.target.
Dec 08 13:25:00 localhost sshd[723]: Server listening on 0.0.0.0 port 22.
Dec 08 13:25:00 localhost sshd[723]: Server listening on :: port 22.
Dec 08 13:29:59 localhost.localdomain sshd[1255]: Accepted password for mmederic from 10.1.2.1 port 51592 ssh2
Dec 08 13:29:59 localhost.localdomain sshd[1255]: pam_unix(sshd:session): session opened for user mmederic(uid=1000) by (uid=0)
Dec 08 13:30:03 localhost.localdomain sshd[1259]: Received disconnect from 10.1.2.1 port 51592:11: disconnected by user
Dec 08 13:30:03 localhost.localdomain sshd[1259]: Disconnected from user mmederic 10.1.2.1 port 51592
Dec 08 13:30:03 localhost.localdomain sshd[1255]: pam_unix(sshd:session): session closed for user mmederic
Dec 08 13:30:20 localhost.localdomain sshd[1279]: Accepted password for mmederic from 10.1.2.1 port 51602 ssh2
Dec 08 13:30:20 localhost.localdomain sshd[1279]: pam_unix(sshd:session): session opened for user mmederic(uid=1000) by (uid=0)
````

Petite remarque, dans la version actuellement utilisée de Rocky 9.0, nous ne trouverons pas le dossier journale dans le directory /var/log : 
````
[mmederic@localhost ~]$ cat /var/log/README
You are looking for the traditional text log files in /var/log, and they are
gone?

Here's an explanation on what's going on:

You are running a systemd-based OS where traditional syslog has been replaced
with the Journal. The journal stores the same (and more) information as classic
syslog. To make use of the journal and access the collected log data simply
invoke "journalctl", which will output the logs in the identical text-based
format the syslog files in /var/log used to be. For further details, please
refer to journalctl(1).

Alternatively, consider installing one of the traditional syslog
implementations available for your distribution, which will generate the
classic log files for you. Syslog implementations such as syslog-ng or rsyslog
may be installed side-by-side with the journal and will continue to function
the way they always did.

Thank you!
````
Nous resterons donc avec la commande journalctl. 

#### 2. Modification du service. 

 * On identifie le fichier de config du serveur SSH : 
````
[mmederic@localhost ~]$ cd /etc/ssh
[mmederic@localhost ssh]$ ls
moduli      ssh_config.d        ssh_host_ecdsa_key.pub  ssh_host_ed25519_key.pub  ssh_host_rsa_key.pub  sshd_config.d
ssh_config  ssh_host_ecdsa_key  ssh_host_ed25519_key    ssh_host_rsa_key          sshd_config
````
 * On modifiera alors le fichier sshd_config. 

Notre cmd $RANDOM nous offre le nombre : 
````
[mmederic@localhost ssh]$ echo $RANDOM
8472
````
C'est par celui-ci que nous allons remplacer l'iconique numéro 22 qui convient au Port ssh. 

 * Un sudo nano, puis un Cat pour voir les changements apportés : 
````
[mmederic@localhost ssh]$ sudo cat sshd_config | grep Port
#   Port 8472
````

 * On supprime l'ancien port 22 sur notre firewall : 
````
[mmederic@localhost ~]$ sudo firewall-cmd --list-all
public (active)
  target: default
  icmp-block-inversion: no
  interfaces: enp0s3 enp0s8
  sources:
  services: cockpit dhcpv6-client ssh
  ports: 22/tcp
  protocols:
  forward: yes
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:
[mmederic@localhost ~]$ sudo firewall-cmd --remove-port=22/tcp --permanent
success
````
On le remplace par le nouveau port : 
````
[mmederic@localhost ~]$ sudo firewall-cmd --add-port=8472/tcp --permanent
success
[mmederic@localhost ~]$ sudo firewall-cmd --reload
success
````
On recharge le tout pour faire en sorte que tout soit clair. 
Puis on vérifie : 
````
[mmederic@localhost ~]$ sudo firewall-cmd --list-all | grep 8472
  ports: 8472/tcp
````

 * On relance le service : 
````
[mmederic@localhost ssh]$ systemctl restart sshd
Failed to restart sshd.service: Access denied
See system logs and 'systemctl status sshd.service' for details.
[mmederic@localhost ssh]$ sudo !!
sudo systemctl restart sshd
````

 * On utilise cette commande pour se connecter par le nouveau Port : 
````
PS C:\Users\Initi> ssh mmederic@10.1.2.15 -p 8472
mmederic@10.1.2.15's password:
Last login: Thu Dec  8 20:01:25 2022 from 10.1.2.1
[mmederic@gaston ~]$
````

### II. Service HTTP 

#### 1. Mise en place. 

* On installe NGINX avec une simple petite commande : 
````
[mmederic@gaston ~]$ sudo dnf install nginx
````

* On démarre le service : 
````
[mmederic@gaston ~]$ sudo systemctl enable nginx
Created symlink /etc/systemd/system/multi-user.target.wants/nginx.service → /usr/lib/systemd/system/nginx.service.
[mmederic@gaston ~]$ sudo systemctl start nginx
````
* On détermine sur quel Port tourne nginx : 
````
[mmederic@gaston ~]$ ss -l -n | grep 511
tcp   LISTEN 0      511                                       0.0.0.0:80               0.0.0.0:*
tcp   LISTEN 0      511                                          [::]:80                  [::]:*
````
par défaut celui-ci tournera sur le 80. 

Nous avons évidemment ouvert le Port concerné : 
````
[mmederic@gaston ~]$ sudo firewall-cmd --list-all | grep ports
ports: 22/tcp 80/tcp
````

 * Processus lié à NGINX : 
````
[mmederic@gaston ~]$ ps -U root -u | grep nginx
root        2462  0.0  0.1  10084   956 ?        Ss   20:30   0:00 nginx: master process /usr/sbin/nginx
````
````
[mmederic@gaston ~]$ ps -e | grep nginx
   2462 ?        00:00:00 nginx
   2463 ?        00:00:00 nginx
   2464 ?        00:00:00 nginx
````
````
[mmederic@gaston ~]$ ps -efl | grep nginx
1 S root        2462       1  0  80   0 -  2521 -      20:30 ?        00:00:00 nginx: master process /usr/sbin/nginx
5 S nginx       2463    2462  0  80   0 -  3469 -      20:30 ?        00:00:00 nginx: worker process
5 S nginx       2464    2462  0  80   0 -  3469 -      20:30 ?        00:00:00 nginx: worker process
0 S mmederic    2609    2138  0  80   0 -   969 pipe_r 20:52 pts/0    00:00:00 grep --color=auto nginx
````
J'en ai mis plusieurs, ne sachant pas trop lequel serait le plus intéressant. Sur chacun j'ai essayé de chercher plus loin ou différemment. 


 * On utilise GitBash pour cette commande : 
````
$ curl http://10.1.2.15:80 | head -n 7
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  7620  100  7620    0     0  4216k      0 --:--:-- --:--:-- --:--:-- 7441k<!doctype html>
<html>
  <head>
    <meta charset='utf-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1'>
    <title>HTTP Server Test Page powered by: Rocky Linux</title>
    <style type="text/css">

````
Voici les 7 premières lignes du Server http. 

#### 2. Analyser la conf de NGINX

 * Nous avons ici le chemin vers le fichier de config de nginx : 
````
[mmederic@gaston nginx]$ ls -al /etc/nginx/nginx.conf
-rw-r--r--. 1 root root 2334 Oct 31 16:37 /etc/nginx/nginx.conf
````

 * Voici le premier Cat du fichier nginx.conf intéressant : 
````
[mmederic@gaston nginx]$ cat nginx.conf | grep server -A 10
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
--
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
````

Je n'ai pas très bien compris "la ligne qui parle d'inclure d'autres fichiers de conf", mais je pense avoir trouvé ceci : 
````
[mmederic@gaston nginx]$ cat nginx.conf | grep include  -A 3
include /usr/share/nginx/modules/*.conf;
````
La ligne include qui revient 2/3 fois dans le fichier. 
Je me suis dis que ça pourrait coller !

#### 3. Déployer un nouveau site web. 

 * Nous allons créer un site web ! 

Pour se faire nous créeons un sous-dossier pour y stocker notre index.html 

````
[mmederic@gaston nginx]$ cd /var
[mmederic@gaston var]$ mkdir www
mkdir: cannot create directory ‘www’: Permission denied
[mmederic@gaston var]$ sudo !!
sudo mkdir www
[sudo] password for mmederic:
[mmederic@gaston var]$ cd www/
[mmederic@gaston www]$ sudo mkdir tp2_linux
[mmederic@gaston www]$ ls
tp2_linux
[mmederic@gaston tp2_linux]$ touch index.html
touch: cannot touch 'index.html': Permission denied
[mmederic@gaston tp2_linux]$ sudo !!
sudo touch index.html
[mmederic@gaston tp2_linux]$ ls
index.html
````
Nous venons d'ajouter notre Headline h1 dans notre index.html. 
````
[mmederic@gaston tp2_linux]$ sudo nano index.html
````

 * Nous venons de supprimer le bloc server et de redémarrer nginx : 
````
[mmederic@gaston nginx]$ sudo nano nginx.conf
[sudo] password for mmederic:
[mmederic@gaston nginx]$ cd
[mmederic@gaston ~]$ sudo systemctl restart nginx
````

Le echo random :   
````
$ echo $RANDOM
11778
````

 * Voici notre magnifique curl : 
````
$ curl http://10.1.2.15:11778
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100    38  100    38    0     0  31122      0 --:--:-- --:--:-- --:--:-- 38000<h1>MEOW mon premier serveur web</h1>
````

### III. Your own services. 

#### 2. Analyse des services existants.

 * Je n'ai pas les process affichés dans ma commande pour sshd : 
````
[mmederic@gaston ~]$ systemctl status sshd
● sshd.service - OpenSSH server daemon
     Loaded: loaded (/usr/lib/systemd/system/sshd.service; enabled; vendor preset: enabled)
     Active: active (running) since Thu 2022-12-08 19:54:04 CET; 2h 29min ago
       Docs: man:sshd(8)
             man:sshd_config(5)
   Main PID: 1785 (sshd)
      Tasks: 1 (limit: 4636)
     Memory: 4.1M
        CPU: 433ms
     CGroup: /system.slice/sshd.service
             └─1785 "sshd: /usr/sbin/sshd -D [listener] 0 of 10-100 startups"
````

Cependant je les retrouve en utilisant une autre commande : 
````
[mmederic@gaston ~]$ ps -ef | grep sshd
root        1785       1  0 19:54 ?        00:00:00 sshd: /usr/sbin/sshd -D [listener] 0 of 10-100 startups
root        2133    1785  0 20:01 ?        00:00:00 sshd: mmederic [priv]
mmederic    2137    2133  0 20:01 ?        00:00:00 sshd: mmederic@pts/0
mmederic    3021    2138  0 22:27 pts/0    00:00:00 grep --color=auto sshd
````

Pour le service nginx : 
````
[mmederic@gaston ~]$ systemctl status nginx | grep ExecStart
    Process: 2950 ExecStart=/usr/sbin/nginx (code=exited, status=0/SUCCESS)
````

#### 3. Création de service. 

 * Nous avons créé le fichier et modifié celui-ci en conséquence : 
````
[mmederic@gaston ~]$ sudo nano /etc/systemd/system/tp2_nc.service
[mmederic@gaston ~]$ echo $RANDOM
2991
[mmederic@gaston ~]$ sudo nano /etc/systemd/system/tp2_nc.service
````
On y a ajouté la valeur random en tant que Port. 


 * On recharge les services : 
````
[mmederic@gaston ~]$ sudo systemctl daemon-reload
````

 * Nous venons de démarrer notre nouveau service : 
````
[mmederic@gaston ~]$ systemctl start tp2_nc.service
Failed to start tp2_nc.service: Access denied
See system logs and 'systemctl status tp2_nc.service' for details.
[mmederic@gaston ~]$ sudo !!
sudo systemctl start tp2_nc.service
[mmederic@gaston ~]$ sudo systemctl status tp2_nc.service
● tp2_nc.service - Super netcat de fou
     Loaded: loaded (/etc/systemd/system/tp2_nc.service; static)
     Active: active (running) since Thu 2022-12-08 22:41:47 CET; 8s ago
   Main PID: 3109 (nc)
      Tasks: 1 (limit: 4636)
     Memory: 1.1M
        CPU: 5ms
     CGroup: /system.slice/tp2_nc.service
             └─3109 /usr/bin/nc -l 2991

Dec 08 22:41:47 gaston systemd[1]: Started Super netcat de fou.
````

 * Nous avons trouvés notre service en fonction qui écoute : 
````
[mmederic@gaston ~]$ ss -lne | grep tp2
tcp   LISTEN 0      10                                        0.0.0.0:2991             0.0.0.0:*    ino:33426 sk:75 cgroup:/system.slice/tp2_nc.service <->

tcp   LISTEN 0      10                                           [::]:2991                [::]:*    ino:33425 sk:77 cgroup:/system.slice/tp2_nc.service v6only:1 <->
````

 * Ligne de démarrage du service : 
````
[mmederic@gaston ~]$ sudo journalctl -xe -u tp2_nc | grep Start
Dec 08 22:41:47 gaston systemd[1]: Started Super netcat de fou.
````

 * Ligne de dialogue : 
````
[mmederic@gaston ~]$ sudo journalctl -xe -u tp2_nc | grep Hello
Dec 08 22:56:01 gaston nc[3109]: Hello
````

 * Ligne d'arrêt de service : 
````
[mmederic@gaston ~]$ sudo journalctl -xe -u tp2_nc | grep Deac
Dec 08 22:56:59 gaston systemd[1]: tp2_nc.service: Deactivated successfully.
````

 * Nous venons de modifier le fichier : 
````
[mmederic@gaston ~]$ sudo nano /etc/systemd/system/tp2_nc.service
[mmederic@gaston ~]$ sudo systemctl restart tp2_nc.service
````


