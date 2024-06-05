# TP-5 Admin : Haute Dispo. 

## Partie I - Setup du TP :

![Setup](./images/jenkins-prepare-the-finest-carpet.jpeg)

On va donc faire un jolie Vagrant qui se trouve [ici](./Vagrant/Vagrantfile).

Dans le dossier Vagrant, on retrouvera tous les scripts et fichiers de confs pour les vagrant.

Et nos scripts : 

 - [Web](./Vagrant/web/web1.sh) 
 - [DB](./Vagrant/db/db1.sh) 
 - [Reverse_Proxy](./Vagrant/rp/rp1.sh)

Faut taper 2/3 commandes pour que ça marche quand meme : 

````
vagrant up
vagrant ssh [web1 ou db1 ou rp1]
cd /var/[web1 ou db1 ou rp1]
sudo chmod +x [web1.sh ou db1.sh ou rp1.sh]
sudo ./[web1.sh ou db1.sh ou rp1.sh - tqt c'est pas un virus]
````

*On peut s'assure du visudo de vagrant pour que ça marche mieux aussi quand meme*

Et voila, c'est tout.

## Partie II - Haute Disponibilité : 

![Not Higly Available](./images/Anavailable.jpeg)

On prépare nos nouvelles VMs avec un nouveau Vagrantfile [ici](./HA/Vagrantfile).

Dans le dossier HA on retrouvera tous les dossiers de scripts et les fichiers de confs utilisés pour la 2ème partie du TP.

On vient ensuite de modifier le fichier de conf du reverse proxy : 

````bash
[vagrant@rp1 conf.d]$ sudo cat app_nulle.conf
upstream app_nulle_servers {
        server web1.tp5:80;
        server web2.tp5:80;
        server web3.tp5:80;

}

server {
    listen 80;
    server_name app_nulle;

    location / {
        proxy_pass http://app_nulle_servers;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
````

*J'ai pu faire la conf, mais malheureusement, j'ai une erreur 403 et je ne sais pas comment la résoudre. J'imagine qu'elle vient du Web1 / Docker. Le Selinux était enforcing, j'ai voulus le passer en permissive mais pas moyen de mettre la main sur le mdp root de vagrant (j'ai essayé "vagrant") et rien du tout.*

Je n'ai toujours pas réussi à résoudre le problème, mais je vais continuer à chercher.

Entre temps j'ai continué à update les scripts pour tenter de tout faire avec, mais je n'ai pas réussi à résoudre les soucis précédents.

![Alt Text](./images/hurtedcat.jpg)