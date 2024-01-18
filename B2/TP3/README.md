# TP-3 Linux - Vagrant 

### 1. Une première VM

On crée un dossier pour le TP3 et on initialise vagrant dans ce dossier.
On récupère ensuite la box generic/ubuntu2204.
````
PS C:\Users\Initi\TPLinux\B2\TP3\vagrant> ls


    Répertoire : C:\Users\Initi\TPLinux\B2\TP3\vagrant


Mode                 LastWriteTime         Length Name
----                 -------------         ------ ----
d-----        18/01/2024     10:42                .vagrant
-a----        18/01/2024     10:44           3469 Vagrantfile
````
Un petit cat du Vagrantfile 
````
PS C:\Users\Initi\TPLinux\B2\TP3\vagrant> cat .\Vagrantfile
# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://vagrantcloud.com/search.
  config.vm.box = "generic/ubuntu2204"
````

On vient de modifier les lignes données dans le TP :
````
PS C:\Users\Initi\TPLinux\B2\TP3\vagrant> cat .\Vagrantfile |  Select-String -Pattern '#' -NotMatch


Vagrant.configure("2") do |config|

  config.vm.box = "generic/ubuntu2204"

  config.vm.box_check_update = false

  config.vm.synced_folder ".", "/vagrant", disabled: true

end
````

Nous sommes passés entre temps sur une Rocky9, ça fonctionnait pas avec une Ubuntu (???).

La VM fonctionne : 
````
PS C:\Users\Initi\TPLinux\B2\TP3\vagrant> vagrant status
Current machine states:

default                   running (virtualbox)

The VM is running. To stop this VM, you can run `vagrant halt` to
shut it down forcefully, or you can run `vagrant suspend` to simply
suspend the virtual machine. In either case, to restart it again,
simply run `vagrant up`.
````

On peut ssh dans la vm : 
````
PS C:\Users\Initi\TPLinux\B2\TP3\vagrant> vagrant ssh
[vagrant@rocky9 ~]$
[vagrant@rocky9 ~]$
[vagrant@rocky9 ~]$ ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:b1:30:01 brd ff:ff:ff:ff:ff:ff
    altname enp0s3
    inet 10.0.2.15/24 brd 10.0.2.255 scope global dynamic noprefixroute eth0
       valid_lft 86251sec preferred_lft 86251sec
````

On peut l'arrêter et la supprimer : 
````
PS C:\Users\Initi\TPLinux\B2\TP3\vagrant> vagrant halt
==> default: Attempting graceful shutdown of VM...
PS C:\Users\Initi\TPLinux\B2\TP3\vagrant> vagrant destroy -f
==> default: Destroying VM and associated drives...
````

On va paramètrer une vm pour en faire un package : 
````
sudo dnf update -y 
sudo dnf install -y vim bind-utils net-tools nmap -y
sudo firewall-cmd --list-all
sudo vi /etc/selinux/config
````

Le package est créé, on en fait un beau vagrantfile et on test  :
````
[vagrant@rocky9 ~]$ sestatus
SELinux status:                 enabled
SELinuxfs mount:                /sys/fs/selinux
SELinux root directory:         /etc/selinux
Loaded policy name:             targeted
Current mode:                   permissive
Mode from config file:          permissive
Policy MLS status:              enabled
Policy deny_unknown status:     allowed
Memory protection checking:     actual (secure)
Max kernel policy version:      33
````
it works.


Nous avons créés nos deux vagrantfile personnalisés : 

- [Vagrantfile-3A](./partie1/Vagrantfile-3A)
- [Vagrantfile-3B](./partie1/Vagrantfile-3B)

Vagrant sympa mais un peu lent. 