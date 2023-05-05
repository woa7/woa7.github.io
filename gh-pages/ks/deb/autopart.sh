#!/bin/sh

#debconf-set-selections /tmp/salstar.selections

# partition definition
parts_root=/
parts_swap=swap
parts_boot=/boot
parts_var=/var
parts_home=/home
parts_tmp=/tmp
parts_www=/var/www
parts_mysql=/var/lib/mysql
parts_pgsql=/var/lib/pgsql
parts_mongodb=/var/lib/mongodb
parts_redis=/var/lib/redis
parts_squid=/var/spool/squid
parts_opt=/opt

parts=$(tr ' ' '\n' < /proc/cmdline | grep '^part=' | sed 's/^part=//' | tr , ' ')
disks=$(tr ' ' '\n' < /proc/cmdline | grep '^disks*=' | sed 's/^disks*=//')
fs="" #"--fstype=ext4"
cfg1=/tmp/salstar.preseed
cfgraid=/tmp/raid.preseed
touch $cfgraid

mirror=0
if echo $disks | grep -q ,; then
  mirror=1
  raid=1
  disk1=$(echo $disks | cut -d, -f1)
  disk2=$(echo $disks | cut -d, -f2)
  method="raid"
  echo "d-i partman-auto/disk string /dev/$disk1 /dev/$disk2"
  echo "d-i partman-auto-raid/recipe string \\" >> $cfgraid
elif [ "$disks" ]; then
  method="regular"
  echo "d-i partman-auto/disk string /dev/$disks"
fi >> $cfg1

create_raid() {
  [ $counter -gt 0 ] && echo "  . \\"
  echo "  $size $size2 $size raid \\"
  if [ "$raid" = "1" ]; then
    echo "    \$primary{ } \$bootable{ } \\"
  fi
  echo "    \$lvmignore{ } \\"
  echo "    method{ raid } \\"
  if [ "$partdir" = "swap" ]; then
    fs="swap"
    partdir="-"
  elif [ "$name" = "vg" ]; then
    fs="lvm"
    partdir="-"
    #echo "    vg_name{ $vg } \\"
  else
    fs="ext4"
    echo "    filesystem{ $fs } \\"
    echo "    mountpoint{ $partdir } \\"
  fi
  # how to construct raid
  [ $raid -gt 1 ] && echo "  . \\" >> $cfgraid
  echo "  1 2 0 $fs $partdir /dev/vda$raid#/dev/vdb$raid \\" >> $cfgraid
  raid=$((raid+1))
  if [ "$raid" = "2" ]; then
    raid=5
  fi
}

create_part() {
  [ $counter -gt 0 ] && echo "  . \\"
  if [ "$partdir" = "swap" ]; then
    echo "  $size $size2 $size linux-swap \\"
    if [ "$vg" ]; then
      echo "    \$lvmok{ } \$defaultignore{ } \\"
    fi
    echo "    method{ swap } format{ } \\"
  else
    echo "  $size $size2 $size ext4 \\"
    if [ "$partdir" = "/" ]; then
      echo "   \$primary{ } \$bootable{ } \\"
    fi
    if [ "$vg" ]; then
      echo "    \$lvmok{ } \$defaultignore{ } \\"
    fi
    echo "    method{ format } format{ } \\"
    echo "    use_filesystem{ } filesystem{ ext4 } \\"
    echo "    mountpoint{ $partdir } \\"
  fi
}

counter=0
echo "d-i partman-auto/expert_recipe string multiraid :: \\" >> $cfg1
for part in $parts; do
  name=$(echo $part | cut -d= -f1)
  value=$(echo $part | cut -d= -f2)
  #echo "# $part, mirror=$mirror, vg=$vg"
  if [ "$name" = "vg" ]; then
    if [ "$method" = "regular" ]; then
      method="lvm"
    fi
    vg=$value
    if [ $mirror = 1 ]; then
      create_raid
      raid=$((raid+1))
    fi
    continue
  fi
  size=$((value*1024))
  size2=$((size*1024))
  partdir=$(eval echo \$parts_$name)
  if [ "$vg" ]; then
    create_part
  elif [ $mirror = 1 ]; then
    create_raid
  else
    create_part
  fi
  counter=$((counter+1))
done >> $cfg1
#echo "  . 1 1 1000000 ext3 \$lvmok{ } \$defaultignore{ }" >> $cfg1
echo "  ." >> $cfg1
if [ -s $cfgraid ]; then
  # finish non empty raid configuration file
  echo "  ." >> $cfgraid
fi

echo "d-i partman-auto/method string $method" >> $cfg1

debconf-set-selections /tmp/salstar.preseed
debconf-set-selections /tmp/raid.preseed

exit 0
