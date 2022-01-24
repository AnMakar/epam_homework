1. add secondary ip address to you second network interface enp0s8. Each point must be presented with commands and showing that new address was applied to the interface. To repeat adding address for points 2 and 3 address must be deleted (please add deleting address to you homework log) Methods:
   1. using ip utility (stateless)
# для начала добавляю второй сетевой интерфейс в VB
ip -4 a
# 1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
#     inet 127.0.0.1/8 scope host lo
#        valid_lft forever preferred_lft forever
# 2: enp0s3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
#     inet 10.0.2.15/24 brd 10.0.2.255 scope global noprefixroute dynamic enp0s3
#        valid_lft 86329sec preferred_lft 86329sec
# 3: enp0s8: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
#     inet 10.0.3.15/24 brd 10.0.3.255 scope global noprefixroute dynamic enp0s8
#        valid_lft 86329sec preferred_lft 86329sec

sudo ip addr add 10.0.3.100/24 dev enp0s8
ip -4 a
# 1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
#     inet 127.0.0.1/8 scope host lo
#        valid_lft forever preferred_lft forever
# 2: enp0s3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
#     inet 10.0.2.15/24 brd 10.0.2.255 scope global noprefixroute dynamic enp0s3
#        valid_lft 85696sec preferred_lft 85696sec
# 3: enp0s8: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group  default qlen 1000
#     inet 10.0.3.15/24 brd 10.0.3.255 scope global noprefixroute dynamic enp0s8
#        valid_lft 85697sec preferred_lft 85697sec
#     inet 10.0.3.100/24 scope global secondary enp0s8
#        valid_lft forever preferred_lft forever

sudo ip addr del 10.0.3.100/24 dev enp0s8
ip -4 a
# 1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
#     inet 127.0.0.1/8 scope host lo
#        valid_lft forever preferred_lft forever
# 2: enp0s3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
#     inet 10.0.2.15/24 brd 10.0.2.255 scope global noprefixroute dynamic enp0s3
#        valid_lft 85433sec preferred_lft 85433sec
# 3: enp0s8: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
#     inet 10.0.3.15/24 brd 10.0.3.255 scope global noprefixroute dynamic enp0s8
#        valid_lft 85433sec preferred_lft 85433sec

   2. using centos network configuration file (statefull)
# для настройки отдельного интерфейса нужно создать новый файл в /etc/sysconfig/network-scripts/ с именем ifcfg-enp0s8
# для самого себя помечу наиболее распространенные параметры для данного конфига. Информация из статьи https://overcoder.net/manuals/nastrojka-seti-v-linux-rabota-s-fajlami-konfiguracii, т.к. что-то man не нашел
# Варианты конфигурации
# Есть множество различных опций конфигурации для файлов конфигурации интерфейса. Вот некоторые из наиболее распространенных вариантов:
# DEVICE: логическое имя устройства, например, eth0 или enp0s2;
# HWADDR: MAC-адрес сетевой карты, связанной с файлом, например, 00: 16: 76: 02: BA: DB;
# ONBOOT: запуск сети на этом устройстве при загрузке хоста. Варианты yes/no. Обычно это значение равно «no», и сеть не запускается, пока пользователь не войдет в систему на рабочем столе. Если если вам нужно, чтобы сеть запускалась, когда никто не вошел в систему, установите для этого параметра значение «yes»;
# IPADDR: IP-адрес, назначенный этому NIC, например, 192.168.0.10;
# BROADCAST: широковещательный адрес для этой сети, такой как 192.168.0.255;
# NETMASK: маска сети для этой подсети, например, маска класса C 255.255.255.0;
# NETWORK: идентификатор сети для этой подсети, например, идентификатор класса C 192.168.0.0;
# SEARCH: DNS-имя домена для поиска при поиске на неквалифицированных именах хостов, таких как "example.com";
# BOOTPROTO: протокол загрузки для этого интерфейса. Варианты: static, DHCP, bootp, none. Опция «none» по умолчанию является статической;
# GATEWAY: сетевой маршрутизатор или шлюз по умолчанию для этой подсети, например, 192.168.0.254;
# ETHTOOL_OPTS: эта опция используется для установки определенных элементов конфигурации интерфейса для сетевого интерфейса, таких как скорость, состояние дуплекса и состояние автосогласования. Поскольку этот параметр имеет несколько независимых значений, значения должны быть заключены в один набор кавычек, например: «autoneg off speed 100 duplex full»;
# DNS1: основной DNS-сервер, например, 192.168.0.254, который является сервером в локальной сети. Указанные здесь DNS-серверы добавляются в файл /etc/resolv.conf при использовании NetworkManager или когда для директивы peerdns задано значение yes. В противном случае DNS-серверы необходимо добавить в /etc/resolv.conf вручную и игнорировать здесь;
# DNS2: вторичный DNS-сервер, например, 8.8.8.8, который является одним из бесплатных DNS-серверов Google. Обратите внимание, что третичный DNS-сервер не поддерживается в файлах конфигурации интерфейса, хотя третий может быть настроен в энергонезависимом файле resolv.conf;
# TYPE: Тип сети, обычно Ethernet. Единственная другая ценность, которую я тут когда-либо видел, была Token Ring, но сейчас она в основном не имеет значения;
# PEERDNS: опция yes указывает, что файл /etc/resolv.conf необходимо изменить, вставив в этот файл записи DNS-сервера, указанные в параметрах DNS1 и DNS2. «No» означает не изменять файл resolv.conf. «Yes» – это значение по умолчанию, если в строке BOOTPROTO указан DHCP;
# USERCTL: указывает, могут ли непривилегированные пользователи запускать и останавливать этот интерфейс. Варианты yes/no;
# IPV6INIT: указывает, применяются ли протоколы IPV6 к этому интерфейсу. Варианты yes/no.
# Если указан параметр DHCP, большинство других параметров игнорируются. Единственными необходимыми опциями являются BOOTPROTO, ONBOOT и HWADDR. Другими опциями, которые могут оказаться полезными и которые не игнорируются, являются опции DNS и PEERDNS, если вы хотите переопределить записи DNS, предоставленные сервером DHCP.

# Изначально заметил, что в /etc/sysconfig/network-scripts/ почему-то отсутствует интерфейс enp0s8, хотя при этом сам интерфейс отображается в ip в предыдущем пункте
ls /etc/sysconfig/network-scripts/
# ifcfg-enp0s3  ifdown-isdn      ifdown-tunnel  ifup-isdn    ifup-Team
# ifcfg-lo      ifdown-post      ifup           ifup-plip    ifup-TeamPort
# ifdown        ifdown-ppp       ifup-aliases   ifup-plusb   ifup-tunnel
# ifdown-bnep   ifdown-routes    ifup-bnep      ifup-post    ifup-wireless
# ifdown-eth    ifdown-sit       ifup-eth       ifup-ppp     init.ipv6-global
# ifdown-ippp   ifdown-Team      ifup-ippp      ifup-routes  network-functions
# ifdown-ipv6   ifdown-TeamPort  ifup-ipv6      ifup-sit     network-functions-ipv6

# если я создам файл ifcfg_enp0s8, то он переопределит настройку интерфейса, поэтому сначала создам файл ifcfg_enp0s8 с содержанием, по большей части дублиурющим интерфейс ifcfg_enp0s3:
# TYPE="Ethernet"
# PROXY_METHOD="none"
# BROWSER_ONLY="no"
# BOOTPROTO="dhcp"
# DEFROUTE="yes"
# IPV4_FAILURE_FATAL="no"
# IPV6INIT="yes"
# IPV6_AUTOCONF="yes"
# IPV6_DEFROUTE="yes"
# IPV6_FAILURE_FATAL="no"
# IPV6_ADDR_GEN_MODE="stable-privacy"
# NAME="enp0s8"
# DEVICE="enp0s8"
# ONBOOT="yes"

sudo systemctl restart network

ip -4 a
# 1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
#     inet 127.0.0.1/8 scope host lo
#        valid_lft forever preferred_lft forever
# 2: enp0s3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
#     inet 10.0.2.15/24 brd 10.0.2.255 scope global noprefixroute dynamic enp0s3
#        valid_lft 86397sec preferred_lft 86397sec
# 3: enp0s8: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
#     inet 10.0.3.15/24 brd 10.0.3.255 scope global noprefixroute dynamic enp0s8
#        valid_lft 86398sec preferred_lft 86398sec

# создаю файл ifcfg_enp02s8:1 с содержанием
# TYPE="Ethernet"
# BOOTPROTO="static"
# NAME="enp0s8:1"
# DEVICE="enp0s8:1"
# ONBOOT="yes"
# IPADDR="10.0.3.100"
# NETMASK=255.255.255.0

sudo systemctl restart network
ip -4 a
# 1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
#     inet 127.0.0.1/8 scope host lo
#        valid_lft forever preferred_lft forever
# 2: enp0s3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
#     inet 10.0.2.15/24 brd 10.0.2.255 scope global noprefixroute dynamic enp0s3
#        valid_lft 86395sec preferred_lft 86395sec
# 3: enp0s8: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
#     inet 10.0.3.15/24 brd 10.0.3.255 scope global noprefixroute dynamic enp0s8
#        valid_lft 86395sec preferred_lft 86395sec

# странно, второй IP не отображается
sudo ifup enp0s8:1
# Determining if ip address 10.0.3.100 is already in use for device enp0s8...
# RTNETLINK answers: File exists
# хотя здесь сообщает, что он уже используется

ip -4 a
# 1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
#     inet 127.0.0.1/8 scope host lo
#        valid_lft forever preferred_lft forever
# 2: enp0s3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
#     inet 10.0.2.15/24 brd 10.0.2.255 scope global noprefixroute dynamic enp0s3
#        valid_lft 86361sec preferred_lft 86361sec
# 3: enp0s8: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
#     inet 10.0.3.15/24 brd 10.0.3.255 scope global noprefixroute dynamic enp0s8
#        valid_lft 86361sec preferred_lft 86361sec
#     inet 10.0.3.100/24 brd 10.0.3.255 scope global secondary enp0s8
#        valid_lft forever preferred_lft forever

# а теперь он появился...

sudo mv /etc/sysconfig/network-scripts/ifcfg-enp0s8:1 ~/ # убираю настройки второго IP
ip -4 a
# 1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
#     inet 127.0.0.1/8 scope host lo
#        valid_lft forever preferred_lft forever
# 2: enp0s3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
#     inet 10.0.2.15/24 brd 10.0.2.255 scope global noprefixroute dynamic enp0s3
#        valid_lft 86398sec preferred_lft 86398sec
# 3: enp0s8: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
#     inet 10.0.3.15/24 brd 10.0.3.255 scope global noprefixroute dynamic enp0s8
#        valid_lft 86398sec preferred_lft 86398sec

   3. using nmcli utility (statefull)
sudo nmcli connection show
# NAME                UUID                                  TYPE      DEVICE
# enp0s3              528615da-a739-4255-b1ff-e572876efa30  ethernet  enp0s3
# enp0s8              00cb8299-feb9-55b6-a378-3fdc720e0bc6  ethernet  enp0s8
# Wired connection 1  34dfc0d5-4de4-351f-96ce-b1ea288ae5f9  ethernet  --

# добавлю второй IP
sudo nmcli connection modify enp0s8 +ipv4.addresses "10.0.3.100/24"
ip -4 a
# 1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
#     inet 127.0.0.1/8 scope host lo
#        valid_lft forever preferred_lft forever
# 2: enp0s3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
#     inet 10.0.2.15/24 brd 10.0.2.255 scope global noprefixroute dynamic enp0s3
#        valid_lft 85841sec preferred_lft 85841sec
# 3: enp0s8: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
#     inet 10.0.3.15/24 brd 10.0.3.255 scope global noprefixroute dynamic enp0s8
#        valid_lft 85841sec preferred_lft 85841sec

sudo systemctl restart network
ip -4 a
# 1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
#     inet 127.0.0.1/8 scope host lo
#        valid_lft forever preferred_lft forever
# 2: enp0s3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
#     inet 10.0.2.15/24 brd 10.0.2.255 scope global noprefixroute dynamic enp0s3
#        valid_lft 86397sec preferred_lft 86397sec
# 3: enp0s8: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
#     inet 10.0.3.15/24 brd 10.0.3.255 scope global noprefixroute dynamic enp0s8
#        valid_lft 86398sec preferred_lft 86398sec
#     inet 10.0.3.100/24 brd 10.0.3.255 scope global secondary noprefixroute enp0s8
#        valid_lft forever preferred_lft forever

# удалю второй IP
sudo nmcli connection modify enp0s8 -ipv4.addresses "10.0.3.100/24"
ip -4 a
# 1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
#     inet 127.0.0.1/8 scope host lo
#        valid_lft forever preferred_lft forever
# 2: enp0s3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
#     inet 10.0.2.15/24 brd 10.0.2.255 scope global noprefixroute dynamic enp0s3
#        valid_lft 86348sec preferred_lft 86348sec
# 3: enp0s8: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
#     inet 10.0.3.15/24 brd 10.0.3.255 scope global noprefixroute dynamic enp0s8
#        valid_lft 86348sec preferred_lft 86348sec
#     inet 10.0.3.100/24 brd 10.0.3.255 scope global secondary noprefixroute enp0s8
#        valid_lft forever preferred_lft forever
sudo systemctl restart network
ip -4 a
# 1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
#     inet 127.0.0.1/8 scope host lo
#        valid_lft forever preferred_lft forever
# 2: enp0s3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
#     inet 10.0.2.15/24 brd 10.0.2.255 scope global noprefixroute dynamic enp0s3
#        valid_lft 86397sec preferred_lft 86397sec
# 3: enp0s8: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
#     inet 10.0.3.15/24 brd 10.0.3.255 scope global noprefixroute dynamic enp0s8
#        valid_lft 86398sec preferred_lft 86398sec


2. You should have a possibility to use ssh client to connect to your node using new address from previous step. Run tcpdump in separate tmux session or separate connection before starting ssh client and capture packets that are related to this ssh connection. Find packets that are related to TCP session establish.
# По умолчанию у меня tcpdump не установлен. Поставлю его
sudo yum install tcpdump -y

sudo tcpdump --list-interfaces
# 1.enp0s3
# 2.enp0s8
# 3.nflog (Linux netfilter log (NFLOG) interface)
# 4.nfqueue (Linux netfilter queue (NFQUEUE) interface)
# 5.usbmon1 (USB bus number 1)
# 6.any (Pseudo-device that captures on all interfaces)
# 7.lo [Loopback]

sudo tcpdump -n -i enp0s8 > ~/tcpdump_enp0s8.dmp
# tcpdump: listening on enp0s8, link-type EN10MB (Ethernet), capture size 262144 bytes
# -v может увеличить количество отображаемой информации о пакетах, но я обойдусь без этого, чтобы не мусорить в дампе
# -n Если DNS не работает или вы не хотите, чтобы tcpdump выполнял поиск имени. По умолчанию tcpdump преобразует IP-адреса в имена хостов, а также использует имена служб вместо номеров портов.
# -i Для захвата пакетов, проходящих через определенный интерфейс


# Чтобы заработало подключение по данному новому IP, снова повторяю шаги из пункта 1.3, но еще нужно сделать проброску портов в виртуальной машине. Создаю новое правило, протокол - TCP, адрес хоста - 127.0.0.1, порт хоста - 2222, адрес гостя - 10.0.3.100, порт гостя - 22. Подключаюсь через putty на 127.0.0.1 по порту 2222.

# Я подключился, ввел имя пользователя, пароль, а затем сразу же ввел exit и отключился

head ./tcpdump_enp0s8.dmp
# 17:00:54.773813 IP 10.0.3.2.51714 > 10.0.3.100.ssh: Flags [S], seq 90048001, win 65535, options [mss 1460], length 0
# 17:00:54.773920 IP 10.0.3.100.ssh > 10.0.3.2.51714: Flags [S.], seq 4112183622, ack 90048002, win 29200, options [mss 1460], length 0
# 17:00:54.774044 IP 10.0.3.2.51714 > 10.0.3.100.ssh: Flags [.], ack 1, win 65535, length 0
# 17:00:54.783562 IP 10.0.3.2.51714 > 10.0.3.100.ssh: Flags [P.], seq 1:29, ack 1, win 65535, length 28
# 17:00:54.783624 IP 10.0.3.100.ssh > 10.0.3.2.51714: Flags [.], ack 29, win 29200, length 0
# 17:00:54.807055 IP 10.0.3.100.ssh > 10.0.3.2.51714: Flags [P.], seq 1:22, ack 29, win 29200, length 21
# 17:00:54.810698 IP 10.0.3.2.51714 > 10.0.3.100.ssh: Flags [.], ack 22, win 65535, length 0
# 17:00:54.814221 IP 10.0.3.2.51714 > 10.0.3.100.ssh: Flags [P.], seq 29:1285, ack 22, win 65535, length 1256
# 17:00:54.828119 IP 10.0.3.100.ssh > 10.0.3.2.51714: Flags [P.], seq 22:1302, ack 1285, win 31400, length 1280
# 17:00:54.828364 IP 10.0.3.2.51714 > 10.0.3.100.ssh: Flags [.], ack 1302, win 65535, length 0

# Каждая строка включает:
# Метка времени Unix (20: 58: 26.765637)
# протокол (IP)
# имя или IP-адрес исходного хоста и номер порта (10.0.0.50.80)
# имя хоста или IP-адрес назначения и номер порта (10.0.0.1.53181)
# Флаги TCP (Flags [F.]). Указывают на состояние соединения и могут содержать более одного значения:
# S. — SYN. Первый шаг в установлении соединения
# F. — FIN. Прекращение соединения
# .  — ACK. Пакет подтверждения принят успешно
# P. — PUSH. Указывает получателю обрабатывать пакеты вместо их буферизации
# R. — RST. Связь прервалась
# Порядковый номер данных в пакете. (seq 1)
# Номер подтверждения. (ack 2)
# Размер окна (win 453). Количество байтов, доступных в приемном буфере. Далее следуют параметры TCP
# Длина полезной нагрузки данных. (length 0)

# Таким образом, судя по всему, соединение установлено после появления строчек с флагами [S.] - SYN и [.] - ACK, идущего после SYN

3. Close session. Find in tcpdump output packets that are related to TCP session closure.

tail ./tcpdump_enp0s8.dmp
# 17:01:00.401981 IP 10.0.3.2.51714 > 10.0.3.100.ssh: Flags [.], ack 3142, win 65535, length 0
# 17:01:01.567227 IP 10.0.3.2.51714 > 10.0.3.100.ssh: Flags [P.], seq 2389:2453, ack 3142, win 65535, length 64
# 17:01:01.568737 IP 10.0.3.100.ssh > 10.0.3.2.51714: Flags [P.], seq 3142:3286, ack 2453, win 36424, length 144
# 17:01:01.568904 IP 10.0.3.2.51714 > 10.0.3.100.ssh: Flags [.], ack 3286, win 65535, length 0
# 17:01:01.568937 IP 10.0.3.100.ssh > 10.0.3.2.51714: Flags [P.], seq 3286:3382, ack 2453, win 36424, length 96
# 17:01:01.569086 IP 10.0.3.2.51714 > 10.0.3.100.ssh: Flags [.], ack 3382, win 65535, length 0
# 17:01:01.571142 IP 10.0.3.2.51714 > 10.0.3.100.ssh: Flags [F.], seq 2453, ack 3382, win 65535, length 0
# 17:01:01.571784 IP 10.0.3.100.ssh > 10.0.3.2.51714: Flags [F.], seq 3382, ack 2454, win 36424, length 0
# 17:01:01.571978 IP 10.0.3.2.51714 > 10.0.3.100.ssh: Flags [.], ack 3383, win 65535, length 0

# Аналогично прошлому пункту, соединение закрывается после флагов [F.] - FIN и последующего [.]

4. run tcpdump and request any http site in separate session. Find HTTP request and answer packets with ASCII data in it.  Tcpdump command must be as strict as possible to capture only needed packages for this http request.

# Не совсем понял в каком виде должен быть результат
sudo tcpdump host 52.128.23.153 and port 80 # вот так можно отфильтровать запросы к хосту и от хоста http://ngnix.com с IP-адрессом 52.128.23.153 с портом 80 (используется для незашифрованного трафика HTTP)

# tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
# listening on enp0s3, link-type EN10MB (Ethernet), capture size 262144 bytes
# 19:12:17.913858 IP localhost.localdomain.60526 > 52.128.23.153.http: Flags [S], seq 587432236, win 29200, options [mss 1460,sackOK,TS val 15263019 ecr 0,nop,wscale 7], length 0
# 19:12:18.098692 IP 52.128.23.153.http > localhost.localdomain.60526: Flags [S.], seq 2798592001, ack 587432237, win 65535, options [mss 1460], length 0
# 19:12:18.098740 IP localhost.localdomain.60526 > 52.128.23.153.http: Flags [.], ack 1, win 29200, length 0
# 19:12:18.098943 IP localhost.localdomain.60526 > 52.128.23.153.http: Flags [P.], seq 1:74, ack 1, win 29200, length 73: HTTP: GET / HTTP/1.1
# 19:12:18.110108 IP 52.128.23.153.http > localhost.localdomain.60526: Flags [.], ack 74, win 65535, length 0
# 19:12:18.283485 IP 52.128.23.153.http > localhost.localdomain.60526: Flags [P.], seq 1:307, ack 74, win 65535, length 306: HTTP: HTTP/1.1 200 OK
# 19:12:18.283520 IP localhost.localdomain.60526 > 52.128.23.153.http: Flags [.], ack 307, win 30016, length 0
# 19:12:18.283997 IP 52.128.23.153.http > localhost.localdomain.60526: Flags [P.], seq 307:1767, ack 74, win 65535, length 1460: HTTP
# 19:12:18.284020 IP localhost.localdomain.60526 > 52.128.23.153.http: Flags [.], ack 1767, win 32120, length 0
# 19:12:18.467881 IP 52.128.23.153.http > localhost.localdomain.60526: Flags [P.], seq 1767:1871, ack 74, win 65535, length 104: HTTP
# 19:12:18.467916 IP localhost.localdomain.60526 > 52.128.23.153.http: Flags [.], ack 1871, win 32120, length 0
# 19:12:18.468105 IP localhost.localdomain.60526 > 52.128.23.153.http: Flags [F.], seq 74, ack 1871, win 32120, length 0
# 19:12:18.468357 IP 52.128.23.153.http > localhost.localdomain.60526: Flags [.], ack 75, win 65535, length 0
# 19:12:18.652722 IP 52.128.23.153.http > localhost.localdomain.60526: Flags [F.], seq 1871, ack 75, win 65535, length 0
# 19:12:18.652762 IP localhost.localdomain.60526 > 52.128.23.153.http: Flags [.], ack 1872, win 32120, length 0
# ^C
# 15 packets captured
# 15 packets received by filter
# 0 packets dropped by kernel
