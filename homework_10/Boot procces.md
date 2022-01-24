# Boot procces, proc system, kernel parameters, sysctl

## UEFI/BIOS, POSTests

The operating system is loaded through a bootstrapping process. A boot loader is a program whose task is to load a bigger program, such as the operating system.

First stage loader - simple. Load the second stage loader
Second stage loader - error checking, giving the user a choice of operating systems to boot, the ability to load diagnostic software, or enabling diagnostic modes in the operating system, etc.

Upon start-up, the BIOS goes through the following sequence:

* Power-on self-test (POST)
* Detect the video card’s (chip’s) BIOS and execute its code to initialize the video hardware
* Detect any other device BIOSes and invoke their initialize functions
* Display the BIOS start-up screen
* Perform a brief memory test (identify how much memory is in the system)
* Set memory and drive parameters
* Configure Plug & Play devices (traditionally PCI bus devices)
* Assign resources (DMA channels & IRQs)
* Identify the boot device
* When the BIOS identifies the boot device (typically one of several disks that has been tagged as the bootable disk), it reads block 0 from that device into memory location 0x7c00 and jumps there.

## MBR, grub2, initramfs

### Master Boot Record

![MBR](https://3.bp.blogspot.com/-9IIJTxX4PaE/T2Da-evpLBI/AAAAAAAABI8/k3v6RGWnh0k/s1600/structure+mbr.jpg)

This first disk block, block 0, is called the Master Boot Record (MBR) and contains the first stage boot loader.
Since the standard block size is 512 bytes, the entire boot loader has to fit into this space. The contents of the MBR are:

- MBR code area (440 bytes). Function is to read the first sector of the grub image from a local disk and jump to it
- 32-bit disk signature (optional 4 bytes)
- 0x0000 or 0x5A5A (2 bytes)
- Partition entries (64 bytes)
- MBR signature 0X55AA (2 bytes)

Partition entry:
- 0x00 - Bootable flag (0x80 - bootable | 0x00 - non-bootable | 0x01-0x07 - Invalid)
- 0x01-0x03 - CHS address of the starting of partition in hard disk
- 0x04 - Partition type (83 - Linux)
- 0x05-0x07 - CHS address of the end of partition in hard disk
- 0x08-0x0B - LBA of first sector in the partition
- 0x0C-0x0F - Number of sectors in partition

```bash
[vault@centos ~]$ sudo dd if=/dev/sda of=./first_sec bs=512 count=1 conv=swab
1+0 records in
1+0 records out
512 bytes (512 B) copied, 0.000157044 s, 3.3 MB/s

[vault@centos ~]$ hexdump -s 446 -n 16 first_sec
00001be 8020 2100 83aa 2882 0008 0000 0000 2000
00001ce

80 - boot
202100 - CHS start
83 - type linux
aa2882 - CHS end
00080000 - LBA first sector
00002000 - Number of sectors

[vault@centos ~]$ echo 'ibase=16; 200000' | bc
2097152

[vault@centos ~]$ sudo fdisk -l /dev/sda1

Disk /dev/sda1: 1073 MB, 1073741824 bytes, 2097152 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
```

### Boot with GRUB

![grub](https://upload.wikimedia.org/wikipedia/commons/1/18/GNU_GRUB_on_MBR_partitioned_hard_disk_drives.svg)

It is relatively easy to boot GNU/Linux from GRUB, because it somewhat resembles to boot a Multiboot-compliant OS.

1. Set GRUB’s root device to the same drive as GNU/Linux’s. The command search or similar may help you (see search):
```
grub> search --no-floppy --fs-uuid --set=root dfdf4cc9-753b-415f-aa4c-eae07f18d8e0
```
2. Load the kernel using the command linux (see linux):
```
grub> linux16 /vmlinuz-3.10.0-1160.el7.x86_64 root=/dev/mapper/centos-root ro crashkernel=auto rd.lvm.lv=centos/root rd.lvm.lv=centos/swap rhgb quiet
```
3. If you use an initrd, execute the command initrd (see initrd) after linux:
```
grub> initrd16 /initramfs-3.10.0-1160.el7.x86_64.img
```
4. Boot

Menuentry example:
```
menuentry 'CentOS Linux (3.10.0-1160.el7.x86_64) 7 (Core)' --class centos --class gnu-linux --class gnu --class os --unrestricted $menuentry_id_option 'gnulinux-3.10.0-1160.el7.x86_64-advanced-863e175d-91f9-43a3-b1cc-8fd88bf3c58a' {
        load_video
        set gfxpayload=keep
        insmod gzio
        insmod part_msdos
        insmod xfs
        set root='hd0,msdos1'
        if [ x$feature_platform_search_hint = xy ]; then
          search --no-floppy --fs-uuid --set=root --hint-bios=hd0,msdos1 --hint-efi=hd0,msdos1 --hint-baremetal=ahci0,msdos1 --hint='hd0,msdos1'  dfdf4cc9-753b-415f-aa4c-eae07f18d8e0
        else
          search --no-floppy --fs-uuid --set=root dfdf4cc9-753b-415f-aa4c-eae07f18d8e0
        fi
        linux16 /vmlinuz-3.10.0-1160.el7.x86_64 root=/dev/mapper/centos-root ro crashkernel=auto rd.lvm.lv=centos/root rd.lvm.lv=centos/swap rhgb quiet
        initrd16 /initramfs-3.10.0-1160.el7.x86_64.img
}
```

After loading kernel executes the /sbin/init program, which is always the first program to be executed. You can confirm this with its process id (PID), which should always be 1.

### Grub configuration

grub-install - installs  GRUB  onto  a  device.
This includes copying GRUB images into the target directory (generally /boot/grub), and on some platforms may also include installing GRUB onto a boot sector.

```bash
grub2-install /dev/sda
```

GRUB 2 reads its configuration from the /boot/grub2/grub.cfg file on traditional BIOS-based machines.

The GRUB 2 configuration file, grub.cfg, is generated during installation, or by invoking the grub2-mkconfig utility, and is automatically updated by grubby each time a new kernel is installed. When regenerated manually using grub2-mkconfig, the file is generated according to the template files located in /etc/grub.d/, and custom settings in the /etc/default/grub file.

Setting in /etc/default/grub:
GRUB_TIMEOUT - Sets the time period in seconds for the menu to be displayed before automatically booting unless the user intervenes.
GRUB_DEFAULT - Sets the default menu entry
GRUB_TERMINAL_OUTPUT - Select the terminal output device
GRUB_CMDLINE_LINUX - Entries on this line are added to the end of the 'linux' command line
GRUB_DISABLE_RECOVERY - If this option is set to ‘true’, disable the generation of recovery mode menu entries.

By default, the key for the GRUB_DEFAULT directive in the /etc/default/grub file is the word saved. This instructs GRUB 2 to load the kernel specified by the saved_entry directive in the GRUB 2 environment file, located at /boot/grub2/grubenv. You can set another GRUB 2 record to be the default, using the grub2-set-default command, which will update the GRUB 2 environment file. By default, the saved_entry value is set to the name of latest installed kernel of package type kernel. This is defined in /etc/sysconfig/kernel by the UPDATEDEFAULT and DEFAULTKERNEL directives.

grub-set-default - Set the default boot menu entry for GRUB
```bash
grub2-set-default 1
```

grub-reboot - Set the default boot menu entry for the next boot only
```bash
grub2-reboot 2
```

The following files are included in /etc/grub.d/:

- 00_header, which loads GRUB 2 settings from the /etc/default/grub file.
- 01_users, which reads the superuser password from the user.cfg file. In CentOS 7.0, this file was only created when boot password was defined in the kickstart file during installation, and it included the defined password in plain text.
- 10_linux, which locates kernels in the default partition of CentOS.
- 30_os-prober, which builds entries for operating systems found on other partitions.
- 40_custom, a template, which can be used to create additional menu entries:
```
menuentry "<Title>"{
<Data>
}
```

Changes to /etc/default/grub require rebuilding the grub.cfg file as follows:
```bash
grub2-mkconfig -o /boot/grub2/grub.cfg
```

Need to add add_drivers+=" fat vfat " to /etc/dracut.conf.d/drivers.conf for fat modules in initramfs.

dracut - low-level tool for generating an initramfs/initrd image
dracut [OPTION...] [<image> [<kernel version>]]

-f, --force overwrite existing initramfs file

```bash
    dracut -f -v /boot/initramfs-$(uname-r).img $(uname -r)
```

lsinitrd - tool to show the contents of an initramfs image


## runlevels

The previous versions of CentOS were distributed with SysV
In SysVinit systems, you had a defined but configurable set of runlevels numbered from 0 to 6.

The init program uses a series of shell scripts, divided into separate runlevels. You can see below a detailed description of runlevels in Sys V:
- Runlevel 0 or Halt is used to shift the computer from one state to another. It shut down the system.
- Runlevel 1, s, S or Single-User Mode is used for administrative and recovery functions. It has only enough daemons to allow one user (the root user) to log in and perform system maintenance tasks. All local file systems are mounted. Some essential services are started, but networking remains disabled.
- Runlevel 2 or Multi-user Mode is used for most daemons running and allows multiple users the ability to log in and use system services but without networking.
- Runlevel 3 or Extended Multi-user Mode is used for a full multi-user mode with a console (without GUI) login screen with network services available
- Runlevel 4 is not normally used and undefined so it can be used for a personal customization
- Runlevel 5 or Graphical Mode is same as Runlevel 3 with graphical login _(such as GDN)_.
- Runlevel 6 or Reboot is a transitional runlevel to reboot the system.

runlevel - Print previous and current SysV runlevel.
telinit - Change SysV runlevel

These commands are available for compatibility only. It should not be used anymore, as the concept of runlevels is obsolete.
Starting with CentOs 7, the concept of runlevels has been replaced with systemd targets.

## systemd targets

Targets are simply logical collections of units. They are a special systemd unit type with the .target file extension.
Default target located in /etc/systemd/system/default.target. It's just a symlink:

```bash
[root@centos vault]# ls -l /etc/systemd/system/default.target
lrwxrwxrwx. 1 root root 37 Nov 30 16:19 /etc/systemd/system/default.target -> /lib/systemd/system/multi-user.target
```

For a server, the default is the multi-user.target which is like runlevel 3 in SystemV.
For a desktop workstation, this is typically going to be the graphical.target, which is equivalent to runlevel 5.

Comparison of SysV runlevels with systemd targets

|Runlevel	|Target Units	|Description|
|-----------|--------------|-----------|
|0 |runlevel0.target, poweroff.target |Shut down and power off the system.|
|1 |runlevel1.target, rescue.target |Set up a rescue shell.|
|2 |runlevel2.target, multi-user.target |Set up a non-graphical multi-user system.|
|3 |runlevel3.target, multi-user.target |Set up a non-graphical multi-user system.|
|4 |runlevel4.target, multi-user.target |Set up a non-graphical multi-user system.|
|5 |runlevel5.target, graphical.target |Set up a graphical multi-user system.|
|6 |runlevel6.target, reboot.target |Shut down and reboot the system.|

Lists currently loaded target units:

```bash
[vault@centos ~]$ systemctl list-units --type target
UNIT                  LOAD   ACTIVE SUB    DESCRIPTION
basic.target          loaded active active Basic System
cryptsetup.target     loaded active active Local Encrypted Volumes
getty.target          loaded active active Login Prompts
local-fs-pre.target   loaded active active Local File Systems (Pre)
local-fs.target       loaded active active Local File Systems
multi-user.target     loaded active active Multi-User System
network-online.target loaded active active Network is Online
network-pre.target    loaded active active Network (Pre)
network.target        loaded active active Network
paths.target          loaded active active Paths
remote-fs.target      loaded active active Remote File Systems
slices.target         loaded active active Slices
sockets.target        loaded active active Sockets
swap.target           loaded active active Swap
sysinit.target        loaded active active System Initialization
timers.target         loaded active active Timers

LOAD   = Reflects whether the unit definition was properly loaded.
ACTIVE = The high-level unit activation state, i.e. generalization of SUB.
SUB    = The low-level unit activation state, values depend on unit type.
```

Changes the current target:
```bash
systemctl isolate name.target
```

To determine which target unit is used by default:
```bash
[vault@centos ~]$ systemctl get-default
multi-user.target
```

To configure the system to use a different target unit by default:
```bash
[vault@centos ~]$ sudo systemctl set-default multi-user.target
Removed symlink /etc/systemd/system/default.target.
Created symlink from /etc/systemd/system/default.target to /usr/lib/systemd/system/multi-user.target
```

Booting to rescue mode
Rescue mode provides a convenient single-user environment and allows you to repair your system in situations when it is unable to complete a regular booting process. In rescue mode, the system attempts to mount all local file systems and start some important system services, but it does not activate network interfaces or allow more users to be logged into the system at the same time.

To change the current target and enter rescue mode in the current session:
```bash
systemctl rescue
```

Booting to emergency mode
Emergency mode provides the most minimal environment possible and allows you to repair your system even in situations when the system is unable to enter rescue mode. In emergency mode, the system mounts the root file system only for reading, does not attempt to mount any other local file systems, does not activate network interfaces, and only starts a few essential services.

```bash
systemctl emergency
```

To shut down the system and power off the machine, use the command in the following format:
```bash
systemctl poweroff
```

## procfs

/proc is very special in that it is also a virtual filesystem. It's sometimes referred to as a process information pseudo-file system. It doesn't contain 'real' files but runtime system information (e.g. system memory, devices mounted, hardware configuration, etc). For this reason it can be regarded as a control and information centre for the kernel. In fact, quite a lot of system utilities are simply calls to files in this directory. For example, 'lsmod' is the same as 'cat /proc/modules' while 'lspci' is a synonym for 'cat /proc/pci'. By altering files located in this directory you can even read/change kernel parameters (sysctl) while the system is running.

### Process-Specific Subdirectories

The directory /proc contains (among other things) one subdirectory for each process running on the system, which is named after the process ID (PID).
The link ‘self’ points to the process reading the file system.

Process specific entries in /proc:
|Path|Content|
|-|-|
|/proc/PID/cmdline| Command line arguments.|
|/proc/PID/cpu| Current and last cpu in which it was executed.|
|/proc/PID/cwd| Link to the current working directory.|
|/proc/PID/environ| Values of environment variables.|
|/proc/PID/exe| Link to the executable of this process.|
|/proc/PID/fd| Directory, which contains all file descriptors.|
|/proc/PID/maps| Memory maps to executables and library files.|
|/proc/PID/mem| Memory held by this process.|
|/proc/PID/root| Link to the root directory of this process.|
|/proc/PID/stat| Process status.|
|/proc/PID/statm| Process memory status information.|
|/proc/PID/status| Process status in human readable form.|

### Kernel data

|Path|Content|
|-|-|
|/proc/cmdline| Kernel command line.|
|/proc/cpuinfo| Information about the processor, such as its type, make, model, and performance.|
|/proc/devices| List of device drivers configured into the currently running kernel (block and character).|
|/proc/filesystems| Filesystems configured/supported into/by the kernel.|
|/proc/fs| File system parameters, currently nfs/exports.|
|/proc/meminfo| Information about memory usage, both physical and swap. Concatenating this file produces similar results to using 'free' or the first few lines of |'top'.
|/proc/sys/| Configurable kernel features fs,net,kernel,vm, etc.|


fs/file-max & fs/file-nr The value in file-max denotes the maximum number of file-handles that the Linux kernel will allocate. When you get lots of error messages about running out of file handles, you might want to increase this limit.

net/ipv4/ip_forward — Permits interfaces on the system to forward packets. By default, this file is set to 0. Setting this file to 1 enables network packet forwarding.

vm/dirty_ratio — Starts active writeback of dirty data at this percentage of total memory for the generator of dirty data, via pdflush. The default value is 20.


## sysfs

In addition to /proc, the kernel also exports information to another virtual file system called sysfs. The sysfs file system is mounted on /sys. It provides a means to export kernel data structures, their attributes, and the linkages between them to userspace. Sysfs internally stores a pointer to the kobject that implements a directory in the kernfs_node object associated with the directory

In addition to providing information about various devices and kernel subsystems, exported virtual files are also used for their configuration.

The sysfs filesystem is commonly mounted at /sys.  Typically, it is mounted automatically by the system, but it can also be mounted manually using a command such as:

```
mount -t sysfs sysfs /sys
```

- /sys/block/ contains entries for each block device in the system
- /sys/devices/ contains a filesystem representation of the device tree. It maps directly to the internal kernel device tree
- /sys/bus/ contains flat directory layout of the various bus types in the kernel. Each bus’s directory contains two subdirectories:
   - devices/ contains symlinks for each device discovered in the system that point to the device’s directory under root/.
   - drivers/ contains a directory for each device driver that is loaded for devices on that particular bus (this assumes that drivers do not span multiple bus types)
- /sys/dev/ contains two directories char/ and block/. Inside these two directories there are symlinks named <major>:<minor>. These symlinks point to the sysfs directory for the given device. /sys/dev provides a quick way to lookup the sysfs interface for a device from the result of a stat(2) operation
- /sys/class/ contains every device class registered with the kernel. Device classes describe a functional type of device.
- /sys/module/ contains subdirectories for each module that is loaded into the kernel

## sysctl (list, get, set, persist)

sysctl - configure kernel parameters at runtime

sysctl [options] [variable[=value]] [...]

-a: This will display all the values currently available in the sysctl configuration.
-A: This will display all the values currently available in the sysctl configuration in table form.
-e: This option will ignore errors about unknown keys.
-p: This is used to load a specific sysctl configuration, by default it will use /etc/sysctl.conf
-n: This option will disable showing the key names when printing out the values.
-w: This option is for changing (or adding) values to the sysctl on-demand.

Default value stored in /etc/sysctl.conf. Additionally sysctl settings are defined through files in /usr/lib/sysctl.d/, /run/sysctl.d/, and /etc/sysctl.d/.

vm.drop_caches=2
fs.file-max = 2097152

---

- [Load the Operating System](https://www.cs.rutgers.edu/~pxk/416/notes/02-boot.html)
- [Proc FS](https://tldp.org/LDP/Linux-Filesystem-Hierarchy/html/proc.html)
- [The /proc Filesystem](https://www.kernel.org/doc/html/latest/filesystems/proc.html)
- [The filesystem for exporting kernel objects](https://www.kernel.org/doc/html/latest/filesystems/sysfs.html)
- [GRUB](https://thestarman.pcministry.com/asm/mbr/GRUB.htm)
- [RHEL7 System administrators guide](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/system_administrators_guide/ch-working_with_the_grub_2_boot_loader)