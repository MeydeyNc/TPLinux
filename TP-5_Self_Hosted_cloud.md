# TP-5 : Self-Hosted Cloud. 

## Partie 1 : Mise en place du serveur web. 

### 1. Installation. 

 * On lance l'installation d'Apache : 
 ````
 [mmederic@web ~]$ sudo dnf install httpd -y
 ````

Nous venons de supprimer les commentaires dans le fichier de conf : 

````
[mmederic@web ~]$ cat /etc/httpd/conf/httpd.conf

ServerRoot "/etc/httpd"

Listen 80

Include conf.modules.d/*.conf

User apache
Group apache


ServerAdmin root@localhost
````

* Nous avons pu déterminer qu'Apache se lance bien au boot : 
````
[mmederic@web ~]$ sudo systemctl is-enabled httpd
enabled
````

Apache est bien lancé et en service : 
````
[mmederic@web ~]$ systemctl status httpd
● httpd.service - The Apache HTTP Server
     Loaded: loaded (/usr/lib/systemd/system/httpd.service; enabled; vendor preset: disabled)
     Active: active (running) since Tue 2023-01-03 15:08:19 CET; 21min ago
````

Apache est sur le port 80 : 
````
[mmederic@web ~]$ sudo ss -lantpu | grep httpd
tcp   LISTEN 0      511                   *:80              *:*     users:(("httpd",pid=1974,fd=4),("httpd",pid=1973,fd=4),("httpd",pid=1972,fd=4),("httpd",pid=1969,fd=4))
````

 * Le service fonctionne bien : 
````
Initi@DESKTOP-IM5I5BK MINGW64 ~
$ curl 10.105.1.11
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0<!doctype html>
<html>
  <head>
    <meta charset='utf-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1'>
    <title>HTTP Server Test Page powered by: Rocky Linux</title>
````

### 2. Maîtrise du service. 

* Le contenu du fichier httpd.service : 
````
[mmederic@web ~]$ systemctl cat httpd
# /usr/lib/systemd/system/httpd.service
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
````

* Dans le fichier httpd.conf, on détermine le user : 
````
[mmederic@web ~]$ cat /etc/httpd/conf/httpd.conf | grep user
[mmederic@web ~]$ cat /etc/httpd/conf/httpd.conf | grep User
User apache
````
Puis on utilise la commande ps : 
````
[mmederic@web ~]$ ps -ef | grep apache
apache      1971    1969  0 15:08 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
apache      1972    1969  0 15:08 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
apache      1973    1969  0 15:08 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
apache      1974    1969  0 15:08 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
````
Le serveur tourne bien sous le user Apache, mais celui la meme tourne aussi sous root. En effet, si on suit le PPID, on tombe sur root : 
````
[mmederic@web ~]$ ps -ef | grep apache
apache      1971    1969  0 15:08 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
apache      1972    1969  0 15:08 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
apache      1973    1969  0 15:08 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
apache      1974    1969  0 15:08 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
mmederic    2385    1330  0 16:45 pts/0    00:00:00 grep --color=auto apache
[mmederic@web ~]$ ps -ef | grep 1969
root        1969       1  0 15:08 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
apache      1971    1969  0 15:08 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
apache      1972    1969  0 15:08 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
apache      1973    1969  0 15:08 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
apache      1974    1969  0 15:08 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
````

Après un ls -al : 
````
[mmederic@web ~]$ ls -al /usr/share/testpage/
total 12
drwxr-xr-x.  2 root root   24 Jan  3 15:05 .
drwxr-xr-x. 81 root root 4096 Jan  3 15:05 ..
-rw-r--r--.  1 root root 7620 Jul 27 20:05 index.html
````
On peut voir que c'est root qui possède les autorisations. Donc dans notre cheminement de pensé, le contenu est accessible. 

* On crée un nouveau user : 
````
sudo useradd apaoperator -m -s /sbin/nologin -u 2048
````

On modifie le fichier de conf d'Httpd : 
````
[mmederic@web ~]$ sudo vim /etc/httpd/conf/httpd.conf
[mmederic@web ~]$ cat /etc/httpd/conf/httpd.conf | grep apa
User apaoperator
Group apaoperator
````

On restart apache, et on vérifie les changements : 
````
[mmederic@web ~]$ sudo systemctl restart httpd
[mmederic@web ~]$ systemctl status httpd
● httpd.service - The Apache HTTP Server
     Loaded: loaded (/usr/lib/systemd/system/httpd.service; enabled; vendor preset: disabled)
     Active: active (running) since Tue 2023-01-03 17:17:28 CET; 7s ago
[mmederic@web ~]$ ps -ef | grep apa
apaoper+    2475    2473  0 17:17 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
apaoper+    2476    2473  0 17:17 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
apaoper+    2477    2473  0 17:17 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
apaoper+    2478    2473  0 17:17 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
````

* Maintenant on change le port d'écoute d'Apache : 
````
[mmederic@web ~]$ cat /etc/httpd/conf/httpd.conf | grep Listen
Listen 8080
````

On fait le changemens sur le pare-feu : 
````
[mmederic@web ~]$ sudo firewall-cmd --add-port=8080/tcp --permanent --zone=public
success
[mmederic@web ~]$ sudo firewall-cmd --reload
success
````

Le port d'écoute a bien été changé : 
````
[mmederic@web ~]$ sudo ss -lnatpu | grep httpd
tcp   LISTEN 0      511                   *:8080            *:*     users:(("httpd",pid=2733,fd=4),("httpd",pid=2732,fd=4),("httpd",pid=2731,fd=4),("httpd",pid=2728,fd=4))
````

Le curl fonctionne : 
````
Initi@DESKTOP-IM5I5BK MINGW64 ~
$ curl 10.105.1.11:8080
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0<!doctype html>
<html>
  <head>
    <meta charset='utf-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1'>
    <title>HTTP Server Test Page powered by: Rocky Linux</title>
````

[httpd.conf](httpd.conf)



## Partie 2. Mise en place de la base de données.

* On lance l'installation de Mariadb : 
````
[mmederic@db ~]$ sudo dnf install mariadb-server
[mmederic@db ~]$ sudo systemctl enable mariadb
[mmederic@db ~]$ sudo systemctl start mariadb
[mmederic@db ~]$ sudo mysql_secure_installation
````
Puis on suit la documentation pour nous aider à installer Mariadb. 

* On fait en sorte que Mariadb se lance au démarrage : 
````
[mmederic@db ~]$ sudo systemctl is-enabled mariadb
enabled
````

* Le port d'écoute de mariadb : 
````
[mmederic@db ~]$ sudo ss -lantpu | grep mariadb
tcp   LISTEN 0      80                    *:3306            *:*     users:(("mariadbd",pid=3768,fd=19))
````

* On permet à mysql de passer le pare feu : 
````
[mmederic@db ~]$ sudo firewall-cmd --add-service=mysql --permanent
success
[mmederic@db ~]$ sudo firewall-cmd --reload
success
[mmederic@db ~]$ sudo firewall-cmd --list-all
public (active)
  target: default
  icmp-block-inversion: no
  interfaces: enp0s3 enp0s8
  sources:
  services: cockpit dhcpv6-client mysql ssh
  ports:
````

* Les processus liés à mariadb : 
````
[mmederic@db ~]$ sudo ps -efly | grep mariadb
S mysql       4445       1  0  80   0 94812 355177 do_pol 10:28 ?       00:00:00 /usr/libexec/mariadbd --basedir=/usr
````

## Partie 3. Configuration et mise en place de Nextcloud. 

### 1. Base de données. 

* On prépare la base de données : 
````
MariaDB [(none)]> create user 'nextcloud'@'10.105.1.11' identified by 'nuagesuivant';
Query OK, 0 rows affected (0.004 sec)

MariaDB [(none)]> create database if not exists nextcloud character set utf8mb4 collate utf8mb4_general_ci;
Query OK, 1 row affected (0.000 sec)

MariaDB [(none)]> grant all privileges on nextcloud.* to 'nextcloud'@'10.105.1.11';
Query OK, 0 rows affected (0.003 sec)

MariaDB [(none)]> flush privileges;
Query OK, 0 rows affected (0.001 sec)
````

* On essaie l'exploration de données : 
````
[mmederic@web ~]$ mysql -u nextcloud -h 10.105.1.12 -p
Enter password:
Welcome to the MySQL monitor.

mysql> show databases
    -> ;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| nextcloud          |
+--------------------+
2 rows in set (0.00 sec)

mysql> show tables;
ERROR 1046 (3D000): No database selected
mysql> use nextcloud;
Database changed
mysql> show tables;
Empty set (0.00 sec)
````

* On check les users dans notre db : 
````
MariaDB [(none)]> select user from mysql.user;
+-------------+
| User        |
+-------------+
| nextcloud   |
| mmederic    |
| mariadb.sys |
| mysql       |
| root        |
+-------------+
5 rows in set (0.002 sec)
````

 ### 2. Serveur web et NuageSuivant. 

 * On a bien veillé à remettre le default user et le port d'origine d'apache. 

 * L'installation des différents modules : 
````
[mmederic@web ~]$ sudo dnf config-manager --set-enabled crb
[mmederic@web ~]$ sudo dnf install dnf-utils http://rpms.remirepo.net/enterprise/remi-release-9.rpm -y
[mmederic@web ~]$ dnf module list php
[mmederic@web ~]$ sudo dnf module enable php:remi-8.1 -y
[mmederic@web ~]$ sudo dnf install -y php81-php
````

* On installe les module php : 
````
sudo dnf install -y libxml2 openssl php81-php php81-php-ctype php81-php-curl php81-php-gd php81-php-iconv php81-php-json php81-php-libxml php81-php-mbstring php81-php-openssl php81-php-posix php81-php-session php81-php-xml php81-php-zip php81-php-zlib php81-php-pdo php81-php-mysqlnd php81-php-intl php81-php-bcmath php81-php-gmp
Complete!
````

* On crée le dossier demandé : 
````
[mmederic@web ~]$ ls /var/www/
cgi-bin  html  tp5_nextcloud
````

* On curl dans le dossier : 
````
[mmederic@web]$ sudo curl  https://download.nextcloud.com/server/prereleases/nextcloud-25.0.0rc3.zip -SLO /var/www/tp5_nextcloud/
````

on a installé la commande unzip : 
````
[mmederic@web]$ sudo dnf install unzip
````

on unzip dans le dossier : 
````
[mmederic@web tp5_nextcloud]$ sudo unzip nextcloud-25.0.0rc3.zip
````

le fichier index.html existe : 
````
[mmederic@web nextcloud]$ ls | grep index.
index.html
index.php
````

on vérifie que le dossier appartient bien à l'utilisateur qui utilise apache : 
````
[mmederic@web www]$ ls -l | grep tp5_nextcloud
drwxr-xr-x. 3 root root 54 Jan  9 11:36 tp5_nextcloud
````

* On crée notre webroot : 
````
[mmederic@web ~]$ cd /etc/httpd/conf.d/
[mmederic@web conf.d]$ sudo vim webroot.conf
[mmederic@web conf.d]$ ls
README  autoindex.conf  php81-php.conf  userdir.conf  webroot.conf  welcome.conf
````
On y ajoute la configuration donnée évidemment. 

### 3. Finalisation de l'installation de NuageSuivant.

* On se connecte à la base de données :
````
[mmederic@db ~]$ sudo mysql
[sudo] password for mmederic:
Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MariaDB connection id is 132
Server version: 10.5.16-MariaDB MariaDB Server
````

* On utilise la bonne base de données :
````
MariaDB [(none)]> show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| nextcloud          |
| performance_schema |
+--------------------+
4 rows in set (0.002 sec)

MariaDB [(none)]> use nextcloud;
Reading table information for completion of table and column names
You can turn off this feature to get a quicker startup with -A

Database changed
`````

Puis on détermine combien de tables ont été créées via la commande : 
````
MariaDB [nextcloud]> show tables;
124 rows in set (0.000 sec)
````




