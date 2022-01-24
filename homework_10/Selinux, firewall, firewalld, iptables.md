# SELinux, firewalld, iptables.
## SELinux

SELinux is a Linux Security Module (LSM) that is built into the Linux kernel. The SELinux subsystem in the kernel is driven by a security policy which is controlled by the administrator and loaded at boot. All security-relevant, kernel-level access operations on the system are intercepted by SELinux and examined in the context of the loaded security policy. If the loaded policy allows the operation, it continues. Otherwise, the operation is blocked and the process receives an error.

SELinux provides the following benefits:
- All processes and files are labeled. SELinux policy rules define how processes interact with files, as well as how processes interact with each other. Access is only allowed if an SELinux policy rule exists that specifically allows it.
- Fine-grained access control. Stepping beyond traditional UNIX permissions that are controlled at user discretion and based on Linux user and group IDs, SELinux access decisions are based on all available information, such as an SELinux user, role, type, and, optionally, a security level.
- SELinux policy is administratively-defined and enforced system-wide.
- Improved mitigation for privilege escalation attacks. Processes run in domains, and are therefore separated from each other. SELinux policy rules define how processes access files and other processes. If a process is compromised, the attacker only has access to the normal functions of that process, and to files the process has been configured to have access to. For example, if the Apache HTTP Server is compromised, an attacker cannot use that process to read files in user home directories, unless a specific SELinux policy rule was added or configured to allow such access.
- SELinux can be used to enforce data confidentiality and integrity, as well as protecting processes from untrusted inputs.

SELinux can run in one of three modes:
- Disabled mode is strongly discouraged; not only does the system avoid enforcing the SELinux policy, it also avoids labeling any persistent objects such as files, making it difficult to enable SELinux in the future.
- In permissive mode, the system acts as if SELinux is enforcing the loaded security policy, including labeling objects and emitting access denial entries in the logs, but it does not actually deny any operations. While not recommended for production systems, permissive mode can be helpful for SELinux policy development.
- Enforcing mode is the default, and recommended, mode of operation; in enforcing mode SELinux operates normally, enforcing the loaded security policy on the entire system.

### Configuration

The /etc/selinux/config file is the main SELinux configuration file.

**SELINUX** option sets whether SELinux is disabled or enabled and in which mode - enforcing or permissive - it is running:
- enforcing, SELinux policy is enforced, and SELinux denies access based on SELinux policy rules. Denial messages are logged.
- permissive, SELinux policy is not enforced. SELinux does not deny access, but denials are logged for actions that would have been denied if running SELinux in enforcing mode.
- disabled, SELinux is disabled, the SELinux module is not registered with the Linux kernel, and only DAC rules are used.

**SELINUXTYPE** option sets the SELinux policy to use. Targeted policy is the default policy. Only change this option if you want to use the MLS policy

### SELinux Status

You need to use **getenforce** utility in order to get the current mode of SELinux:

```
[vault@centos ~]$ getenforce
Enforcing
```

or **sestatus**

```
[vault@centos ~]$ sestatus
SELinux status:                 enabled
SELinuxfs mount:                /sys/fs/selinux
SELinux root directory:         /etc/selinux
Loaded policy name:             targeted
Current mode:                   enforcing
Mode from config file:          enforcing
Policy MLS status:              enabled
Policy deny_unknown status:     allowed
Max kernel policy version:      31
```

Use the **setenforce** utility to change between enforcing and permissive mode. Changes made with setenforce do not persist across reboots.
To change to enforcing mode, enter the **setenforce 1** command as the Linux root user. To change to permissive mode, enter the **setenforce 0**.

You can set individual domains to permissive mode while the system runs in enforcing mode. For example, to make the httpd_t domain permissive:

```
semanage permissive -a httpd_t
```

### Changing SELinux mode at boot time

On boot, you can set several kernel parameters to change the way SELinux runs:
- enforcing=0, causes the system to start in permissive mode
- selinux=0, causes the kernel to not load any part of the SELinux infrastructure. The init scripts notice that the system booted with the selinux=0 parameter and touch the /.autorelabel file. This causes the system to automatically relabel the next time you boot with SELinux enabled.
- autorelabel=1. This parameter forces the system to relabel

### SELinux context

Processes and files are labeled with an SELinux context that contains additional information, such as an SELinux user, role, type, and, optionally, a level. When running SELinux, all of this information is used to make access control decisions.

You can use **ls -Z** to display security context.  Displays only mode, user, group, security context and file name.

```
[vault@centos ~]$ ls -Z .bashrc
-rw-r--r--. vault vault unconfined_u:object_r:user_home_t:s0 .bashrc
```

SELinux contexts follow the SELinux user:role:type:level syntax. The fields are as follows:

- user. The SELinux user identity is an identity known to the policy that is authorized for a specific set of roles. Each Linux user is mapped to an SELinux user using SELinux policy.
- role. Part of SELinux is the Role-Based Access Control (RBAC) security model. The role is an attribute of RBAC. SELinux users are authorized for roles, and roles are authorized for domains. The role serves as an intermediary between domains and SELinux users. The roles that can be entered determine which domains can be entered; ultimately, this controls which object types can be accessed. This helps reduce vulnerability to privilege escalation attacks.
- type. The type is an attribute of Type Enforcement. The type defines a domain for processes, and a type for files. SELinux policy rules define how types can access each other, whether it be a domain accessing a type, or a domain accessing another domain. Access is only allowed if a specific SELinux policy rule exists that allows it.
- level. The level is an attribute of MLS and MCS. An MLS range is a pair of levels, written as lowlevel-highlevel if the levels differ, or lowlevel if the levels are identical (s0-s0 is the same as s0). Each level is a sensitivity-category pair, with categories being optional. If there are categories, the level is written as sensitivity:category-set. If there are no categories, it is written as sensitivity.

Enter the following command as root to view a list of mappings between SELinux and Linux user accounts:

```
[vault@centos ~]$ sudo yum install policycoreutils-python
[vault@centos ~]$ sudo semanage login -l

Login Name           SELinux User         MLS/MCS Range        Service

__default__          unconfined_u         s0-s0:c0.c1023       *
root                 unconfined_u         s0-s0:c0.c1023       *
system_u             system_u             s0-s0:c0.c1023       *
```

Output may differ slightly from system to system:
- The Login Name column lists Linux users.
- The SELinux User column lists which SELinux user the Linux user is mapped to. For processes, the SELinux user limits which roles and levels are accessible.
- The MLS/MCS Range column, is the level used by Multi-Level Security (MLS) and Multi-Category Security (MCS).
- The Service column determines the correct SELinux context, in which the Linux user is supposed to be logged in to the system. By default, the asterisk (*) character is used, which stands for any service.

Use the **ps -eZ** command to view the SELinux context for processes:

```
[vault@centos ~]$ ps -eZ
LABEL                             PID TTY          TIME CMD
system_u:system_r:init_t:s0         1 ?        00:00:01 systemd
system_u:system_r:kernel_t:s0       2 ?        00:00:00 kthreadd
system_u:system_r:kernel_t:s0       4 ?        00:00:00 kworker/0:0H
system_u:system_r:kernel_t:s0       5 ?        00:00:00 kworker/u2:0
system_u:system_r:kernel_t:s0       6 ?        00:00:00 ksoftirqd/0
system_u:system_r:kernel_t:s0       7 ?        00:00:00 migration/0
system_u:system_r:kernel_t:s0       8 ?        00:00:00 rcu_bh

[vault@centos ~]$ ps -eZ | grep passwd
unconfined_u:unconfined_r:passwd_t:s0-s0:c0.c1023 3147 pts/1 00:00:00 passwd
```

The system_r role is used for system processes, such as daemons.
passwd utility labeled with the passwd_exec_t type. Type defines a domain for processes, and a type for files.

In CentOS7 users run unconfined by default.
Use the following command to view the SELinux context associated with your Linux user:

```
[vault@centos ~]$ id -Z
unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023
```

This SELinux context shows that the Linux user is mapped to the SELinux unconfined_u user, running as the unconfined_r role, and is running in the unconfined_t domain. s0-s0 is an MLS range, which in this case, is the same as just s0. The categories the user has access to is defined by c0.c1023, which is all categories (c0 through to c1023).

## Port mapping

semanage port controls the port number to port type definitions. Possible options:

* -a - Add a record of the specified object type
* -d - Delete a record of the specified object type
* -m - Modify a record of the specified object type
* -l - List records of the specified object type

List http_port_t record:

```
[root@centos vault]# semanage port -l |grep http_port
http_port_t                    tcp      80, 81, 443, 488, 8008, 8009, 8443, 9000
```

### Change context

The chcon command relabels files; however, such label changes do not survive when the file system is relabeled. For permanent changes that survive a file system relabel, use the semanage utility, which is discussed later. As root, enter the following command to change the type to a type used by Samba:

```
[root@centos html]# chcon -t samba_share_t /var/www/html/testfile
[root@centos html]# ls -lZ ./
-rw-r--r--. root root unconfined_u:object_r:samba_share_t:s0 testfile
```

The **restorecon** utility restores the default SELinux context for files:

```
[root@centos html]# restorecon -v testfile
restorecon reset /var/www/html/testfile context unconfined_u:object_r:samba_share_t:s0->unconfined_u:object_r:httpd_sys_content_t:s0
```


## Firewalld

A firewall is a way to protect machines from any unwanted traffic from outside. It enables users to control incoming network traffic on host machines by defining a set of firewall rules. These rules are used to sort the incoming traffic and either block it or allow through.

firewalld is a firewall service daemon. firewalld uses the concepts of zones and services, that simplify the traffic management.

Zones are predefined sets of rules. Network interfaces and sources can be assigned to a zone. The traffic allowed depends on the network your computer is connected to and the security level this network is assigned. Firewall services are predefined rules that cover all necessary settings to allow incoming traffic for a specific service and they apply within a zone.

Services use one or more ports or addresses for network communication. Firewalls filter communication based on ports. To allow network traffic for a service, its ports must be open. firewalld blocks all traffic on ports that are not explicitly set as open. Some zones, such as trusted, allow all traffic by default.

![The Firewall Stack](https://access.redhat.com/webassets/avalon/d/Red_Hat_Enterprise_Linux-7-Security_Guide-en-US/images/eee9192950e07b21f5c95b3ced63ae09/RHEL_Security-Guide_453350_0717_ECE_firewalld-comparison-rhel7.png)

### Runtime and Permanent Settings

Using the CLI, you do not modify the firewall settings in both modes at the same time. You only modify either runtime or permanent mode. To modify the firewall settings in the permanent mode, use the --permanent option with the firewall-cmd command.

```
~]# firewall-cmd --permanent <other options>
```

Without this option, the command modifies runtime mode. To change settings in both modes, you can use two methods.
Change runtime settings and then make them permanent as follows:

```
~]# firewall-cmd <other options>
~]# firewall-cmd --runtime-to-permanent
```

Set permanent settings and reload the settings into runtime mode:

```
~]# firewall-cmd --permanent <other options>
~]# firewall-cmd --reload
```

### Firewall status

To see the status of the service:

```
[root@centos vault]# firewall-cmd --state
running
```

firewalld uses zones to manage the traffic. If a zone is not specified by the --zone option, the command is effective in the default zone assigned to the active network interface and connection.
To list all the relevant information for the default zone:

```
[root@centos vault]# firewall-cmd --list-all
public (active)
  target: default
  icmp-block-inversion: no
  interfaces: enp0s3
  sources:
  services: dhcpv6-client ssh
  ports:
  protocols:
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:
```

### Panic mode
To immediately disable networking traffic, switch panic mode on:

```
firewall-cmd --panic-on
```

### Services

A service can be a list of local ports, protocols, source ports, and destinations, as well as a list of firewall helper modules automatically loaded if a service is enabled. Using services saves users time because they can achieve several tasks, such as opening ports, defining protocols, enabling packet forwarding and more, in a single step, rather than setting up everything one after another.

Check that the service is not already allowed:

```
[root@centos vault]# firewall-cmd --list-services
dhcpv6-client ssh
```

List all predefined services:

```
[root@centos vault]# firewall-cmd --get-services
RH-Satellite-6 RH-Satellite-6-capsule amanda-client ...
```

Show service details:

```
[root@centos ~]# firewall-cmd --info-service ssh
ssh
  ports: 22/tcp
  protocols:
  source-ports:
  modules:
  destination:
```

Add the service to the allowed services:

```
~]# firewall-cmd --add-service=<service-name>
```

To add a new service use firewall-cmd with --new-service option:

```
~]$ firewall-cmd --new-service=service-name
```

To add a new service using a local file, use the following command:

```
~]$ firewall-cmd --new-service-from-file=service-name.xml
```

As soon as service settings are changed, an updated copy of the service is placed into /etc/firewalld/services/

#### Ports

Add/Remove a port to the allowed ports to open it for incoming traffic:

```
[root@centos vault]# firewall-cmd --permanent --add-port=12345/tcp
success
[root@centos vault]# firewall-cmd --list-ports
12345/tcp
[root@centos vault]# firewall-cmd --remove-port=12345/tcp
success
[root@centos vault]# firewall-cmd --list-ports

```

#### Zones

firewalld can be used to separate networks into different zones according to the level of trust that the user has decided to place on the interfaces and traffic within that network. A connection can only be part of one zone, but a zone can be used for many network connections.

The predefined zones are stored in the /usr/lib/firewalld/zones/ directory and can be instantly applied to any available network interface. These files are copied to the /etc/firewalld/zones/ directory only after they are modified.

- **block** Any incoming network connections are rejected with an icmp-host-prohibited message for IPv4 and icmp6-adm-prohibited for IPv6. Only network connections initiated from within the system are possible.
- **dmz** For computers in your demilitarized zone that are publicly-accessible with limited access to your internal network. Only selected incoming connections are accepted.
- **drop** Any incoming network packets are dropped without any notification. Only outgoing network connections are possible.
- **external** For use on external networks with masquerading enabled, especially for routers. You do not trust the other computers on the network to not harm your computer. Only selected incoming connections are accepted.
- **home** For use at home when you mostly trust the other computers on the network. Only selected incoming connections are accepted.
- **internal** For use on internal networks when you mostly trust the other computers on the network. Only selected incoming connections are accepted.
- **public** For use in public areas where you do not trust other computers on the network. Only selected incoming connections are accepted.
- **trusted** All network connections are accepted.
- **work** For use at work where you mostly trust the other computers on the network. Only selected incoming connections are accepted.

To see which zones are available on your system:

```
[root@centos vault]# firewall-cmd --get-zones
block dmz drop external home internal public trusted work

[root@centos vault]# ls -l /usr/lib/firewalld/zones/
total 36
-rw-r--r--. 1 root root 299 Sep 30  2020 block.xml
-rw-r--r--. 1 root root 293 Sep 30  2020 dmz.xml
-rw-r--r--. 1 root root 291 Sep 30  2020 drop.xml
-rw-r--r--. 1 root root 304 Sep 30  2020 external.xml
-rw-r--r--. 1 root root 369 Sep 30  2020 home.xml
-rw-r--r--. 1 root root 384 Sep 30  2020 internal.xml
-rw-r--r--. 1 root root 315 Sep 30  2020 public.xml
-rw-r--r--. 1 root root 162 Sep 30  2020 trusted.xml
-rw-r--r--. 1 root root 311 Sep 30  2020 work.xml
```

To see detailed information for all zones:

```
[root@centos vault]# firewall-cmd --list-all-zones
block
  target: %%REJECT%%
  icmp-block-inversion: no
  interfaces:
  sources:
  services:
  ports:
  protocols:
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:
```

To see detailed information for a specific zone:

```
[root@centos vault]# firewall-cmd --zone=drop --list-all
drop
  target: DROP
  icmp-block-inversion: no
  interfaces:
  sources:
  services:
  ports:
  protocols:
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:
```

Display the current default zone:

```
~]# firewall-cmd --get-default-zone
```

Set the new default zone:

```
~]# firewall-cmd --set-default-zone zone-name
```

List the active zones and the interfaces assigned to them:

```
[root@centos ~]# firewall-cmd --get-active-zones
public
  interfaces: enp0s3 enp0s8
```

Assign the interface to a different zone:

```
~]# firewall-cmd --zone=zone-name --change-interface=<interface-name>
```

For every zone, you can set a default behavior that handles incoming traffic that is not further specified. Such behaviour is defined by setting the target of the zone. There are three options:

- ACCEPT accept all incoming packets except those disabled by a specific rule.
- REJECT disable all incoming packets except those that you have allowed in specific rules.
- DROP disable all incoming packets except those that you have allowed in specific rules.

When packets are rejected, the source machine is informed about the rejection, while there is no information sent when the packets are dropped.

```
firewall-cmd --zone=zone-name --set-target=<default|ACCEPT|REJECT|DROP>
```


## Iptables

The essential differences between firewalld and the iptables (and ip6tables) services are:
- The iptables service stores configuration in /etc/sysconfig/iptables and /etc/sysconfig/ip6tables, while firewalld stores it in various XML files in /usr/lib/firewalld/ and /etc/firewalld/. Note that the /etc/sysconfig/iptables file does not exist as firewalld is installed by default on Red Hat Enterprise Linux.
- With the iptables service, every single change means flushing all the old rules and reading all the new rules from /etc/sysconfig/iptables, while with firewalld there is no recreating of all the rules. Only the differences are applied. Consequently, firewalld can change the settings during runtime without existing connections being lost.

Both use iptables tool to talk to the kernel packet filter.

To use the iptables and ip6tables services instead of firewalld, first disable firewalld by running the following command as root:

```
~]# systemctl disable --now firewalld
~]# yum -y install iptables-services
~]# systemctl enable --now iptables.service
```

Configuration file stored in /etc/sysconfig/iptables:

```
[root@centos ~]# cat /etc/sysconfig/iptables
# sample configuration for iptables service
# you can edit this manually or use system-config-firewall
# please do not ask us to add additional ports/services to this default configuration
*filter
:INPUT ACCEPT [0:0]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
-A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
-A INPUT -p icmp -j ACCEPT
-A INPUT -i lo -j ACCEPT
-A INPUT -p tcp -m state --state NEW -m tcp --dport 22 -j ACCEPT
-A INPUT -j REJECT --reject-with icmp-host-prohibited
-A FORWARD -j REJECT --reject-with icmp-host-prohibited
COMMIT
```

After adding rules have to save it manually:

```
[root@centos ~]# iptables-save > /etc/sysconfig/iptables
```

or

```
[root@centos ~]# service iptables save
iptables: Saving firewall rules to /etc/sysconfig/iptables:[  OK  ]
```

To restore rules need to use iptables-restore (-n for adding only new rules):

```
iptables-restore < /etc/sysconfig/iptables
iptables-restore -n < /etc/sysconfig/iptables
```

Output rules with rule number:
iptables -L --line-numbers

Remove rule with specific number:
iptables -D INPUT 2

### Tables

![Tables](https://www.frozentux.net/iptables-tutorial/images/tables_traverse.jpg)

iptables contains five tables:

- raw is used only for configuring packets so that they are exempt from connection tracking.
- filter is the default table, and is where all the actions typically associated with a firewall take place.
- nat is used for network address translation (e.g. port forwarding).
- mangle is used for specialized packet alterations.
- security is used for Mandatory Access Control networking rules.

In most common use cases you will only use two of these: filter and nat. The other tables are aimed at complex configurations involving multiple routers and routing decisions

Iptables places rules into predefined chains (INPUT, OUTPUT and FORWARD) that are checked against any network traffic (IP packets) relevant to those chains and a decision is made about what to do with each packet based upon the outcome of those rules, i.e. accepting or dropping the packet. These actions are referred to as targets, of which the two most common predefined targets are DROP to drop a packet or ACCEPT to accept a packet.

### Chains

Tables consist of chains. The default table, filter, contains three built-in chains. We can add rules for processing IP packets passing through those chains. These chains are:

- INPUT - All packets destined for the host computer.
- OUTPUT - All packets originating from the host computer.
- FORWARD - All packets neither destined for nor originating from the host computer, but passing through (routed by) the host computer. This chain is used if you are using your computer as a router.

```
[root@centos ~]# iptables -L
Chain INPUT (policy ACCEPT)
target     prot opt source               destination

Chain FORWARD (policy ACCEPT)
target     prot opt source               destination

Chain OUTPUT (policy ACCEPT)
target     prot opt source               destination
```

The nat table includes PREROUTING, POSTROUTING, and OUTPUT chains.

By default, none of the chains contain any rules. It is up to you to append rules to the chains that you want to use. Chains do have a default policy, which is generally set to ACCEPT, but can be reset to DROP

### Rules

Packet filtering is based on rules, which are specified by multiple matches (conditions the packet must satisfy so that the rule can be applied), and one target (action taken when the packet matches all conditions). Targets are specified using the -j or --jump option

Rules are added in a list to each chain. A packet is checked against each rule in turn, starting at the top, and if it matches that rule, then an action is taken such as accepting (ACCEPT) or dropping (DROP) the packet. Once a rule has been matched and an action taken, then the packet is processed according to the outcome of that rule and isn't processed by further rules in the chain. If a packet passes down through all the rules in the chain and reaches the bottom without being matched against any rule, then the default action for that chain is taken. This is referred to as the default policy and may be set to either ACCEPT or DROP the packet.

Set the policy for the chain to the specific target:

```
iptables -P INPUT ACCEPT
```

Deleting all the rules:

```
iptables -F
```

iptables commands:

```
-A, --append chain rule-specification
    Append one or more rules to the end of the selected chain.  When the source and/or destination names resolve to more than one  address, a rule will  be  added for each possible address combination.

-C, --check chain rule-specification
    Check  whether  a rule matching the specification does exist in the selected chain. This command uses the same logic as -D to find a matching entry, but does not alter the existing iptables configuration and uses its exit code to indicate success or failure.

-D, --delete chain rule-specification
-D, --delete chain rulenum
    Delete one or more rules from the selected chain.  There are two versions of this command: the rule can be specified as a number in the chain (starting at  1mfor the first rule) or a rule to match.

-I, --insert chain [rulenum] rule-specification
    Insert  one  or  more  rules  in the selected chain as the given rule number.  So, if the rule number is 1, the rule or rules are inserted at the head of the chain.  This is also the default if no rule number is specified.

-R, --replace chain rulenum rule-specification
    Replace a rule in the selected chain.  If the source and/or destination names resolve to multiple addresses, the  command  will  fail.   Rules  are  numbered starting at 1.

-L, --list [chain]
    List  all  rules in the selected chain.  If no chain is selected, all chains are listed. Like every other iptables command, it applies to the specified table (filter is the default), so NAT rules get listed by **iptables -t nat -n -L**.

-S, --list-rules [chain]
    Print all rules in the selected chain.  If no chain is selected, all chains are printed like iptables-save. Like every other iptables command, it applies  to the specified table (filter is the default).

-F, --flush [chain]
    Flush the selected chain (all the chains in the table if none is given).  This is equivalent to deleting all the rules one by one.

-Z, --zero [chain [rulenum]]
    Zero  the  packet  and  byte counters in all chains, or only the given chain, or only the given rule in a chain. It is legal to specify the -L, --list (list) option as well, to see the counters immediately before they are cleared. (See above.)
```

Possible connections states:
- NEW meaning that the packet has started a new connection, or otherwise associated with a connection which has not seen packets in both directions
- ESTABLISHED meaning that the packet is associated with a connection which has seen packets in both directions
- RELATED meaning that the packet is starting a new connection, but is associated with an existing connection, such as an FTP data transfer, or an ICMP error.
- INVALID meaning that the packet is associated with no known connection
- SNAT A virtual state, matching if the original source address differs from the reply destination.
- DNAT A virtual state, matching if the original destination differs from the reply source.

Allow input from network interfaces:

```
[root@centos ~]# iptables -A INPUT -i lo -j ACCEPT
[root@centos ~]# iptables -A INPUT -i enp0s3 -j ACCEPT
[root@centos ~]# iptables -vnL
Chain INPUT (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination
    0     0 ACCEPT     all  --  lo     *       0.0.0.0/0            0.0.0.0/0
  236 14268 ACCEPT     all  --  enp0s3 *       0.0.0.0/0            0.0.0.0/0

Chain FORWARD (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination

Chain OUTPUT (policy ACCEPT 122 packets, 34144 bytes)
 pkts bytes target     prot opt in     out     source               destination
```

Allow input from specific address:

```
iptables -A INPUT -s 192.168.88.17 -j ACCEPT
```

or network:

```
iptables -A INPUT -s 192.168.88.0/24 -j ACCEPT
```

Allow all tcp packets on destination port:

iptables -A INPUT -p tcp --dport 6881 -j ACCEPT

or port range

iptables -A INPUT -p tcp --dport 6881:6890 -j ACCEPT

---

- [RHEL7. Selinux users and administrators guide](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/selinux_users_and_administrators_guide/chap-security-enhanced_linux-introduction)
- [RHEL7. Security guide](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/security_guide/sec-using_firewalls)