#!/bin/bash

#
# Homework Check Script 
# for LSA 2021.11 / M6
# 
# Dimitar Zahariev (dimitar@zahariev.pro)
# 

# Prerequsites
if [ -n $app ]; then 
  curl --help &> /dev/null 
  if [ $? -eq 0 ]; then app='curl'; fi
fi

if [ -n $app ]; then 
  wget --help &> /dev/null
  if [ $? -eq 0 ]; then app='wget'; fi
fi

if [ ! "$app" ]; then
  echo 'Neither curl nor wget found. Exiting ...'
  exit 1
fi

# Test if gdisk is available
gdisk --help &> /dev/null
if [ $? -ne 0 ]; then
  echo 'ERROR: No gdisk found. Exiting ...'
  exit 1
fi

tu=${SUDO_USER:-$USER}

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

echo "\"module\": 6," >> $logfile

echo "\"tests\": [" >> $logfile


tt='Testing if ~/etc.tar.xz file exists'
echo '* '$tt' ...'
ls -l /home/$tu/etc.tar.xz &> /dev/null && file /home/$tu/etc.tar.xz 2> /dev/null | grep 'XZ compressed' &> /dev/null
if [ $? -eq 0 ]; then tr='PASS'; else tr='ERROR'; fi
echo '... '$tr
echo "{\"id\": 1, \"name\": \"$tt\", \"result\": \"$tr\"}, " >> $logfile


tt='Testing if ~/etc.tar.bzip file exists'
echo '* '$tt' ...'
ls -l /home/$tu/etc.tar.bzip &> /dev/null && file /home/$tu/etc.tar.bzip 2> /dev/null | grep 'bzip2 compressed' &> /dev/null
if [ $? -eq 0 ]; then tr='PASS'; else tr='ERROR'; fi
echo '... '$tr
echo "{\"id\": 2, \"name\": \"$tt\", \"result\": \"$tr\"}, " >> $logfile


tt='Testing if ~/etc.tar.gzip file exists'
echo '* '$tt' ...'
ls -l /home/$tu/etc.tar.gzip &> /dev/null && file /home/$tu/etc.tar.gzip 2> /dev/null | grep 'gzip compressed' &> /dev/null
if [ $? -eq 0 ]; then tr='PASS'; else tr='ERROR'; fi
echo '... '$tr
echo "{\"id\": 3, \"name\": \"$tt\", \"result\": \"$tr\"}, " >> $logfile


tt='Testing the ~/compression-test.txt file'
echo '* '$tt' ...'
ls -l /home/$tu/compression-test.txt &> /dev/null && head -n 1 /home/$tu/compression-test.txt 2> /dev/null | grep 'etc.tar.xz' &> /dev/null
if [ $? -eq 0 ]; then tr='PASS'; else tr='ERROR'; fi
echo '... '$tr
echo "{\"id\": 4, \"name\": \"$tt\", \"result\": \"$tr\"}, " >> $logfile

d2='sdb'

lsblk -l -n -p -d /dev/vdb -o NAME,SIZE,PARTTYPE &> /dev/null
if [ $? -eq 0 ]; then d2='vdb'; fi

lsblk -l -n -p -d /dev/xvdb -o NAME,SIZE,PARTTYPE &> /dev/null
if [ $? -eq 0 ]; then d2='xvdb'; fi

lsblk -l -n -p -d /dev/xdb -o NAME,SIZE,PARTTYPE &> /dev/null
if [ $? -eq 0 ]; then d2='xdb'; fi

tt="Testing the /dev/$d2 disk layout"
echo '* '$tt' ...'
lsblk -l -n -p /dev/$d2 2> /dev/null | grep $d2 | tail -n 1 | grep ${d2}6 &> /dev/null
if [ $? -eq 0 ]; then tr='PASS'; else tr='ERROR'; fi
echo '... '$tr
echo "{\"id\": 5, \"name\": \"$tt\", \"result\": \"$tr\"}, " >> $logfile


tt="Testing partition #1 of /dev/$d2 disk"
echo '* '$tt' ...'
lsblk -l -n -p /dev/$d2 -o NAME,SIZE,PARTTYPE 2> /dev/null | grep ${d2}1 2> /dev/null | grep 700M 2> /dev/null | grep 0fc63daf &> /dev/null
if [ $? -eq 0 ]; then tr='PASS'; else tr='ERROR'; fi
echo '... '$tr
echo "{\"id\": 6, \"name\": \"$tt\", \"result\": \"$tr\"}, " >> $logfile


tt="Testing partition #2 of /dev/$d2 disk"
echo '* '$tt' ...'
lsblk -l -n -p /dev/$d2 -o NAME,SIZE,PARTTYPE 2> /dev/null | grep ${d2}2 2> /dev/null | grep 200M 2> /dev/null | grep 0657fd6d &> /dev/null
if [ $? -eq 0 ]; then tr='PASS'; else tr='ERROR'; fi
echo '... '$tr
echo "{\"id\": 7, \"name\": \"$tt\", \"result\": \"$tr\"}, " >> $logfile


tt="Testing partition #3 of /dev/$d2 disk"
echo '* '$tt' ...'
lsblk -l -n -p /dev/$d2 -o NAME,SIZE,PARTTYPE 2> /dev/null | grep ${d2}3 2> /dev/null | grep 300M 2> /dev/null | grep 0fc63daf &> /dev/null
if [ $? -eq 0 ]; then tr='PASS'; else tr='ERROR'; fi
echo '... '$tr
echo "{\"id\": 8, \"name\": \"$tt\", \"result\": \"$tr\"}, " >> $logfile


tt="Testing partition #4 of /dev/$d2 disk"
echo '* '$tt' ...'
lsblk -l -n -p /dev/$d2 -o NAME,SIZE,PARTTYPE 2> /dev/null | grep ${d2}4 2> /dev/null | grep 100M 2> /dev/null | grep e6d6d379 &> /dev/null
if [ $? -eq 0 ]; then tr='PASS'; else tr='ERROR'; fi
echo '... '$tr
echo "{\"id\": 9, \"name\": \"$tt\", \"result\": \"$tr\"}, " >> $logfile


tt="Testing partition #5 of /dev/$d2 disk"
echo '* '$tt' ...'
lsblk -l -n -p /dev/$d2 -o NAME,SIZE,PARTTYPE 2> /dev/null | grep ${d2}5 2> /dev/null | grep 300M 2> /dev/null | grep e6d6d379 &> /dev/null
if [ $? -eq 0 ]; then tr='PASS'; else tr='ERROR'; fi
echo '... '$tr
echo "{\"id\": 10, \"name\": \"$tt\", \"result\": \"$tr\"}, " >> $logfile


tt="Testing partition #6 of /dev/$d2 disk"
echo '* '$tt' ...'
lsblk -l -n -p /dev/$d2 -o NAME,SIZE,PARTTYPE 2> /dev/null | grep ${d2}6 2> /dev/null | grep 300M 2> /dev/null | grep e6d6d379 &> /dev/null
if [ $? -eq 0 ]; then tr='PASS'; else tr='ERROR'; fi
echo '... '$tr
echo "{\"id\": 11, \"name\": \"$tt\", \"result\": \"$tr\"}, " >> $logfile


tt='Testing mount folder structure'
echo '* '$tt' ...'
ls -al /addon/{xfs,ext4,lvm} &> /dev/null
if [ $? -eq 0 ]; then tr='PASS'; else tr='ERROR'; fi
echo '... '$tr
echo "{\"id\": 12, \"name\": \"$tt\", \"result\": \"$tr\"}, " >> $logfile


tt='Testing partition #1 for filesystem and mount point'
echo '* '$tt' ...'
lsblk -n -o NAME,FSTYPE /dev/${d2}1 2> /dev/null | grep xfs &> /dev/null && lsblk -n -o NAME,MOUNTPOINT /dev/${d2}1 2> /dev/null | grep /addon/xfs &> /dev/null && cat /etc/fstab | grep /addon/xfs &> /dev/null
if [ $? -eq 0 ]; then tr='PASS'; else tr='ERROR'; fi
echo '... '$tr
echo "{\"id\": 13, \"name\": \"$tt\", \"result\": \"$tr\"}, " >> $logfile


tt='Testing partition #2 for filesystem and mount point'
echo '* '$tt' ...'
lsblk -n -o NAME,FSTYPE /dev/${d2}2 2> /dev/null | grep swap &> /dev/null && lsblk -n -o NAME,MOUNTPOINT /dev/${d2}2 2> /dev/null | grep '[SWAP]' &> /dev/null
if [ $? -eq 0 ]; then tr='PASS'; else tr='ERROR'; fi
echo '... '$tr
echo "{\"id\": 14, \"name\": \"$tt\", \"result\": \"$tr\"}, " >> $logfile


tt='Testing partition #3 for filesystem and mount point'
echo '* '$tt' ...'
lsblk -n -o NAME,FSTYPE /dev/${d2}3 2> /dev/null | grep ext4 &> /dev/null && lsblk -n -o NAME,MOUNTPOINT /dev/${d2}3 2> /dev/null | grep /addon/ext4 &> /dev/null && cat /etc/fstab | grep /addon/ext4 &> /dev/null
if [ $? -eq 0 ]; then tr='PASS'; else tr='ERROR'; fi
echo '... '$tr
echo "{\"id\": 15, \"name\": \"$tt\", \"result\": \"$tr\"}, " >> $logfile


tt='Testing that partitions #4, #5, and #6 are initialized as PVs'
echo '* '$tt' ...'
pvs 2> /dev/null | grep $d2 | wc -l | grep 3 &> /dev/null
if [ $? -eq 0 ]; then tr='PASS'; else tr='ERROR'; fi
echo '... '$tr
echo "{\"id\": 16, \"name\": \"$tt\", \"result\": \"$tr\"}, " >> $logfile


tt='Testing that all three PVs are included in a VG'
echo '* '$tt' ...'
vgs 2> /dev/null | grep vg_addon | grep 3 &> /dev/null
if [ $? -eq 0 ]; then tr='PASS'; else tr='ERROR'; fi
echo '... '$tr
echo "{\"id\": 17, \"name\": \"$tt\", \"result\": \"$tr\"}, " >> $logfile


tt='Testing that LV is created on top of the VG'
echo '* '$tt' ...'
lvs 2> /dev/null | grep vg_addon | grep lv_addon &> /dev/null
if [ $? -eq 0 ]; then tr='PASS'; else tr='ERROR'; fi
echo '... '$tr
echo "{\"id\": 18, \"name\": \"$tt\", \"result\": \"$tr\"}, " >> $logfile


tt='Testing that LV is resized to 100% of the VG and mounted'
echo '* '$tt' ...'
# lsblk -l | grep /addon/lvm | wc -l | grep 3 &> /dev/null
lsblk -l | grep vg_addon-lv_addon | grep 688M | grep /addon/lvm &> /dev/null
if [ $? -eq 0 ]; then tr='PASS'; else tr='ERROR'; fi
echo '... '$tr
echo "{\"id\": 19, \"name\": \"$tt\", \"result\": \"$tr\"}, " >> $logfile


tt='Testing that LV registed in the /etc/fstab file'
echo '* '$tt' ...'
grep '/addon/lvm' /etc/fstab &> /dev/null
if [ $? -eq 0 ]; then tr='PASS'; else tr='ERROR'; fi
echo '... '$tr
echo "{\"id\": 20, \"name\": \"$tt\", \"result\": \"$tr\"} " >> $logfile

echo "]" >> $logfile

echo '}' >> $logfile

if [ $app == 'curl' ]; then
  curl --request POST --url https://courses.zahariev.pro/ --header 'content-type: application/json' --data @$logfile
else
  wget --quiet --method POST --header 'content-type: application/json' --body-file=$logfile --output-document - https://courses.zahariev.pro/
fi
