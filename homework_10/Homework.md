## Boot process

1. enable recovery options for grub, update main configuration file and find new item in grub2 config in /boot.
2. modify option vm.dirty_ratio:
   - using echo utility
   - using sysctl utility
   - using sysctl configuration files

* extra
1. Inspect initrd file contents. Find all files that are related to XFS filesystem and give a short description for every file.
2. Study dracut utility that is used for rebuilding initrd image. Give an example for adding driver/kernel module for your initrd and recreating it.
3. Explain the difference between ordinary and rescue initrd images.

## Selinux

Disable selinux using kernel cmdline

## Firewalls

1. Add rule using firewall-cmd that will allow SSH access to your server *only* from network 192.168.56.0/24 and interface enp0s8 (if your network and/on interface name differs - change it accordingly).
2. Shutdown firewalld and add the same rules via iptables.