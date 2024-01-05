#!/bin/bash

if [[ -d /srv/yt/downloads ]] #Si le dossier existe 
then 
    url="$(https://www.youtube.com/watch?v=NZG69VP7UmI)"
    VideoName="$(youtube-dl ${url} -e -q --skip-download)"
    CreationVideoFileName="$(mkdir /srv/yt/downloads/${Videoname})"
    echo "${CreationVideoFileName}" #Alors on crée le dossier
    CreationVideoName="$(sudo touch /srv/yt/downloads/${Videoname}/${VideoName}.mp4)"
    echo "${CreationVideoName}" #Alors on crée le fichier
    GetDescription="$(youtube-dl ${url} --get-description -q --skip-download >> /srv/yt/downloads/${VideoName}/)"
    echo "${GetDescription}" #On récupère la description
    VideoDownload="$(youtube-dl ${url} -q)"
    echo "${VideoDownload}" #On télécharge la vidéo 
    echo " Video ${url} was downloaded successfully" #On annonce le téléchargement éffectué
    FilePath="$(/srv/yt/downloads/${Videoname}/${Videoname}.mp4)"
    echo "File Path : ${FilePath}"  #on visualise le chemin de la vidéo 
else 
    exit    #Sinon on sort du script
fi 

