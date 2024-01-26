# TP-4 Vers une maîtrise des OS Linux.

## I. 1. LVM dès l'installation

### 2.Scénario de remplissage de partition. 

On rempli la partition en mode bourrinage : 
````
[mmederic@tp4 ~]$ dd if=/dev/zero of=/home/mmederic/bigfile bs=4M count=5000


dd: error writing '/home/mmederic/bigfile': No space left on device
1171+0 records in
1170+0 records out
````

On constate : 
````
[mmederic@tp4 ~]$ df -h | grep /home
/dev/mapper/rl-home  4.9G  4.6G     0 100% /home
````

On crée puis ajoute un nouveau disk sur vbox : 
````
[mmederic@tp4 ~]$ lsblk | grep sdb
sdb           8:16   0   40G  0 disk
````

On crée une partition sur le nouveau disk : 
````
[mmederic@tp4 ~]$ sudo pvcreate /dev/sdb
[mmederic@tp4 ~]$ sudo pvs | grep sdb
  /dev/sdb   rl lvm2 a--  <40.00g    0
``````

On extend le volume : 
````
[mmederic@tp4 ~]$ sudo vgextend rl /dev/sdb
[mmederic@tp4 ~]$ sudo vgs
  VG #PV #LV #SN Attr   VSize  VFree
  rl   2   4   0 wz--n- 61.00g    0
````

Puis on extend le volume logique : 
````
[mmederic@tp4 ~]$ sudo lvextend -l +100%FREE /dev/rl/home
[mmederic@tp4 ~]$ sudo lvs | grep home
  home rl -wi-ao---- 45.00g
````

On a ici dans le hisory la suite des commandes used :
````
sudo fdisk /dev/sda
  102  lsblk
  103  ls /dev/sda3
  104  sudo pvcreate /dev/sda
  105  sudo pvcreate /dev/sda3
  106  sudo pvs
  107  sudo vgs
  108  sudo vgextend rl /dev/sda3
  109  sudo vgs
  110  sudo lvs
  111  sudo lvextend -l +100%FREE /dev/rl/home
  112  sudo lvs
  113  df -h
  114  sudo resize2fs /dev/rl/home
````

## II.Gestion des users. 

alice : 
````
[mmederic@tp4 ~]$ sudo useradd alice -d /home/alice -s /bin/bash
[mmederic@tp4 ~]$ sudo usermod alice -p toto
[mmederic@tp4 ~]$ sudo usermod alice -G admins
[mmederic@tp4 ~]$ id alice
uid=1001(alice) gid=1001(alice) groups=1001(alice),1002(admins)
[mmederic@tp4 ~]$ getent passwd alice | cut -d: -f6
/home/alice
[mmederic@tp4 ~]$ getent passwd alice | cut -d: -f7
/bin/bash
[mmederic@tp4 ~]$ sudo cat /etc/shadow | grep alice
alice:toto:19747:0:99999:7:::
````

bob : 
````
[mmederic@tp4 ~]$ sudo useradd bob -d /home/bob -s /bin/bash
[mmederic@tp4 ~]$ sudo usermod bob -p toto
[mmederic@tp4 ~]$ sudo usermod bob -G admins
[mmederic@tp4 ~]$ id bob
uid=1002(bob) gid=1003(bob) groups=1003(bob),1002(admins)
[mmederic@tp4 ~]$ getent passwd bob | cut -d: -f6
/home/bob
[mmederic@tp4 ~]$ getent passwd bob | cut -d: -f7
/bin/bash
[mmederic@tp4 ~]$ sudo cat /etc/shadow | grep bob
bob:toto:19747:0:99999:7:::
````

charlie :
````
[mmederic@tp4 ~]$ sudo useradd charlie -d /home/charlie -s /bin/bash
[mmederic@tp4 ~]$ sudo usermod charlie -G admins
[mmederic@tp4 ~]$ sudo usermod charlie -p toto
[mmederic@tp4 ~]$ who charlie
[mmederic@tp4 ~]$ id charlie
uid=1003(charlie) gid=1004(charlie) groups=1004(charlie),1002(admins)
[mmederic@tp4 ~]$ getent passwd charlie | cut -d: -f6
/home/charlie
[mmederic@tp4 ~]$ getent passwd charlie | cut -d: -f7
/bin/bash
[mmederic@tp4 ~]$ sudo cat /etc/shadow | grep charlie
charlie:toto:19747:0:99999:7:::
````

eve: 
````
[mmederic@tp4 ~]$ sudo useradd eve -d /home/eve -s /bin/bash
[mmederic@tp4 ~]$ sudo usermod eve -p toto
[mmederic@tp4 ~]$ id eve
uid=1004(eve) gid=1005(eve) groups=1005(eve)
[mmederic@tp4 ~]$ getent passwd eve | cut -d: -f6
/home/eve
[mmederic@tp4 ~]$ getent passwd eve | cut -d: -f7
/bin/bash
[mmederic@tp4 ~]$ sudo cat /etc/shadow | grep eve
eve:toto:19747:0:99999:7:::
````

backup :
````
[mmederic@tp4 ~]$ id backup
uid=1005(backup) gid=1006(backup) groups=1006(backup)
[mmederic@tp4 ~]$ getent passwd backup | cut -d: -f6
/var/backup
[mmederic@tp4 ~]$ getent passwd backup | cut -d: -f7
/usr/bin/nologin
[mmederic@tp4 ~]$ sudo cat /etc/shadow | grep backup
backup:toto:19747:0:99999:7:::
[mmederic@tp4 ~]$
````

Le groupe admins est sudo, sans utiliser son mot de passe : 
````
## Same thing without a password
# %wheel        ALL=(ALL)       NOPASSWD: ALL
%admins         ALL=(ALL)       NOPASSWD: ALL
````

On a modifié le fichier sudoers pour permettre à eve d'utiliser ls en tant que backup : 
````
## Allow root to run any commands anywhere
root    ALL=(ALL)       ALL
eve     ALL=(backup)    /bin/ls
````

En ce qui concerne le dossier precious_backup, voici le résultat :
````
[mmederic@tp4 ~]$ sudo ls -al /var/backup/ | grep precious_backup
-rw-r-----.  1 backup backup    5 Jan 26 10:40 precious_backup
````
Nos commandes pour y parvenir : 
````
sudo vi /var/backup/precious_backup
[mmederic@tp4 ~]$ sudo chown backup:backup /var/backup/precious_backup
[mmederic@tp4 ~]$ sudo chmod 640 /var/backup/precious_backup
````

un cat du fichier precious_backup, parce que pourquoi pas : 
````
[mmederic@tp4 ~]$ sudo cat /var/backup/precious_backup
meow
````

Pour les mots de passe des users.
On sait qu'on a le fichier shadow qui permet de le savoir : 
````
[mmederic@tp4 ~]$ sudo cat /etc/shadow | grep "\$6"
root:$6$liyemM4b8FBfAAHE$tO8fhSN5hzUiHuC1xGjWFQDfNkSlkSd7Qea4nkRKZKiE8oHlJpm31PWoBfZMb7CuUsiVSAZufWi19glXAt0rM.::0:99999:7:::
mmederic:$6$cKmX/GU352GtxR5l$PV7NUjm6qZaT6dE1RHiubVjEI/ZoEwMfPWuLYVvx4yHF/Ici5lcPgIEcnvD3jNs71VXK94z./ROpvydIRK4aM.::0:99999:7:::
eve:$6$klaFEhb4oCPWa7tJ$SV35erVxlEn1gSEYu4DRRdg0sijx0G5x.A1Ulz5ah87O5i6C80qExPBG6Ikl9nwWl0TbK7TThBhCkBiRPPjhl/:19748:0:99999:7:::
backup:$6$9w.zA.Yo50FZf4xi$og/AL/eJNXF5nPiDC9eWEon6NI4T4WqBo5U/p6CSKvskunMO6tEsA/ZoTAInhhYrkrRD8Rvhxsf8PhFi3FEiU.:19748:0:99999:7:::
````

Nos droits avec eve : 
````
[eve@tp4 ~]$ sudo -l
[sudo] password for eve:
Matching Defaults entries for eve on tp4:
    !visiblepw, always_set_home, match_group_by_gid, always_query_group_plugin, env_reset, env_keep="COLORS DISPLAY
    HOSTNAME HISTSIZE KDEDIR LS_COLORS", env_keep+="MAIL PS1 PS2 QTDIR USERNAME LANG LC_ADDRESS LC_CTYPE",
    env_keep+="LC_COLLATE LC_IDENTIFICATION LC_MEASUREMENT LC_MESSAGES", env_keep+="LC_MONETARY LC_NAME LC_NUMERIC
    LC_PAPER LC_TELEPHONE", env_keep+="LC_TIME LC_ALL LANGUAGE LINGUAS _XKB_CHARSET XAUTHORITY",
    secure_path=/sbin\:/bin\:/usr/sbin\:/usr/bin

User eve may run the following commands on tp4:
    (backup) /bin/ls
````

## III. Gestion du temps.

Notre service NTP : 
````
[mmederic@tp4 ~]$ timedatectl
               Local time: Fri 2024-01-26 11:12:35 CET
           Universal time: Fri 2024-01-26 10:12:35 UTC
                 RTC time: Fri 2024-01-26 10:04:33
                Time zone: Europe/Paris (CET, +0100)
System clock synchronized: no
              NTP service: active
          RTC in local TZ: no
````

Un petit cat pour savoir si on a bien pris les serveurs français à modifier dans la conf : 
````
[mmederic@tp4 ~]$ cat /etc/chrony.conf
# Use public servers from the pool.ntp.org project.
# Please consider joining the pool (https://www.pool.ntp.org/join.html).
server 0.fr.pool.ntp.org
server 1.fr.pool.ntp.org
server 2.fr.pool.ntp.org
server 3.fr.pool.ntp.org
````

On s'assure qu'il est synchro sur l'heure de Paris : 
````
[mmederic@tp4 ~]$ timedatectl
               Local time: Fri 2024-01-26 12:29:41 CET
           Universal time: Fri 2024-01-26 11:29:41 UTC
                 RTC time: Fri 2024-01-26 11:29:41
                Time zone: Europe/Paris (CET, +0100)
System clock synchronized: yes
              NTP service: active
          RTC in local TZ: no
[mmederic@tp4 ~]$ timedatectl | grep synchro
System clock synchronized: yes
````
