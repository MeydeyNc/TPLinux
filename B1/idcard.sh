#!/bin/bash

Name="$(hostname)"
OS="$(head -n 1 /etc/os-release | cut -d '"' -f2)"
kernel="$(uname -r)"
IP="$(ip -f inet a | tail -n 2 | grep inet | cut -d ' ' -f6)"
RamF="$(free -h |grep Mem | tr -s ' ' | cut -d ' ' -f7)"
RamT="$(free -h |grep Mem | tr -s ' ' | cut -d ' ' -f2)"
Disk="$(df -ah | grep root | tr -s ' ' | cut -d ' ' -f4)"
Top5="$(ps -eo %mem=,cmd= --sort=-%mem | head -n 5)"
Ports="$(sudo ss -ltnpu)"

cat_filename='super_cat'
curl "https://cataas.com/cat" -o "${cat_filename}" -s
cat_file_output="$(file ${cat_filename})"

if [[ "${cat_file_output}" == *JPEG* ]] ; then
  cat_filetype='jpg'
elif [[ "${cat_file_output}" == *PNG* ]] ; then
  cat_filetype='png'
elif [[ "${cat_file_output}" == *GIF* ]] ; then
  cat_filetype='gif'
fi

mv "${cat_filename}" "${cat_filename}.${cat_filetype}"

echo "Machine Name : ${Name}"
echo "OS : ${OS}" echo "and kernel version is ${kernel}"
echo "IP : ${IP}" 
echo "RAM : ${RamF}" echo "memory available on ${RamT} total memory"
echo "Disk : ${Disk} space left"
echo "Top 5 processes by RAM usage :" 
echo "${Top5}" 
echo "Listening ports :"
echo "${Ports}"

echo "Here is your random cat : ./${cat_filename}.${cat_filetype}"
