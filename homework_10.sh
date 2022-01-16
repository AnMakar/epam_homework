## Boot process

# 1. enable recovery options for grub, update main configuration file and find new item in grub2 config in /boot.
sudo cat /boot/grub2/grub.cfg | grep "menuentry " # конфигурация в меню загрузки до изменений
# menuentry 'CentOS Linux (3.10.0-1160.el7.x86_64) 7 (Core)' --class centos --class gnu-linux --class gnu --class os --unrestricted $menuentry_id_option 'gnulinux-3.10.0-1160.el7.x86_64-advanced-74a53497-b9a3-48c1-8e50-a6abe36bcdca' {
# menuentry 'CentOS Linux (0-rescue-808fd66c47ddd04a914a561554c7dc4b) 7 (Core)' --class centos --class gnu-linux --class gnu --class os --unrestricted $menuentry_id_option 'gnulinux-0-rescue-808fd66c47ddd04a914a561554c7dc4b-advanced-74a53497-b9a3-48c1-8e50-a6abe36bcdca' {


# Меняю в файле /etc/default/grub опцию GRUB_DISABLE_RECOVERY с true нап false
sudo nano /etc/default/grub
sudo grub2-mkconfig -o /boot/grub2/grub.cfg # обновляю конфигурацию Grub
# Generating grub configuration file ...
# Found linux image: /boot/vmlinuz-3.10.0-1160.el7.x86_64
# Found initrd image: /boot/initramfs-3.10.0-1160.el7.x86_64.img
# Found linux image: /boot/vmlinuz-0-rescue-808fd66c47ddd04a914a561554c7dc4b
# Found initrd image: /boot/initramfs-0-rescue-808fd66c47ddd04a914a561554c7dc4b.img
# done
sudo cat /boot/grub2/grub.cfg | grep "menuentry " # конфигурация в меню загрузки после изменений
# menuentry 'CentOS Linux (3.10.0-1160.el7.x86_64) 7 (Core)' --class centos --class gnu-linux --class gnu --class os --unrestricted $menuentry_id_option 'gnulinux-3.10.0-1160.el7.x86_64-advanced-74a53497-b9a3-48c1-8e50-a6abe36bcdca' {
# menuentry 'CentOS Linux (3.10.0-1160.el7.x86_64) 7 (Core) (recovery mode)' --class centos --class gnu-linux --class gnu --class os --unrestricted $menuentry_id_option 'gnulinux-3.10.0-1160.el7.x86_64-recovery-74a53497-b9a3-48c1-8e50-a6abe36bcdca' {
# menuentry 'CentOS Linux (0-rescue-808fd66c47ddd04a914a561554c7dc4b) 7 (Core)' --class centos --class gnu-linux --class gnu --class os --unrestricted $menuentry_id_option 'gnulinux-0-rescue-808fd66c47ddd04a914a561554c7dc4b-advanced-74a53497-b9a3-48c1-8e50-a6abe36bcdca' {
# menuentry 'CentOS Linux (0-rescue-808fd66c47ddd04a914a561554c7dc4b) 7 (Core) (recovery mode)' --class centos --class gnu-linux --class gnu --class os --unrestricted $menuentry_id_option 'gnulinux-0-rescue-808fd66c47ddd04a914a561554c7dc4b-recovery-74a53497-b9a3-48c1-8e50-a6abe36bcdca' {



# 2. modify option vm.dirty_ratio:
   # - using echo utility
# vm.dirty_ratio это параметр, содержащийся в файле /proc/sys/vm/dirty_ratio
cat /proc/sys/vm/dirty_ratio
# 30
echo 20 > /proc/sys/vm/dirty_ratio
cat /proc/sys/vm/dirty_ratio
# 20

   # - using sysctl utility
sysctl vm.dirty_ratio
# vm.dirty_ratio = 20
sysctl -w vm.dirty_ratio=30
# vm.dirty_ratio = 30

   # - using sysctl configuration files
cat /etc/sysctl.conf
# sysctl settings are defined through files in
# /usr/lib/sysctl.d/, /run/sysctl.d/, and /etc/sysctl.d/.
#
# Vendors settings live in /usr/lib/sysctl.d/.
# To override a whole file, create a new file with the same in
# /etc/sysctl.d/ and put new settings there. To override
# only specific settings, add a file with a lexically later
# name in /etc/sysctl.d/ and put new settings there.
#
# For more information, see sysctl.conf(5) and sysctl.d(5).
#
# vm.dirty_ratio = 20

# Значения sysctl загружаются во время загрузки системы из файла /etc/sysctl.conf.
reboot
sysctl vm.dirty_ratio
# vm.dirty_ratio = 20



# * extra
# 1. Inspect initrd file contents. Find all files that are related to XFS filesystem and give a short description for every file.
lsinitrd | grep xfs
# drwxr-xr-x   2 root     root            0 Nov 25 11:37 usr/lib/modules/3.10.0-1160.el7.x86_64/kernel/fs/xfs
# -rw-r--r--   1 root     root       335716 Oct 19  2020 usr/lib/modules/3.10.0-1160.el7.x86_64/kernel/fs/xfs/xfs.ko.xz
# -rwxr-xr-x   1 root     root          433 Sep 30  2020 usr/sbin/fsck.xfs
# -rwxr-xr-x   1 root     root       590208 Nov 25 11:37 usr/sbin/xfs_db
# -rwxr-xr-x   1 root     root          747 Sep 30  2020 usr/sbin/xfs_metadump
# -rwxr-xr-x   1 root     root       576720 Nov 25 11:37 usr/sbin/xfs_repair


# 2. Study dracut utility that is used for rebuilding initrd image. Give an example for adding driver/kernel module for your initrd and recreating it.
# 3. Explain the difference between ordinary and rescue initrd images.

## Selinux
# Disable selinux using kernel cmdline
getenforce
# Enforcing
sestatus
# SELinux status:                 enabled
# SELinuxfs mount:                /sys/fs/selinux
# SELinux root directory:         /etc/selinux
# Loaded policy name:             targeted
# Current mode:                   enforcing
# Mode from config file:          enforcing
# Policy MLS status:              enabled
# Policy deny_unknown status:     allowed
# Max kernel policy version:      31

reboot
# Во время загрузки операционной системы при выборе опций загрузки можно нажать клавишу "e" и изменить параметры загрузки. Добавляю туда в конце строки linux16 /vmlinuz-3.10.0... selinux=0. Нажимаю Ctrl+X для запуска.
getenforce
# Disabled



## Firewalls
# 1. Add rule using firewall-cmd that will allow SSH access to your server *only* from network 192.168.56.0/24 and interface enp0s8 (if your network and/on interface name differs - change it accordingly).
firewall-cmd --get-zones # список всех зон
# block dmz drop external home internal public trusted work
firewall-cmd --get-default-zone # зона по умолчанию
# public
firewall-cmd --get-active-zones # активная зона. Если будут отклонения от основной зоны, то тут появятся и другие активные зоны. Здесь мы видим, что на нашем сервере брандмауэр контролирует два сетевых интерфейса (enp0s3 и enp0s8). Управление обоими интерфейсами осуществляется в соответствии с правилами, заданными для зоны public.
# public
  # interfaces: enp0s3 enp0s8
firewall-cmd --zone=public --list-all
  # public (active)
  #   target: default
  #   icmp-block-inversion: no
  #   interfaces: enp0s3 enp0s8
  #   sources:
  #   services: dhcpv6-client ssh
  #   ports:
  #   protocols:
  #   masquerade: no
  #   forward-ports:
  #   source-ports:
  #   icmp-blocks:
  #   rich rules:

# по идее нужно сделать следующее
# - создать новую зону или использовать существующую
# - перенести в выбранную зону интерфейс enp0s8
# - добавить в новую зону сервис SSH
# - добавить source с IP
# - из зоны public убрать интерфейс enp0s3, чтобы все соединения шли только через enp0s8
# - попытаться подключиться через ssh
# насколько понял, firewalld не настраивается какими-нибудь конфиг-файлами, но есть xml-файлы по пути /usr/lib/firewalld/zones/. Использовать команды firewall-cmd для настройки мне кажется очень неудобным. Пожалуй, для настройки firewalld было бы наиболее удобно использовать графическую утилиту. Но ладно уж, буду пробовать командами

firewall-cmd --permanent --new-zone=newzone # опция --permanent делает правило постоянным, а в частности данная команда не работает без данной опции
# success
firewall-cmd --permanent --zone=newzone --change-interface=enp0s8
# success
firewall-cmd --permanent --zone=newzone --add-service=ssh
# Error: INVALID_ZONE: newzone
# похоже, нужна перезагрузка демона
firewall-cmd --reload
# success
firewall-cmd --zone=public --list-all # здесь интерфейс enp0s8 пропал
# public (active)
#   target: default
#   icmp-block-inversion: no
#   interfaces: enp0s3
#   sources:
#   services: dhcpv6-client ssh
#   ports:
#   protocols:
#   masquerade: no
#   forward-ports:
#   source-ports:
#   icmp-blocks:
#   rich rules:

firewall-cmd --zone=newzone --list-all # тут интерфейс enp0s8 появился
# newzone (active)
#   target: default
#   icmp-block-inversion: no
#   interfaces: enp0s8
#   sources:
#   services:
#   ports:
#   protocols:
#   masquerade: no
#   forward-ports:
#   source-ports:
#   icmp-blocks:
#   rich rules:

firewall-cmd --get-active-zones
# public
#   interfaces: enp0s3
# newzone
#   interfaces: enp0s8

firewall-cmd --permanent --zone=newzone --add-service=ssh
# success
firewall-cmd --permanent --zone=newzone --add-source=192.168.68.0/24 # ставлю IP в соответствии со своей сетью
# success

firewall-cmd --zone=newzone --list-all
# newzone (active)
#   target: default
#   icmp-block-inversion: no
#   interfaces: enp0s8
#   sources: 192.168.68.0/24
#   services: ssh
#   ports:
#   protocols:
#   masquerade: no
#   forward-ports:
#   source-ports:
#   icmp-blocks:
#   rich rules:

# дальше уберу из зоны public интерфейс enp0s3 и службу ssh, чтобы

firewall-cmd --zone=public --remove-interface=enp0s3
# success
firewall-cmd --zone=drop --remove-service=ssh
# success
firewall-cmd --reload

firewall-cmd --zone=newzone --list-all
# newzone (active)
#   target: default
#   icmp-block-inversion: no
#   interfaces: enp0s8
#   sources: 192.168.68.0/24
#   services: ssh
#   ports:
#   protocols:
#   masquerade: no
#   forward-ports:
#   source-ports:
#   icmp-blocks:
#   rich rules:

firewall-cmd --get-active-zones
  # newzone
  #   interfaces: enp0s8
  #   sources: 192.168.68.0/24



# 2. Shutdown firewalld and add the same rules via iptables.
systemctl stop firewalld
systemctl status firewalld
# ● firewalld.service - firewalld - dynamic firewall daemon
#    Loaded: loaded (/usr/lib/systemd/system/firewalld.service; enabled; vendor preset: enabled)
#    Active: inactive (dead) since Sun 2022-01-16 00:40:09 EST; 3s ago
#      Docs: man:firewalld(1)
#   Process: 688 ExecStart=/usr/sbin/firewalld --nofork --nopid $FIREWALLD_ARGS (code=exited, status=0/SUCCESS)
#  Main PID: 688 (code=exited, status=0/SUCCESS)

iptables -A INPUT -i enp0s8 -s 192.168.68.0/24 -p tcp --dport 22 -j ACCEPT

iptables -A INPUT -i enp0s8 -j REJECT
iptables -A INPUT -i enp0s3 -j REJECT

iptables -nvL

# в итоге я много промучился с данными командами, пробовал блокировать все входящие подключения и отдельно разрешать хотя бы только icmp пакеты, чисто для проверки, но правила не работают так как должны, хотя с теоретической части всё должно бы работать.
# почему-то при блокировке enp0s3 я не мог пинговать и по ip на интерфейсе enp0s8
# пробовал отдельно блокировать пакеты ssh от конкретной виртуальной машины, и это работало, но если заблокировать всё на интерфейсе enp0s3, то достучаться до хоста становится в приниципе невозможно, и я уже не понимаю в чем дело
# К сожалению, видно, с iptables и firewalld мне нужно закапываться глубже и больше поэкспериментировать, потому что на данный момент теория и практика почему-то совершенно не стыкуются между собой
