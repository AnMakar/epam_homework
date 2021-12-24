## Repositories and Packages
​
# - Use rpm for the following tasks:
# 1. Download sysstat package.
sudo yum --downloadonly --downloaddir=/home/anme/ install sysstat
# 2. Get information from downloaded sysstat package file.
rpm -qp sysstat-10.1.5-19.el7.x86_64.rpm -i
# Name        : sysstat
# Version     : 10.1.5
# Release     : 19.el7
# Architecture: x86_64
# Install Date: (not installed)
# Group       : Applications/System
# Size        : 1172488
# License     : GPLv2+
# Signature   : RSA/SHA256, Fri 03 Apr 2020 05:08:48 PM EDT, Key ID 24c6a8a7f4a80eb5
# Source RPM  : sysstat-10.1.5-19.el7.src.rpm
# Build Date  : Wed 01 Apr 2020 12:36:37 AM EDT
# Build Host  : x86-01.bsys.centos.org
# Relocations : (not relocatable)
# Packager    : CentOS BuildSystem <http://bugs.centos.org>
# Vendor      : CentOS
# URL         : http://sebastien.godard.pagesperso-orange.fr/
# Summary     : Collection of performance monitoring tools for Linux
# Description :
# The sysstat package contains sar, sadf, mpstat, iostat, pidstat, nfsiostat-sysstat,
# tapestat, cifsiostat and sa tools for Linux.
# The sar command collects and reports system activity information. This
# information can be saved in a file in a binary format for future inspection. The
# statistics reported by sar concern I/O transfer rates, paging activity,
# process-related activities, interrupts, network activity, memory and swap space
# utilization, CPU utilization, kernel activities and TTY statistics, among
# others. Both UP and SMP machines are fully supported.
# The sadf command may be used to display data collected by sar in various formats
# (CSV, XML, etc.).
# The iostat command reports CPU utilization and I/O statistics for disks.
# The tapestat command reports statistics for tapes connected to the system.
# The mpstat command reports global and per-processor statistics.
# The pidstat command reports statistics for Linux tasks (processes).
# The nfsiostat-sysstat command reports I/O statistics for network file systems.
# The cifsiostat command reports I/O statistics for CIFS file systems.

3. Install sysstat package and get information about files installed by this package.
sudo rpm -i sysstat-10.1.5-19.el7.x86_64.rpm
# error: Failed dependencies:
#         libsensors.so.4()(64bit) is needed by sysstat-10.1.5-19.el7.x86_64
# для установки нужно удовлетворение зависимостей, но стоит задача просто установить
sudo rpm -i sysstat-10.1.5-19.el7.x86_64.rpm --nodeps # но так установка прошла без каких-либо выводов. Для установки лучше всего использовать -ivh, так можно получить доп. инфу во время установки. --nodeps позволит установить без учета зависимостей
sudo rpm -ivh sysstat-10.1.5-19.el7.x86_64.rpm --nodeps
# Preparing...                          ################################# [100%]
# Updating / installing...
#    1:sysstat-10.1.5-19.el7            ################################# [100%]


​
- Add NGINX repository (need to find repository config on https://www.nginx.com/) and complete the following tasks using yum:
# На ресурсе https://www.nginx.com/resources/wiki/start/topics/tutorials/install/ нашел инструкцию по добавлению репозитория ngnix. Создал в /etc/yum.repos.d/ файл nginx.repo с текстом:
# [nginx]
# name=nginx repo
# baseurl=https://nginx.org/packages/centos/$releasever/$basearch/
# gpgcheck=0
# enabled=1

yum repolist | grep nginx
# nginx/7/x86_64                      nginx repo                               256

# Можно еще добавить репозиторий с помощью yum-config-manager
sudo yum-config-manager --add-repo /etc/yum.repos.d/nginx.repo # без указания пути yum-config-manager искал файл репозитория в текущей директории. В таком случае можно просто под боком держать пачку нужных репозиториев, чтобы потом их просто подгрузить.
# Loaded plugins: fastestmirror
# adding repo from: /etc/yum.repos.d/nginx.repo
# grabbing file /etc/yum.repos.d/nginx.repo to /etc/yum.repos.d/nginx.repo
# repo saved to /etc/yum.repos.d/nginx.repo

# 1. Check if NGINX repository enabled or not.
yum repolist enabled | grep nginx
# nginx/7/x86_64                      nginx repo                               256

# 2. Install NGINX.
# sudo yum install nginx -y
# Loaded plugins: fastestmirror
# Loading mirror speeds from cached hostfile
#  * base: mirror.logol.ru
#  * extras: mirror.reconn.ru
#  * updates: mirror.corbina.net
# Resolving Dependencies
# --> Running transaction check
# ---> Package nginx.x86_64 1:1.20.2-1.el7.ngx will be installed
# --> Finished Dependency Resolution
#
# Dependencies Resolved
#
# =======================================================================================
#  Package         Arch             Version                        Repository       Size
# =======================================================================================
# Installing:
#  nginx           x86_64           1:1.20.2-1.el7.ngx             nginx           790 k
#
# Transaction Summary
# =======================================================================================
# Install  1 Package
#
# Total download size: 790 k
# Installed size: 2.8 M
# Downloading packages:
# nginx-1.20.2-1.el7.ngx.x86_64.rpm                               | 790 kB  00:00:06
# Running transaction check
# Running transaction test
# Transaction test succeeded
# Running transaction
#   Installing : 1:nginx-1.20.2-1.el7.ngx.x86_64                                     1/1
# ----------------------------------------------------------------------
#
# Thanks for using nginx!
#
# Please find the official documentation for nginx here:
# * https://nginx.org/en/docs/
#
# Please subscribe to nginx-announce mailing list to get
# the most important news about nginx:
# * https://nginx.org/en/support.html
#
# Commercial subscriptions for nginx are available on:
# * https://nginx.com/products/
#
# ----------------------------------------------------------------------
#   Verifying  : 1:nginx-1.20.2-1.el7.ngx.x86_64                                     1/1
#
# Installed:
#   nginx.x86_64 1:1.20.2-1.el7.ngx
#
# Complete!

# 3. Check yum history and undo NGINX installation.
sudo yum history info 7
# Loaded plugins: fastestmirror
# Transaction ID : 7
# Begin time     : Fri Dec 24 07:40:34 2021
# Begin rpmdb    : 338:75b957abae40b571240286ed67ad3cd9ccc89878
# End time       :            07:40:35 2021 (1 seconds)
# End rpmdb      : 339:1126fd74b6a7dbdd5614c20551c77cea7da6b43f
# User           :  <anme>
# Return-Code    : Success
# Command Line   : install nginx -y
# Transaction performed with:
#     Installed     rpm-4.11.3-45.el7.x86_64                        @anaconda
#     Installed     yum-3.4.3-168.el7.centos.noarch                 @anaconda
#     Installed     yum-plugin-fastestmirror-1.1.31-54.el7_8.noarch @anaconda
# Packages Altered:
#     Install nginx-1:1.20.2-1.el7.ngx.x86_64 @nginx
# Scriptlet output:
#    1 ----------------------------------------------------------------------
#    2
#    3 Thanks for using nginx!
#    4
#    5 Please find the official documentation for nginx here:
#    6 * https://nginx.org/en/docs/
#    7
#    8 Please subscribe to nginx-announce mailing list to get
#    9 the most important news about nginx:
#   10 * https://nginx.org/en/support.html
#   11
#   12 Commercial subscriptions for nginx are available on:
#   13 * https://nginx.com/products/
#   14
#   15 ----------------------------------------------------------------------
# history info

sudo yum history undo 7
# Loaded plugins: fastestmirror
# Undoing transaction 7, from Fri Dec 24 07:40:34 2021
#     Install nginx-1:1.20.2-1.el7.ngx.x86_64 @nginx
# Resolving Dependencies
# --> Running transaction check
# ---> Package nginx.x86_64 1:1.20.2-1.el7.ngx will be erased
# --> Finished Dependency Resolution
#
# Dependencies Resolved
#
# =====================================================================================================================================
#  Package                    Arch                        Version                                    Repository                   Size
# =====================================================================================================================================
# Removing:
#  nginx                      x86_64                      1:1.20.2-1.el7.ngx                         @nginx                      2.8 M
#
# Transaction Summary
# =====================================================================================================================================
# Remove  1 Package
#
# Installed size: 2.8 M
# Is this ok [y/N]: y
# Downloading packages:
# Running transaction check
# Running transaction test
# Transaction test succeeded
# Running transaction
#   Erasing    : 1:nginx-1.20.2-1.el7.ngx.x86_64                                                                                   1/1
#   Verifying  : 1:nginx-1.20.2-1.el7.ngx.x86_64                                                                                   1/1
#
# Removed:
#   nginx.x86_64 1:1.20.2-1.el7.ngx
#
# Complete!

# 4. Disable NGINX repository.
sudo yum-config-manager --disable nginx
sudo yum repolist disabled | grep nginx
# nginx/7/x86_64                         nginx repo

# 5. Remove sysstat package installed in the first task.
sudo yum remove sysstat
# Loaded plugins: fastestmirror
# Resolving Dependencies
# --> Running transaction check
# ---> Package sysstat.x86_64 0:10.1.5-19.el7 will be erased
# --> Finished Dependency Resolution
#
# Dependencies Resolved
#
# =====================================================================================================================================
#  Package                      Arch                        Version                               Repository                      Size
# =====================================================================================================================================
# Removing:
#  sysstat                      x86_64                      10.1.5-19.el7                         installed                      1.1 M
#
# Transaction Summary
# =====================================================================================================================================
# Remove  1 Package
#
# Installed size: 1.1 M
# Is this ok [y/N]: y
# Downloading packages:
# Running transaction check
# Running transaction test
# Transaction test succeeded
# Running transaction
#   Erasing    : sysstat-10.1.5-19.el7.x86_64                                                                                      1/1
#   Verifying  : sysstat-10.1.5-19.el7.x86_64                                                                                      1/1
#
# Removed:
#   sysstat.x86_64 0:10.1.5-19.el7
#
# Complete!

# 6. Install EPEL repository and get information about it.
# Насколько выяснил, EPEL в centos ставится легко с помощью коамнды
yum install epel-release
yum repolist | grep epel
 # * epel: mirror.speedpartner.de
# epel/x86_64           Extra Packages for Enterprise Linux 7 - x86_64      13,701

# 7. Find how much packages provided exactly by EPEL repository.
yum repoinfo epel | grep Repo-pkgs
# Repo-pkgs    : 13,701

# 8. Install ncdu package from EPEL repo.
sudo yum --disablerepo="*" --enablerepo=epel install ncdu # выяснил такую команду, с помощью которой можно на времся установки отключить все репозитории и включит конкретный. Правда не очень удобно и красиво выглядит, было бы удобнее, будь какая-то опция для загрузки из определенного репозитория.
​
# *Extra task:
    # Need to create an rpm package consists of a shell script and a text file. The script should output words count stored in file.
# Для создания rpm файлов есть утилита rpm-build

## Work with files
​
# 1. Find all regular files below 100 bytes inside your home directory.
find ~/ -type f -size -100b

2. Find an inode number and a hard links count for the root directory. The hard link count should be about 17. Why?
ls -lai /
# total 20
#       64 dr-xr-xr-x.  18 root root  237 Dec 12 01:18 .
#       64 dr-xr-xr-x.  18 root root  237 Dec 12 01:18 ..
#      120 lrwxrwxrwx.   1 root root    7 Nov 25 11:30 bin -> usr/bin
#       64 dr-xr-xr-x.   5 root root 4096 Nov 25 11:37 boot
#        3 drwxr-xr-x.  20 root root 3120 Dec 24 04:10 dev
#  4194369 drwxr-xr-x.  76 root root 8192 Dec 24 08:55 etc
#  8464286 drwxr-xr-x.  18 root root  224 Dec 12 05:22 home
#      124 lrwxrwxrwx.   1 root root    7 Nov 25 11:30 lib -> usr/lib
#       82 lrwxrwxrwx.   1 root root    9 Nov 25 11:30 lib64 -> usr/lib64
# 12583333 drwxr-xr-x.   2 root root    6 Apr 11  2018 media
#       83 drwxr-xr-x.   2 root root    6 Apr 11  2018 mnt
#  4195292 drwxr-xr-x.   2 root root   36 Dec 17 17:01 opt
#        1 dr-xr-xr-x. 109 root root    0 Dec 24 04:10 proc
#  8409153 dr-xr-x---.   6 root root  190 Dec 24 07:24 root
#     7205 drwxr-xr-x.  24 root root  740 Dec 24 11:33 run
#      125 lrwxrwxrwx.   1 root root    8 Nov 25 11:30 sbin -> usr/sbin
# 12956658 drwxr-xr-x.   3 root root   19 Dec 12 01:18 share
#  8464287 drwxr-xr-x.   2 root root    6 Apr 11  2018 srv
#        1 dr-xr-xr-x.  13 root root    0 Dec 24 04:10 sys
#  4194376 drwxrwxrwt.  14 root root 4096 Dec 24 08:55 tmp
#  8464248 drwxr-xr-x.  13 root root  155 Nov 25 11:30 usr
# 12582977 drwxr-xr-x.  19 root root  267 Nov 25 11:37 var
stat --format="inode number: %i, number of hard links: %h" /
# inode number: 64, number of hard links: 18
# Ну, их не 17, а 18
sudo find / -inum 64
# /
# /boot
# /sys/devices/system/cpu/vulnerabilities/tsx_async_abort
# /sys/kernel/debug/tracing/per_cpu/cpu0/trace_pipe_raw
# а вот так показывает только 4. Но откуда 18? Есть маленькая идея:
sudo mkdir /testfolder
ls -lia /
# total 20
#      64 dr-xr-xr-x.  19 root root  255 Dec 24 12:21 .
#      64 dr-xr-xr-x.  19 root root  255 Dec 24 12:21 ..
#     120 lrwxrwxrwx.   1 root root    7 Nov 25 11:30 bin -> usr/bin
#      64 dr-xr-xr-x.   5 root root 4096 Nov 25 11:37 boot
#       3 drwxr-xr-x.  20 root root 3120 Dec 24 04:10 dev
# 4194369 drwxr-xr-x.  76 root root 8192 Dec 24 08:55 etc
# 8464286 drwxr-xr-x.  18 root root  224 Dec 12 05:22 home
#     124 lrwxrwxrwx.   1 root root    7 Nov 25 11:30 lib -> usr/lib
#      82 lrwxrwxrwx.   1 root root    9 Nov 25 11:30 lib64 -> usr/lib64
# 12583333 drwxr-xr-x.   2 root root    6 Apr 11  2018 media
#      83 drwxr-xr-x.   2 root root    6 Apr 11  2018 mnt
# 4195292 drwxr-xr-x.   2 root root   36 Dec 17 17:01 opt
#       1 dr-xr-xr-x. 107 root root    0 Dec 24 04:10 proc
# 8409153 dr-xr-x---.   6 root root  190 Dec 24 07:24 root
#    7205 drwxr-xr-x.  24 root root  740 Dec 24 12:21 run
#     125 lrwxrwxrwx.   1 root root    8 Nov 25 11:30 sbin -> usr/sbin
# 12956658 drwxr-xr-x.   3 root root   19 Dec 12 01:18 share
# 8464287 drwxr-xr-x.   2 root root    6 Apr 11  2018 srv
#       1 dr-xr-xr-x.  13 root root    0 Dec 24 04:10 sys
# 8462289 drwxr-xr-x.   2 root root    6 Dec 24 12:21 testfolder
# 4194376 drwxrwxrwt.  14 root root 4096 Dec 24 08:55 tmp
# 8464248 drwxr-xr-x.  13 root root  155 Nov 25 11:30 usr
# 12582977 drwxr-xr-x.  19 root root  267 Nov 25 11:37 var
# теперь ссылок 19. Вероятно каждая дочерняя папка из / является ссылкой на корень, так же как и любая созданная папка в директории уже имеет две ссылки на себя (оригинал и . внутри этой директории), и любая созданная внутри папка будет создавать еще одну ссылку на родительскую директорию.
# Таким образом 17 ссылок на / это уже сразу же по умолчанию существующие директории в /, плюс . и .., симлинки не считаются, итого должно быть 17 в новенькой системе.

stat --format=%i /
# 64

3. Check what inode numbers have "/" and "/boot" directory. Why?
# можно было бы просто посмотреть в графу inode в команде stat /, а можно уточнить с помощью опции
stat --format=%i /
# 64
stat -c%i /boot
# 64
sudo find / -inum 64
# /
# /boot
# /sys/devices/system/cpu/vulnerabilities/tsx_async_abort
# /sys/kernel/debug/tracing/per_cpu/cpu0/trace_pipe_raw
# Inode 64 содержит в себе 4 директории, в том числе / и /boot.

# Насколько я понял, / и /boot это разные точки монтирования разных файловых систем, и они могут иметь один номер иноды их корневой файловой системы. Можно попробовать проверить это
# 64 dr-xr-xr-x.  17 root root  224 Nov 25 11:36 .
# 64 dr-xr-xr-x.   5 root root 4096 Nov 25 11:37 boot
umount /boot
# 64 dr-xr-xr-x.  17 root root  224 Nov 25 11:36 .
# 67 drwxr-xr-x.   2 root root    6 Nov 25 11:30 boot
# ну вот, теперь они различаются

# 4. Check the root directory space usage by du command. Compare it with an information from df. If you find differences, try to find out why it happens.
sudo du -ks /
[sudo] password for anme:
# du: cannot access ‘/proc/17506/task/17506/fd/4’: No such file or directory
# du: cannot access ‘/proc/17506/task/17506/fdinfo/4’: No such file or directory
# du: cannot access ‘/proc/17506/fd/3’: No such file or directory
# du: cannot access ‘/proc/17506/fdinfo/3’: No such file or directory
# 2198684 /

df -k | grep centos-root
# /dev/mapper/centos-root   6486016 2127512   4358504  33% /
# du 2198684 vs. df 2127512
# du, видимо, проверяет в том числе и точки монтирования в корневой системе, а df проверяет конкретное устройство без точек монтирования

# "df (disk free) выводит список всех файловых систем по именам устройств с указанием размера, показывает точки монтирования и количество свободного/занятого пространства.""
# "du (disk usage) – используется для оценки занимаемого файлового пространства. Показывает размер файлов и каталогов, как в совокупности, так и по отдельности.""

# 5. Check disk space usage of /var/log directory using ncdu
ncdu /var/log

# --- /var/log ------------------------------------------------------------------------------------------------------------------------
#     4.5 MiB [###################]  messages-20211212
#     3.8 MiB [################   ]  messages-20211219
#     1.9 MiB [#######            ]  messages
#     1.7 MiB [#######            ] /anaconda
#   668.0 KiB [##                 ]  messages-20211128
#   412.0 KiB [#                  ]  messages-20211205
#    80.0 KiB [                   ]  wtmp
#    68.0 KiB [                   ]  secure-20211219
#    36.0 KiB [                   ]  dmesg
#    36.0 KiB [                   ]  dmesg.old
#    32.0 KiB [                   ] /tuned
#    28.0 KiB [                   ]  secure
#    24.0 KiB [                   ]  secure-20211212
#    20.0 KiB [                   ]  lastlog
#    20.0 KiB [                   ]  cron-20211212
#    20.0 KiB [                   ]  cron-20211219
#    20.0 KiB [                   ]  boot.log-20211218
#    20.0 KiB [                   ]  boot.log-20211219
#    12.0 KiB [                   ]  btmp
#    12.0 KiB [                   ]  secure-20211128
#    12.0 KiB [                   ]  boot.log-20211224
#     8.0 KiB [                   ]  tallylog
#     8.0 KiB [                   ]  boot.log-20211217
#     8.0 KiB [                   ]  boot.log-20211210
#     8.0 KiB [                   ]  boot.log-20211216
#     8.0 KiB [                   ]  boot.log-20211208
#     8.0 KiB [                   ]  cron
#     8.0 KiB [                   ]  maillog
#     8.0 KiB [                   ]  maillog-20211219
#     8.0 KiB [                   ]  maillog-20211212
#     8.0 KiB [                   ]  cron-20211128
#     8.0 KiB [                   ]  maillog-20211128
#     4.0 KiB [                   ]  cron-20211205
#     4.0 KiB [                   ]  firewalld
#     4.0 KiB [                   ]  secure-20211205
#     4.0 KiB [                   ]  yum.log
#     4.0 KiB [                   ]  btmp-20211205
#     4.0 KiB [                   ]  maillog-20211205
#     4.0 KiB [                   ]  grubby_prune_debug
# !   0.0   B [                   ] /audit
#     0.0   B [                   ] /nginx
# e   0.0   B [                   ] /rhsm
# e   0.0   B [                   ] /chrony
#     0.0   B [                   ]  spooler-20211219
#     0.0   B [                   ]  spooler-20211212
#     0.0   B [                   ]  spooler-20211205
#     0.0   B [                   ]  spooler-20211128
#     0.0   B [                   ]  spooler
#     0.0   B [                   ]  boot.log
