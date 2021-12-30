# 1. Imagine you was asked to add new partition to your host for backup purposes. To simulate appearance of new physical disk in your server, please create new disk in Virtual Box (5 GB) and attach it to your virtual machine.
# Создаю в VB диск centos_backup.vdi и подключаю к виртуальной машине

# Also imagine your system started experiencing RAM leak in one of the applications, thus while developers try to debug and fix it, you need to mitigate OutOfMemory errors; you will do it by adding some swap space.
# /dev/sdc - 5GB disk, that you just attached to the VM (in your case it may appear as /dev/sdb, /dev/sdc or other, it doesn't matter)

# 1.1. Create a 2GB   !!! GPT !!!   partition on /dev/sdc of type "Linux filesystem" (means all the following partitions created in the following steps on /dev/sdc will be GPT as well)
fdisk /dev/sdb
# Command (m for help):
g # для создания таблицы GPT
n # для создания нового раздела
# Partition number (1-128, default 1): 1
# First sector (2048-10485726, default 2048): 2048
# Last sector, +sectors or +size{K,M,G,T,P} (2048-10485726, default 10485726): +2G # раздел размером 2Гб
# Created partition 2
p
# Disk /dev/sdb: 5368 MB, 5368709120 bytes, 10485760 sectors
# Units = sectors of 1 * 512 = 512 bytes
# Sector size (logical/physical): 512 bytes / 512 bytes
# I/O size (minimum/optimal): 512 bytes / 512 bytes
# Disk label type: gpt
# Disk identifier: ADEF23C4-28E9-4332-90CB-7D7FCEE5B484
# #         Start          End    Size  Type            Name
#  1         2048      4196351      2G  Linux filesyste
# по умолчанию тип раздела установился на Linux filesystem, поэтому незачем предпринимать что-то еще

# 1.2. Create a 512MB partition on /dev/sdc of type "Linux swap"
n
# Partition number (2-128, default 2): 2
# First sector (4196352-10485726, default 4196352):
# Last sector, +sectors or +size{K,M,G,T,P} (4196352-10485726, default 10485726): +512M
# Created partition 2
t # для смены типа раздела
# Partition number (1,2, default 2): 2
# Partition type (type L to list all types): 19
# Changed type of partition 'Linux filesystem' to 'Linux swap'

w # Принять изменения
# The partition table has been altered!
# Calling ioctl() to re-read partition table.
# Syncing disks.

lsblk
# NAME            MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
# sda               8:0    0    8G  0 disk
# ├─sda1            8:1    0    1G  0 part /boot
# └─sda2            8:2    0    7G  0 part
#   ├─centos-root 253:0    0  6.2G  0 lvm  /
#   └─centos-swap 253:1    0  820M  0 lvm  [SWAP]
# sdb               8:16   0    5G  0 disk
# ├─sdb1            8:17   0    2G  0 part
# └─sdb2            8:18   0  512M  0 part
# sr0              11:0    1 1024M  0 rom

sudo blkid
# /dev/sda1: UUID="53497d14-b3ec-448b-9018-eb2ec162a882" TYPE="xfs"
# /dev/sda2: UUID="Pko2w4-dCjF-NAtj-BwJh-b9WS-0zQV-xOp2HQ" TYPE="LVM2_member"
# /dev/sdb1: UUID="c96fa7b6-8aaf-4ded-8782-239c543e1dcc" TYPE="xfs" PARTUUID="87150f0a-727a-4713-a67a-404d0dafb437"
# /dev/sdb2: UUID="54f3d209-121f-4909-ade5-3a2919e8eac6" TYPE="swap" PARTUUID="5b27aa62-86ec-4bc9-9f04-45e6f6b0c6b3"
# /dev/mapper/centos-root: UUID="74a53497-b9a3-48c1-8e50-a6abe36bcdca" TYPE="xfs"
# /dev/mapper/centos-swap: UUID="607e9614-8863-4896-9f29-3a644611bddb" TYPE="swap"

# 1.3. Format the 2GB partition with an XFS file system
sudo mkfs -t xfs /dev/sdb1
# meta-data=/dev/sdb1              isize=512    agcount=4, agsize=131072 blks
#          =                       sectsz=512   attr=2, projid32bit=1
#          =                       crc=1        finobt=0, sparse=0
# data     =                       bsize=4096   blocks=524288, imaxpct=25
#          =                       sunit=0      swidth=0 blks
# naming   =version 2              bsize=4096   ascii-ci=0 ftype=1
# log      =internal log           bsize=4096   blocks=2560, version=2
#          =                       sectsz=512   sunit=0 blks, lazy-count=1
# realtime =none                   extsz=4096   blocks=0, rtextents=0

# 1.4. Initialize 512MB partition as swap space
sudo mkswap /dev/sdb2
# Setting up swapspace version 1, size = 524284 KiB
# no label, UUID=54f3d209-121f-4909-ade5-3a2919e8eac6

# 1.5. Configure the newly created XFS file system to persistently mount at /backup
sudo mkdir /backup
sudo mount /dev/sdb1 /backup
# для включения автомонтирования раздела нужнго прописать строчку в /etc/fstab
sudo nano /etc/fstab
# UUID="c96fa7b6-8aaf-4ded-8782-239c543e1dcc" /backup xfs default 0 0

# 1) filesystem - идентификатор диска. Можно сипользовать /dev/sdb2, но это не слишком надежно и однозначно
# 2) dir - точка монтирования.  For swap partitions, this field should be specified  as  none
# 3) type тип файловой системы
# 4) точка монтирования, ассоциированная с файловой системой
# 5) для дампов файловой системы. 0 - дампы не нужны
# 6) для определения порядка, в котором проверки файловой системы выполняются во время перезагрузки

# 1.6. Configure the newly created swap space to be enabled at boot
sudo swapon /dev/sdb2 # включение файла подкачки

# для включения файла подкачки после перезагрузки системы Linux нужно прописать в файле /etc/fstab строчку с UUID="607e9614-8863-4896-9f29-3a644611bddb", которую я получил из blkid выше
sudo nano /etc/fstab
# UUID="54f3d209-121f-4909-ade5-3a2919e8eac6" none swap sw 0 0

# 1.7. Reboot your host and verify that /dev/sdc1 is mounted at /backup and that your swap partition  (/dev/sdc2) is enabled
lsblk | grep sdb1
# ├─sdb1            8:17   0    2G  0 part /backup
swapon -s
# Filename                                Type            Size    Used    Priority
# /dev/dm-1                               partition       839676  0       -2
# /dev/sdb2                               partition       524284  0       -3

# 2. LVM. Imagine you're running out of space on your root device. As we found out during the lesson default CentOS installation should already have LVM, means you can easily extend size of your root device. So what are you waiting for? Just do it!
# 2.1. Create 2GB partition on /dev/sdc of type "Linux LVM"
fdisk /dev/sdb
n # новый раздел
3 # под номером 3
# по умолчанию
+2G 
t # изменить тип
3 # раздела 3
31 # тип 31. Linux LVM

# 2.2. Initialize the partition as a physical volume (PV)
lvm> pvcreate /dev/sdb3
  # Physical volume "/dev/sdb3" successfully created.


# 2.3. Extend the volume group (VG) of your root device using your newly created PV
lvm> vgextend centos /dev/sdb3
  # Volume group "centos" successfully extended


# 2.4. Extend your root logical volume (LV) by 1GB, leaving other 1GB unassigned
lvm> lvextend -L +1G /dev/centos/root /dev/sdb3
  # Size of logical volume centos/root changed from <6.20 GiB (1586 extents) to <7.20 GiB (1842 extents).
  # Logical volume centos/root successfully resized.

  lvdisplay /dev/centos/root
    # --- Logical volume ---
    # LV Path                /dev/centos/root
    # LV Name                root
    # VG Name                centos
    # LV UUID                jF80Vt-2XAj-qCZU-0hMW-sQmt-IPBJ-lwF84h
    # LV Write Access        read/write
    # LV Creation host, time localhost, 2021-12-29 17:54:29 +0300
    # LV Status              available
    # # open                 1
    # LV Size                <7.20 GiB
    # Current LE             1842
    # Segments               2
    # Allocation             inherit
    # Read ahead sectors     auto
    # - currently set to     8192
    # Block device           253:0

# 2.5. Check current disk space usage of your root device
df -h | grep root
# Filesystem               Size  Used Avail Use% Mounted on
# /dev/mapper/centos-root  6.2G  1.3G  5.0G  20% /

# 2.6. Extend your root device filesystem to be able to use additional free space of root LV
xfs_growfs / -d
# meta-data=/dev/mapper/centos-root isize=512    agcount=4, agsize=406016 blks
#          =                       sectsz=512   attr=2, projid32bit=1
#          =                       crc=1        finobt=0 spinodes=0
# data     =                       bsize=4096   blocks=1624064, imaxpct=25
#          =                       sunit=0      swidth=0 blks
# naming   =version 2              bsize=4096   ascii-ci=0 ftype=1
# log      =internal               bsize=4096   blocks=2560, version=2
#          =                       sectsz=512   sunit=0 blks, lazy-count=1
# realtime =none                   extsz=4096   blocks=0, rtextents=0
# data blocks changed from 1624064 to 1886208

# 2.7. Verify that after reboot your root device is still 1GB bigger than at 2.5.
df -h
# Filesystem               Size  Used Avail Use% Mounted on
# devtmpfs                 484M     0  484M   0% /dev
# tmpfs                    496M     0  496M   0% /dev/shm
# tmpfs                    496M  6.8M  489M   2% /run
# tmpfs                    496M     0  496M   0% /sys/fs/cgroup
# /dev/mapper/centos-root  7.2G  1.3G  6.0G  18% /
# /dev/sda1               1014M  137M  877M  14% /boot
# tmpfs                    100M     0  100M   0% /run/user/1000
