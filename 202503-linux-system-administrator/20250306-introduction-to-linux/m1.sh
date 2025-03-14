#!/bin/bash

#
# Homework Check Script 
# for LSA 2021.11+ / M1
#
# Dimitar Zahariev (dimitar@zahariev.pro)
#

app=''

if [ x$app == 'x' ]; then 
  curl --help &> /dev/null 
  if [ $? -eq 0 ]; then app='curl'; fi
fi

if [ x$app == 'x' ]; then
  wget --help &> /dev/null
  if [ $? -eq 0 ]; then app='wget'; fi
fi

if [ ! "$app" ]; then
  echo 'Neither curl nor wget found. Exiting ...'
  exit 1
fi

distro=other

grep -i rhel /etc/os-release &> /dev/null
if [ $? -eq 0 ]; then distro=RHEL; fi

grep -i suse /etc/os-release &> /dev/null
if [ $? -eq 0 ]; then distro=SUSE; fi

grep -i debian /etc/os-release &> /dev/null
if [ $? -eq 0 ]; then distro=Debian; fi

fware=BIOS

ls -al /sys/firmware/efi/ &> /dev/null
if [ $? -eq 0 ]; then fware=UEFI; fi

logfile=$(mktemp)

echo "* Working on $distro-based machine ($fware) using $app to report"

echo '{' > $logfile

echo "\"date\": \"$(date '+%Y-%m-%d %H:%M:%S')\"," >> $logfile

echo "\"vm\": 1, " >> $logfile

echo "\"fware\": \"$fware\"," >> $logfile

echo "\"family\": \"$distro\"," >> $logfile

echo "\"distribution\": $(grep PRETTY_NAME /etc/os-release | cut -d = -f 2), " >> $logfile

echo "\"module\": 1," >> $logfile

echo "\"tests\": [" >> $logfile

tt='Testing for a desktop environment installed and in use'
echo '* '$tt' ...'
tf=$XDG_CURRENT_DESKTOP
echo $tf | grep -i -E 'cinnamon|gnome|kde|lxde|lxqt|mate|xfce' &> /dev/null
if [ $? -eq 0 ]; then tr='PASS'; else tr='ERROR'; fi
echo '... '$tr
echo "{\"id\": 1, \"name\": \"$tt\", \"found\": \"$tf\", \"result\": \"$tr\"}," >> $logfile


tt='Testing for a host named after the distribution'
echo '* '$tt' ...'
tf=$(hostname -s)
grep $tf /etc/os-release &> /dev/null
if [ $? -eq 0 ]; then tr='PASS'; else tr='ERROR'; fi
echo '... '$tr
echo "{\"id\": 2, \"name\": \"$tt\", \"found\": \"$tf\", \"result\": \"$tr\"}," >> $logfile


tt='Testing for the domain name of the host'
echo '* '$tt' ...'
tf=$(hostname)
echo $tf | grep lsa.lab &> /dev/null
if [ $? -eq 0 ]; then tr='PASS'; else tr='ERROR'; fi
echo '... '$tr
echo "{\"id\": 3, \"name\": \"$tt\", \"found\": \"$tf\", \"result\": \"$tr\"}," >> $logfile


tt='Testing for a regular user #1'
echo '* '$tt' ...'
tf=$(id -u)
if [ $(id -u) -ge 1000 ]; then tr='PASS'; else tr='ERROR'; fi
echo '... '$tr
echo "{\"id\": 4, \"name\": \"$tt\", \"found\": \"$tf\", \"result\": \"$tr\"}," >> $logfile


tt='Testing for a regular user #2'
echo '* '$tt' ...'
tf=$USER 
cut -d : -f 5 /etc/passwd | grep -i $USER &> /dev/null
if [ $? -eq 0 ]; then tr='PASS'; else tr='ERROR'; fi
echo '... '$tr
echo "{\"id\": 5, \"name\": \"$tt\", \"found\": \"$tf\", \"result\": \"$tr\"}" >> $logfile

echo "]" >> $logfile

echo '}' >> $logfile

if [ $app == 'curl' ]; then
  curl --request POST --url https://courses.zahariev.pro/ --header 'content-type: application/json' --data @$logfile
else
  wget --quiet --method POST --header 'content-type: application/json' --body-file=$logfile --output-document - https://courses.zahariev.pro/
fi
