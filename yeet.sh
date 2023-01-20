#!/bin/bash

video_url="${1}"

# vérif que c'est bien une url youtube

video_description="$(youtube-dl --get-description -q $video_url)"
video_title="$(youtube-dl -e $video_url)"

videos_dir='/srv/yt/downloads'
this_video_dir="${videos_dir}/${video_title}"

date="${date -u }"

if [[ -d "${videos_dir}" ]]
then
        mkdir "${this_video_dir}"
        echo "${video_description}" > "${this_video_dir}/description"
        echo "Video "${1}" was downloaded successfully."
        echo "Here's the file path  : ${videos_dir}/${this_video_dir}.mp4"
else
        exit
fi
       