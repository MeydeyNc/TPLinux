# Premiers pas Docker 

## 1. Init.

### 3. Sudo, c'est pas bo

Tout se passe bien, on à les droits pour utiliser docker sans sudo. 
Simple commande : 
````
[mmederic@tp1docker ~]$ sudo usermod -aG docker $USER
````

````
[mmederic@tp1docker ~]$ docker ps
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES
[mmederic@tp1docker ~]$ docker info
Client: Docker Engine - Community
 Version:    24.0.7
 Context:    default
 Debug Mode: false
 Plugins:
  buildx: Docker Buildx (Docker Inc.)
    Version:  v0.11.2
    Path:     /usr/libexec/docker/cli-plugins/docker-buildx
  compose: Docker Compose (Docker Inc.)
    Version:  v2.21.0
    Path:     /usr/libexec/docker/cli-plugins/docker-compose
````

### 4. Un premier conteneur en vif. 

Le conteneur est lancé : 
````
[mmederic@tp1docker ~]$ docker ps
CONTAINER ID   IMAGE     COMMAND                  CREATED         STATUS         PORTS                                   NAMES
85ddf8804ee2   nginx     "/docker-entrypoint.…"   8 minutes ago   Up 8 minutes   0.0.0.0:9999->80/tcp, :::9999->80/tcp   lucid_bassi
````

On a les logs ici : 
````
10.1.10.1 - - [27/Dec/2023:13:55:22 +0000] "GET / HTTP/1.1" 200 615 "-" "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:121.0) Gecko/20100101 Firefox/121.0" "-"
10.1.10.1 - - [27/Dec/2023:13:55:23 +0000] "GET /favicon.ico HTTP/1.1" 404 153 "http://10.1.10.15:9999/" "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:121.0) Gecko/20100101 Firefox/121.0" "-"
2023/12/27 13:55:23 [error] 30#30: *1 open() "/usr/share/nginx/html/favicon.ico" failed (2: No such file or directory), client: 10.1.10.1, server: localhost, request: "GET /favicon.ico HTTP/1.1", host: "10.1.10.15:9999", referrer: "http://10.1.10.15:9999/"
10.1.10.1 - - [27/Dec/2023:13:55:51 +0000] "GET / HTTP/1.1" 200 615 "-" "curl/7.85.0" "-"
````
obtenus avec cette commande : 
````
[mmederic@tp1docker ~]$ docker logs lucid_bassi
````

Le résultat de notre commande ss -lntp : 
````
[mmederic@tp1docker ~]$ sudo ss -lntp | grep docker
LISTEN 0      4096         0.0.0.0:9999      0.0.0.0:*    users:(("docker-proxy",pid=2889,fd=4))
LISTEN 0      4096            [::]:9999         [::]:*    users:(("docker-proxy",pid=2895,fd=4))
````

On affiche les ports ouverts : 
````
[mmederic@tp1docker ~]$ sudo firewall-cmd --list-all | grep ports
  ports: 9999/tcp
````

On peut visiter le site que nous venons de lancer avec le conteneur docker : 
````
Initi@DESKTOP-IM5I5BK MINGW64 ~ (master)
$ curl 10.1.10.15:9999
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   615  100   615    0     0   324k      0 --:--:-- --:--:-- --:--:--  600k<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
html { color-scheme: light dark; }
body { width: 35em; margin: 0 auto;
font-family: Tahoma, Verdana, Arial, sans-serif; }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
````

On peut voir que le docker est bien lancé : 
````
[mmederic@tp1docker ~]$ docker ps
CONTAINER ID   IMAGE     COMMAND                  CREATED         STATUS         PORTS                                               NAMES
37cc475bf9cd   nginx     "/docker-entrypoint.…"   2 seconds ago   Up 2 seconds   80/tcp, 0.0.0.0:9999->8080/tcp, :::9999->8080/tcp   compassionate_kalam
````
On visite notre site : 
````
Initi@DESKTOP-IM5I5BK MINGW64 ~ (master)
$ curl 10.1.10.15:9999
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   210  100   210    0     0   153k      0 --:--:-- --:--:-- --:--:--  205k<!DOCTYPE html>
<html lang="en">
<head>
   <meta charset="UTF-8">
   <title>My Nginx Server</title>
</head>
<body>
   <h1>Welcome to My Nginx Server!</h1>
   <p>This is a simple test page.</p>
</body>
</html>
````

### 5. Un deuxième conteneur en vif
On pull le docker Python avec la commande donnée : 
````
docker run -it python bash
````

On a bien un bash avec Python : 
````
root@0e2e83b87438:/# python -V
Python 3.12.1
````

On installe les libs demandées : 
````
root@0e2e83b87438:/# pip install aiohttp aioconsole
````

On vérifie : 
````
root@0e2e83b87438:/# python
Python 3.12.1 (main, Dec 19 2023, 20:14:15) [GCC 12.2.0] on linux
Type "help", "copyright", "credits" or "license" for more information.
>>> import aiohttp
````

## II. Images. 

### 1. Images publiques. 

On pull les images demandées : 
````
docker pull python:3.11 mysql:5.7 wordpress:latest linuxserver/wikijs:latest
````
Les voicis : 
````
[mmederic@tp1docker ~]$ docker images
REPOSITORY           TAG       IMAGE ID       CREATED        SIZE
linuxserver/wikijs   latest    869729f6d3c5   12 days ago    441MB
mysql                5.7       5107333e08a8   2 weeks ago    501MB
python               latest    fc7a60e86bae   2 weeks ago    1.02GB
wordpress            latest    fd2f5a0c6fba   2 weeks ago    739MB
python               3.11      22140cbb3b0c   3 weeks ago    1.01GB
nginx                latest    d453dd892d93   2 months ago   187MB
````

On lance un conteneur et on vérifie qu'il est dans la bonne version : 
````
[mmederic@tp1docker ~]$ docker run -it python:3.11 bash
root@d78e2d2e1752:/# python -V
Python 3.11.7
````

### 2. Construire une image.

Nous avons écrit un Dockerfile pour notre application Python :
````
[mmederic@tp1docker python_app_build]$ cat Dockerfile
FROM ubuntu:latest

RUN apt-get update -y

RUN apt-get install -y python3

RUN apt-get install pip -y

RUN pip install emoji

WORKDIR /app

COPY . /app

ENTRYPOINT ["python3","app.py"]
````

On a build notre image : 
````
[mmederic@tp1docker python_app_build]$ docker images | grep python_app
python_app           version_de_ouf   ac4b5f2789d1   4 minutes ago   486MB
````

On lance ! 
````
[mmederic@tp1docker python_app_build]$ docker run python_app:version_de_ouf
Un exemple pour les emojis 👍
````

## III. Docker Compose.

On crée notre fichier docker-compose.yml : 
````
[mmederic@tp1docker compose_test]$ cat docker-compose.yml
version: "3"

services:
  conteneur_nul:
    image: debian
    entrypoint: sleep 9999
  conteneur_floresque:
    image: debian
    entrypoint: sleep 9999
````

On lance le docker-compose, ça tourne ! : 
````
[mmederic@tp1docker compose_test]$ docker compose ps
NAME                                 IMAGE     COMMAND        SERVICE               CREATED         STATUS         PORTS
compose_test-conteneur_floresque-1   debian    "sleep 9999"   conteneur_floresque   9 seconds ago   Up 8 seconds
compose_test-conteneur_nul-1         debian    "sleep 9999"   conteneur_nul         9 seconds ago   Up 8 seconds
````

On va tenter un ping, après une update et un install de iputils-ping : 
````
root@306ce7ab5080:/# ping conteneur_floresque
PING conteneur_floresque (172.18.0.2) 56(84) bytes of data.
64 bytes from compose_test-conteneur_floresque-1.compose_test_default (172.18.0.2): icmp_seq=1 ttl=64 time=0.118 ms
64 bytes from compose_test-conteneur_floresque-1.compose_test_default (172.18.0.2): icmp_seq=2 ttl=64 time=0.136 ms
64 bytes from compose_test-conteneur_floresque-1.compose_test_default (172.18.0.2): icmp_seq=3 ttl=64 time=0.088 ms
64 bytes from compose_test-conteneur_floresque-1.compose_test_default (172.18.0.2): icmp_seq=4 ttl=64 time=0.098 ms
^C
--- conteneur_floresque ping statistics ---
4 packets transmitted, 4 received, 0% packet loss, time 3006ms
rtt min/avg/max/mdev = 0.088/0.110/0.136/0.018 ms
````

It works ! Très pratique Docker, c'est sympa !