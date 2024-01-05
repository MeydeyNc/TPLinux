#!/bin/bash

#This a script written by Mederic MARQUIE from B1A Ynov in Bordeaux.

# The goal of this script is to create a backup save for our nextcloud solution.


Maintenance_Mode_on="$(sudo -u mmederic php occ maintenance:mode --on) Going Maintenance Mode"
Maintenance_Mode_off="$(sudo -u mmederic php occ maintenance:mode --off) Going Live Mode"
Backup_folders="$(sudo rsync -Aavx /srv/backup/nextcloud-dirbkp_`date +"%Y%m%d"`) Creating backup folders. . ."
Data_folders="$(sudo mysqldump --skip-column-statistics -h 10.105.1.12 -u nextcloud -p nuagesuivant > nextcloud-sqlbkp_`date +"%Y%m%d"`.bak)"
Move_backup_folders="$(sudo mv nextcloud* /srv/backup/)"
Zip_folders="$(zip -m -q ${Backup_folders} ${Data_folders})"
Remove_folders="$(sudo rm -r /srv/nextcloud*)"

echo "Launching Backup Procedure..."

echo ${Maintenance_Mode_on}

echo ${Backup_folders}

echo ${Data_folders}

echo ${Zip_folders}

echo ${Move_Data_folders}

echo ${Maintenance_Mode_off}

echo "Backup Process done."
