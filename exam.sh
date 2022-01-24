# # Задача:
# Установить, настроить и запустить Hadoop Сore в минимальной конфигурации. Для этого потребуется подготовить 2 виртуальные машины: VM1 - headnode; VM2 - worker. Понимание принципов работы Hadoop и его компонентов для успешной сдачи задания не требуется.
# Все инструкции и команды для каждого шага задания должны быть сохранены в файле.
# Детальная формулировка:
# 1. Установить CentOS на 2 виртуальные машины:
# •	VM1: 2CPU, 2-4G памяти, системный диск на 15-20G и дополнительные 2 диска по 5G
# •	VM2: 2CPU, 2-4G памяти, системный диск на 15-20G и дополнительные 2 диска по 5G
# Все дальнейшие действия будут выполняться на обеих машинах, если не сказано иначе.



# 2. При установке CentOS создать дополнительного пользователя exam и настроить для него использование sudo без пароля. Все последующие действия необходимо выполнять от этого пользователя, если не указано иное.
sudo yum install nano -y # в первую очередь для себя устанавливаю nano
sudo yum install wget
sudo nano /etc/sudoers # добавляю в файл в раздел «Same thing without a password» строчку
# exam            ALL=(ALL)       NOPASSWD: ALL
# теперь можно пользоваться sudo без пароля



# 3. Установить OpenJDK8 из репозитория CentOS.
yum search openjdk | grep "OpenJDK 8" # хм, какую именно версию OpenJDK мне нужно поставить?
# java-1.8.0-openjdk.x86_64 : OpenJDK 8 Runtime Environment
# java-1.8.0-openjdk-demo.x86_64 : OpenJDK 8 Demos
# java-1.8.0-openjdk-devel.x86_64 : OpenJDK 8 Development Environment
# java-1.8.0-openjdk-headless.x86_64 : OpenJDK 8 Headless Runtime Environment
# java-1.8.0-openjdk-javadoc.noarch : OpenJDK 8 API documentation
# java-1.8.0-openjdk-javadoc-zip.noarch : OpenJDK 8 API documentation compressed
# java-1.8.0-openjdk-src.x86_64 : OpenJDK 8 Source Bundle

sudo yum install java-1.8.0-openjdk.x86_64 -y
# Complete!



# 4. Скачать архив с Hadoop версии 3.1.2 (https://hadoop.apache.org/release/3.1.2.html)
wget https://archive.apache.org/dist/hadoop/common/hadoop-3.1.2/hadoop-3.1.2.tar.gz
# Downloaded: 1 files, 317M in 3m 31s (1.50 MB/s)



# 5. Распаковать содержимое архива в /opt/hadoop-3.1.2/
# sudo mkdir /opt/hadoop-3.1.2 # можно обойтись без этой строчки
sudo tar -xvf hadoop-3.1.2.tar.gz -C /opt/



# 6. Сделать симлинк /usr/local/hadoop/current/ на директорию /opt/hadoop-3.1.2/
sudo mkdir -p /usr/local/hadoop/
sudo ln -s /opt/hadoop-3.1.2/ /usr/local/hadoop/current
ls /usr/local/hadoop/ -l
# total 0
# lrwxrwxrwx. 1 root root 18 Jan 18 03:54 current -> /opt/hadoop-3.1.2/



# 7. Создать пользователей hadoop, yarn и hdfs, а также группу hadoop, в которую необходимо добавить всех этих пользователей
sudo groupadd hadoop
sudo useradd -g hadoop hadoop
sudo useradd -g hadoop yarn
sudo useradd -g hadoop hdfs
sudo usermod -aG hadoop hadoop
sudo usermod -aG hadoop yarn
sudo usermod -aG hadoop hdfs
# на всякий случай задам пароли данным пользователям
sudo passwd hadoop
sudo passwd yarn
sudo passwd hdfs




# 8. Создать для обоих дополнительных дисков разделы размером в 100% диска.
sudo fdisk /dev/sdb
Command (m for help): g
# Building a new GPT disklabel (GUID: 9D23E750-AEB8-47E9-BE66-728138B5D1F6)
Command (m for help): n
# Partition number (1-128, default 1):
# First sector (2048-10485726, default 2048):
# Last sector, +sectors or +size{K,M,G,T,P} (2048-10485726, default 10485726):
# Created partition 1
Command (m for help): p
# Disk /dev/sdb: 5368 MB, 5368709120 bytes, 10485760 sectors
# Units = sectors of 1 * 512 = 512 bytes
# Sector size (logical/physical): 512 bytes / 512 bytes
# I/O size (minimum/optimal): 512 bytes / 512 bytes
# Disk label type: gpt
# Disk identifier: 9D23E750-AEB8-47E9-BE66-728138B5D1F6
#         Start          End    Size  Type            Name
# 1         2048     10485726      5G  Linux filesyste
Command (m for help): w
# The partition table has been altered!
# Calling ioctl() to re-read partition table.
# Syncing disks.

# аналогично для /dev/sdc



# 9. Инициализировать разделы из п.8 в качестве физических томов для LVM.
sudo lvm
lvm> pvcreate /dev/sdb1
  # Physical volume "/dev/sdb1" successfully created.
lvm> pvcreate /dev/sdc1
  # Physical volume "/dev/sdc1" successfully created.



# 10. Создать две группы LVM и добавить в каждую из них по одному физическому тому из п.9.
lvm> vgcreate vgsdb1 /dev/sdb1
  # Volume group "vgsdb1" successfully created
lvm> vgcreate vgsdc1 /dev/sdc1
  # Volume group "vgsdc1" successfully created



# 11. В каждой из групп из п.10 создать логический том LVM размером 100% группы.
vgdisplay
  # --- Volume group ---
  # VG Name               vgsdb1
  # System ID
  # Format                lvm2
  # Metadata Areas        1
  # Metadata Sequence No  1
  # VG Access             read/write
  # VG Status             resizable
  # MAX LV                0
  # Cur LV                0
  # Open LV               0
  # Max PV                0
  # Cur PV                1
  # Act PV                1
  # VG Size               <5.00 GiB
  # PE Size               4.00 MiB
  # Total PE              1279
  # Alloc PE / Size       0 / 0
  # Free  PE / Size       1279 / <5.00 GiB
  # VG UUID               kETGQ0-H3En-kF8N-RFby-vSf3-fhrs-ezCUiL
# по информации от даннйо команды, vgsdb1 и vgsdc1 получились чуть меньше 5GiB, поэтому посчитаю:
  # PE Size = 4.00 MiB
  # Total PE = 1279
  # 4*1279=5116MiB

lvcreate -L 5116MiB -n lvsdb1 vgsdb1
  # Logical volume "lvsdb1" created.
lvcreate -L 5116MiB -n lvsdc1 vgsdc1
  # Logical volume "lvsdc1" created.



# 12. На каждом логическом томе LVM создать файловую систему ext4.
sudo mkfs.ext4 /dev/vgsdb1/lvsdb1
# mke2fs 1.42.9 (28-Dec-2013)
# Filesystem label=
# OS type: Linux
# Block size=4096 (log=2)
# Fragment size=4096 (log=2)
# Stride=0 blocks, Stripe width=0 blocks
# 327680 inodes, 1309696 blocks
# 65484 blocks (5.00%) reserved for the super user
# First data block=0
# Maximum filesystem blocks=1342177280
# 40 block groups
# 32768 blocks per group, 32768 fragments per group
# 8192 inodes per group
# Superblock backups stored on blocks:
#         32768, 98304, 163840, 229376, 294912, 819200, 884736
#
# Allocating group tables: done
# Writing inode tables: done
# Creating journal (32768 blocks): done
# Writing superblocks and filesystem accounting information: done

sudo mkfs.ext4 /dev/vgsdc1/lvsdc1
# mke2fs 1.42.9 (28-Dec-2013)
# Filesystem label=
# OS type: Linux
# Block size=4096 (log=2)
# Fragment size=4096 (log=2)
# Stride=0 blocks, Stripe width=0 blocks
# 327680 inodes, 1309696 blocks
# 65484 blocks (5.00%) reserved for the super user
# First data block=0
# Maximum filesystem blocks=1342177280
# 40 block groups
# 32768 blocks per group, 32768 fragments per group
# 8192 inodes per group
# Superblock backups stored on blocks:
#         32768, 98304, 163840, 229376, 294912, 819200, 884736
#
# Allocating group tables: done
# Writing inode tables: done
# Creating journal (32768 blocks): done
# Writing superblocks and filesystem accounting information: done



# 13. Создать директории и использовать их в качестве точек монтирования файловых систем из п.12:
# •	/opt/mount1
# •	/opt/mount2
sudo mkdir /opt/mount{1,2}
sudo mount /dev/vgsdb1/lvsdb1 /opt/mount1
sudo mount /dev/vgsdc1/lvsdc1 /opt/mount2



# 14. Настроить систему так, чтобы монтирование происходило автоматически при запуске системы. Произвести монтирование новых файловых систем.
sudo nano /etc/fstab # по сути мне надо только добавить пару строк в /etc/fstab
# /dev/vgsdb1/lvsdb1      /opt/mount1     ext4    defaults        0 0
# /dev/vgsdc1/lvsdc1      /opt/mount2     ext4    defaults        0 0



# Для VM1 (шаги 15-16):
# 15. После монтирования создать 2 директории для хранения файлов Namenode сервиса HDFS:
# •	/opt/mount1/namenode-dir
# •	/opt/mount2/namenode-dir
sudo mkdir /opt/mount{1,2}/namenode-dir



# 16. Сделать пользователя hdfs и группу hadoop владельцами этих директорий.
sudo chown hdfs:hadoop /opt/mount{1,2}/namenode-dir



# Для VM2 (шаги 17-20):
# 17. После монтирования создать 2 директории для хранения файлов Datanode сервиса HDFS:
# •	/opt/mount1/datanode-dir
# •	/opt/mount2/datanode-dir
sudo mkdir /opt/mount{1,2}/datanode-dir



# 18. Сделать пользователя hdfs и группу hadoop владельцами директорий из п.17.
sudo chown hdfs:hadoop /opt/mount{1,2}/datanode-dir



# 19. Создать дополнительные 4 директории для Nodemanager сервиса YARN:
# •	/opt/mount1/nodemanager-local-dir
# •	/opt/mount2/nodemanager-local-dir
# •	/opt/mount1/nodemanager-log-dir
# •	/opt/mount2/nodemanager-log-dir
sudo mkdir /opt/mount{1,2}/nodemanager-local-dir
sudo mkdir /opt/mount{1,2}/nodemanager-log-dir



# 20. Сделать пользователя yarn и группу hadoop владельцами директорий из п.19.
sudo chown yarn:hadoop /opt/mount{1,2}/nodemanager-*



# Для обеих машин:
21. Настроить доступ по SSH, используя ключи для пользователя hadoop.
### VM1
sudo -u hadoop ssh-keygen # генерируются ключи для SSH от имени пользователя hadoop
sudo ssh-copy-id -i /home/hadoop/.ssh/id_rsa.pub hadoop@VM2
# /bin/ssh-copy-id: INFO: Source of key(s) to be installed: "/home/hadoop/.ssh/id_rsa.pub"
# The authenticity of host 'vm2 (192.168.68.130)' can't be established.
# ECDSA key fingerprint is SHA256:zHGjG8bZLRDR8q0Eyjkfri2+ua0cvDjpML7JPfp0ODg.
# ECDSA key fingerprint is MD5:cf:73:fa:24:82:a0:9d:a4:e7:c6:ba:f9:68:ab:26:47.
# Are you sure you want to continue connecting (yes/no)? yes
# /bin/ssh-copy-id: INFO: attempting to log in with the new key(s), to filter out any that are already installed
# /bin/ssh-copy-id: INFO: 1 key(s) remain to be installed -- if you are prompted now it is to install the new keys
# hadoop@vm2's password:
#
# Number of key(s) added: 1
#
# Now try logging into the machine, with:   "ssh 'hadoop@VM2'"
# and check to make sure that only the key(s) you wanted were added.

### VM2
sudo -u hadoop ssh-keygen
sudo ssh-copy-id -i /home/hadoop/.ssh/id_rsa.pub hadoop@VM1



# 22. Добавить VM1 и VM2 в /etc/hosts.
# на самом деле я эти параметры прописал еще перед пунктом 21
sudo nano /etc/hosts # добавляю строчки в конце:
# 192.168.68.131  VM1
# 192.168.68.132  VM2



# 23. Скачать файлы по ссылкам в /usr/local/hadoop/current/etc/hadoop/{hadoop-env.sh,core-site.xml,hdfs-site.xml,yarn-site.xml}. При помощи sed заменить заглушки на необходимые значения
# •	hadoop-env.sh (https://gist.github.com/rdaadr/2f42f248f02aeda18105805493bb0e9b)
# Необходимо определить переменные JAVA_HOME (путь до директории с OpenJDK8, установленную в п.3), HADOOP_HOME (необходимо указать путь к симлинку из п.6) и HADOOP_HEAPSIZE_MAX (укажите значение в 512M)
# •	core-site.xml (https://gist.github.com/rdaadr/64b9abd1700e15f04147ea48bc72b3c7)
# Необходимо указать имя хоста, на котором будет запущена HDFS Namenode (VM1)
# •	hdfs-site.xml (https://gist.github.com/rdaadr/2bedf24fd2721bad276e416b57d63e38)
# Необходимо указать директории namenode-dir, а также datanode-dir, каждый раз через запятую (например, /opt/mount1/namenode-dir,/opt/mount2/namenode-dir)
# •	yarn-site.xml (https://gist.github.com/Stupnikov-NA/ba87c0072cd51aa85c9ee6334cc99158)
# Необходимо подставить имя хоста, на котором будет развернут YARN Resource Manager (VM1), а также пути до директорий nodemanager-local-dir и nodemanager-log-dir (если необходимо указать несколько директорий, то необходимо их разделить запятыми)

# hadoop-env.sh
sudo wget -P /usr/local/hadoop/current/etc/hadoop/ https://gist.github.com/rdaadr/2f42f248f02aeda18105805493bb0e9b/raw/6303e424373b3459bcf3720b253c01373666fe7c/hadoop-env.sh
# core-site.xml
sudo wget -P /usr/local/hadoop/current/etc/hadoop/ https://gist.github.com/rdaadr/64b9abd1700e15f04147ea48bc72b3c7/raw/2d416bf137cba81b107508153621ee548e2c877d/core-site.xml
# hdfs-site.xml
sudo wget -P /usr/local/hadoop/current/etc/hadoop/ https://gist.github.com/rdaadr/2bedf24fd2721bad276e416b57d63e38/raw/640ee95adafa31a70869b54767104b826964af48/hdfs-site.xml
# yarn-site.xml
sudo wget -P /usr/local/hadoop/current/etc/hadoop/ https://gist.github.com/Stupnikov-NA/ba87c0072cd51aa85c9ee6334cc99158/raw/bda0f760878d97213196d634be9b53a089e796ea/yarn-site.xml

# у меня файлы немного продублировались, т.к. в этой директории уже существовали нужные, так что заменю их
sudo mv /usr/local/hadoop/current/etc/hadoop/hadoop-env.sh.1 /usr/local/hadoop/current/etc/hadoop/hadoop-env.sh
sudo mv /usr/local/hadoop/current/etc/hadoop/core-site.xml.1 /usr/local/hadoop/current/etc/hadoop/core-site.xml
sudo mv /usr/local/hadoop/current/etc/hadoop/hdfs-site.xml.1 /usr/local/hadoop/current/etc/hadoop/hdfs-site.xml
sudo mv /usr/local/hadoop/current/etc/hadoop/yarn-site.xml.1 /usr/local/hadoop/current/etc/hadoop/yarn-site.xml

ls -l //usr/local/hadoop/current/etc/hadoop/
# total 172
# -rw-r--r--. 1 hadoop 1002  8260 Jan 29  2019 capacity-scheduler.xml
# -rw-r--r--. 1 hadoop 1002  1335 Jan 29  2019 configuration.xsl
# -rw-r--r--. 1 hadoop 1002  1940 Jan 29  2019 container-executor.cfg
# -rw-r--r--. 1 root   root   908 Jan 23 14:57 core-site.xml
# -rw-r--r--. 1 hadoop 1002  3999 Jan 29  2019 hadoop-env.cmd
# -rw-r--r--. 1 root   root 15980 Jan 23 14:57 hadoop-env.sh
# -rw-r--r--. 1 hadoop 1002  3323 Jan 29  2019 hadoop-metrics2.properties
# -rw-r--r--. 1 hadoop 1002 11392 Jan 29  2019 hadoop-policy.xml
# -rw-r--r--. 1 hadoop 1002  3414 Jan 29  2019 hadoop-user-functions.sh.example
# -rw-r--r--. 1 root   root  1081 Jan 23 14:58 hdfs-site.xml
# -rw-r--r--. 1 hadoop 1002  1484 Jan 29  2019 httpfs-env.sh
# -rw-r--r--. 1 hadoop 1002  1657 Jan 29  2019 httpfs-log4j.properties
# -rw-r--r--. 1 hadoop 1002    21 Jan 29  2019 httpfs-signature.secret
# -rw-r--r--. 1 hadoop 1002   620 Jan 29  2019 httpfs-site.xml
# -rw-r--r--. 1 hadoop 1002  3518 Jan 29  2019 kms-acls.xml
# -rw-r--r--. 1 hadoop 1002  1351 Jan 29  2019 kms-env.sh
# -rw-r--r--. 1 hadoop 1002  1747 Jan 29  2019 kms-log4j.properties
# -rw-r--r--. 1 hadoop 1002   682 Jan 29  2019 kms-site.xml
# -rw-r--r--. 1 hadoop 1002 13326 Jan 29  2019 log4j.properties
# -rw-r--r--. 1 hadoop 1002   951 Jan 29  2019 mapred-env.cmd
# -rw-r--r--. 1 hadoop 1002  1764 Jan 29  2019 mapred-env.sh
# -rw-r--r--. 1 hadoop 1002  4113 Jan 29  2019 mapred-queues.xml.template
# -rw-r--r--. 1 hadoop 1002   758 Jan 29  2019 mapred-site.xml
# drwxr-xr-x. 2 hadoop 1002    24 Jan 29  2019 shellprofile.d
# -rw-r--r--. 1 hadoop 1002  2316 Jan 29  2019 ssl-client.xml.example
# -rw-r--r--. 1 hadoop 1002  2697 Jan 29  2019 ssl-server.xml.example
# -rw-r--r--. 1 hadoop 1002  2642 Jan 29  2019 user_ec_policies.xml.template
# -rw-r--r--. 1 hadoop 1002    10 Jan 29  2019 workers
# -rw-r--r--. 1 hadoop 1002  2250 Jan 29  2019 yarn-env.cmd
# -rw-r--r--. 1 hadoop 1002  6056 Jan 29  2019 yarn-env.sh
# -rw-r--r--. 1 hadoop 1002  2591 Jan 29  2019 yarnservice-log4j.properties
# -rw-r--r--. 1 root   root  1499 Jan 23 14:59 yarn-site.xml


# hadoop-env.sh
# JAVA_HOME=/usr/lib/jvm/jre-1.8.0-openjdk
# HADOOP_HOME=/usr/local/hadoop/current
# HADOOP_HEAPSIZE_MAX=512M

sudo sed -i.backup 's|export JAVA_HOME=.*|export JAVA_HOME=/usr/lib/jvm/jre-1.8.0-openjdk|' /usr/local/hadoop/current/etc/hadoop/hadoop-env.sh
sudo sed -i 's|export HADOOP_HOME=.*|export HADOOP_HOME=/usr/local/hadoop/current|' /usr/local/hadoop/current/etc/hadoop/hadoop-env.sh
sudo sed -i 's|export HADOOP_HEAPSIZE_MAX=.*|export HADOOP_HEAPSIZE_MAX=512M|' /usr/local/hadoop/current/etc/hadoop/hadoop-env.sh
# можно было бы провести замену не по строке, а заменить именно заглушки, но надо точно знать как прописаны эти заглушки
# sed -i 's|\"%HADOOP_HEAP_SIZE%\"|512M|' /usr/local/hadoop/current/hadoop-3.1.2/hadoop-env.sh
# пожалуй дальше так и буду делать, потому что с xml файлами так будет даже проще

# core-site.xml
sudo sed -i.backup 's|%HDFS_NAMENODE_HOSTNAME%|VM1|' /usr/local/hadoop/current/etc/hadoop/core-site.xml

# hdfs-site.xml
### VM1
ls -l /opt/mount1/ # namenode_dir есть только на VM1
# total 20
# drwx------. 2 root root   16384 Jan 18 04:45 lost+found
# drwxr-xr-x. 2 hdfs hadoop  4096 Jan 19 19:08 namenode-dir
### VM2
ls -l /opt/mount1/ # datanode_dir есть только на VM2
# total 28
# drwxr-xr-x. 2 hdfs hadoop  4096 Jan 19 19:17 datanode-dir
# drwx------. 2 root root   16384 Jan 18 04:45 lost+found
# drwxr-xr-x. 2 yarn hadoop  4096 Jan 19 19:18 nodemanager-local-dir
# drwxr-xr-x. 2 yarn hadoop  4096 Jan 19 19:19 nodemanager-log-dir

# но на всякий случай и согласно заданию пропишу эти строки на обеих машинах
sudo sed -i.backup 's|%NAMENODE_DIRS%|/opt/mount1/namenode-dir,/opt/mount2/namenode-dir|' /usr/local/hadoop/current/etc/hadoop/hdfs-site.xml
sudo sed -i 's|%DATANODE_DIRS%|/opt/mount1/datanode-dir,/opt/mount2/datanode-dir|' /usr/local/hadoop/current/etc/hadoop/hdfs-site.xml

# yarn-site.xml
sudo sed -i.backup 's|%YARN_RESOURCE_MANAGER_HOSTNAME%|VM1|' /usr/local/hadoop/current/etc/hadoop/yarn-site.xml
sudo sed -i 's|%NODE_MANAGER_LOCAL_DIR%|/opt/mount1/nodemanager-local-dir,/opt/mount2/nodemanager-local-dir|' /usr/local/hadoop/current/etc/hadoop/yarn-site.xml
sudo sed -i 's|%NODE_MANAGER_LOG_DIR%|/opt/mount1/nodemanager-log-dir,/opt/mount2/nodemanager-log-dir|' /usr/local/hadoop/current/etc/hadoop/yarn-site.xml



# 24. Задать переменную окружения HADOOP_HOME через /etc/profile
env # посмотреть все переменные окружения
sudo nano /etc/profile # добавляю строчку в этот файл
# export HADOOP_HOME=/usr/local/hadoop/current
tail /etc/profile -n 1
# export HADOOP_HOME=/usr/local/hadoop/current
source /etc/profile # для перезагрузки файлами
env | grep HADOOP
# HADOOP_HOME=/usr/local/hadoop/current



Для VM1 (шаги 25-26):
25. Произвести форматирование HDFS (от имени пользователя hdfs):
•	$HADOOP_HOME/bin/hdfs namenode -format cluster1

### БЛОК НЕАКТУАЛЬНОЙ ИНФОРМАЦИИ ###
### Нашел ошибку в расположении файлов конфигурации, из-за чего они не считывались как надо ###
### А так же был не совсем корректно распакован архив hadoop, из-за чего путь оказывался длиннее. Это не такая уж проблема, но для корректности изменил данный момент и на виртуальных машинха, и в описанных командах ###
# sudo -u hdfs $HADOOP_HOME/bin/hdfs namenode -format cluster1
# # данная команда очень долго выдавала ошибку
# # ERROR: JAVA_HOME is not set and could not be found.
# # хотя JAVA_HOME определен в hadoop-env.sh
# echo $JAVA_HOME
# # /usr/lib/jvm/jre-1.8.0-openjdk
# sudo -u hdfs echo $JAVA_HOME
# # /usr/lib/jvm/jre-1.8.0-openjdk
#
# # на одном из ресурсов нашел комментарий "In some distributives(CentOS/OpenSuSe,...) will work only if you set JAVA_HOME in the /etc/environment." (https://stackoverflow.com/questions/8827102/hadoop-error-java-home-is-not-set)
# sudo nano /etc/environment
# # добавил в /etc/environment строчку
# # export JAVA_HOME=/usr/lib/jvm/jre-1.8.0-openjdk
# source /etc/environment
# echo $JAVA_HOME
# # /usr/lib/jvm/jre-1.8.0-openjdk
# # и только после этого вывод наконце сменился
# sudo -u hdfs $HADOOP_HOME/hadoop-3.1.2/bin/hdfs namenode -format cluster1
# # WARNING: /opt/hadoop-3.1.2/hadoop-3.1.2/logs does not exist. Creating.
# # mkdir: cannot create directory ‘/opt/hadoop-3.1.2/hadoop-3.1.2/logs’: Permission denied
# # ERROR: Unable to create /opt/hadoop-3.1.2/hadoop-3.1.2/logs. Aborting.
#
# #Итого, /ETC/ENVIRONMENT - "Это файл для создания, редактирования и удаления каких-либо переменных окружения на системном уровне. Переменные окружения, созданные в этом файле доступны для всей системы, для каждого пользователя и даже при удаленном подключении."

# для корректного создания директории от имени пользователя поправлю права на директорию /opt/hadoop-3.1.2
sudo chmod -R g+w /opt/hadoop-3.1.2
sudo chown -R hadoop:hadoop /opt/hadoop-3.1.2/
sudo -u hdfs $HADOOP_HOME/bin/hdfs namenode -format cluster1


# 26. Запустить демоны сервисов Hadoop:
# Для запуска Namenode (от имени пользователя hdfs):
# •	$HADOOP_HOME/bin/hdfs --daemon start namenode
sudo -u hdfs $HADOOP_HOME/bin/hdfs --daemon start namenode

# Для запуска Resource Manager (от имени пользователя yarn):
# •	$HADOOP_HOME/bin/yarn --daemon start resourcemanager
sudo -u yarn $HADOOP_HOME/bin/yarn --daemon start resourcemanager
# ERROR: Unable to write in /usr/local/hadoop/current/logs. Aborting.
sudo chmod -R g+w /usr/local/hadoop/current/logs
sudo -u yarn $HADOOP_HOME/bin/yarn --daemon start resourcemanager



# Для VM2 (шаг 27):
# 27. Запустить демоны сервисов:
sudo chmod -R g+w /usr/local/hadoop/current/logs
# Для запуска Datanode (от имени hdfs):
# •	$HADOOP_HOME/bin/hdfs --daemon start datanode
sudo -u hdfs $HADOOP_HOME/bin/hdfs --daemon start datanode

# Для запуска Node Manager (от имени yarn):
# •	$HADOOP_HOME/bin/yarn --daemon start nodemanager
sudo -u yarn $HADOOP_HOME/bin/yarn --daemon start nodemanager




# 28. Проверить доступность Web-интефейсов HDFS Namenode и YARN Resource Manager по портам 9870 и 8088 соответственно (VM1). << порты должны быть доступны с хостовой системы.

curl localhost:9870
# <!--
#    Licensed to the Apache Software Foundation (ASF) under one or more
#    contributor license agreements.  See the NOTICE file distributed with
#    this work for additional information regarding copyright ownership.
#    The ASF licenses this file to You under the Apache License, Version 2.0
#    (the "License"); you may not use this file except in compliance with
#    the License.  You may obtain a copy of the License at
#
#        http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS,
#    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#    See the License for the specific language governing permissions and
#    limitations under the License.
# -->
# <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
#     "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
# <html xmlns="http://www.w3.org/1999/xhtml">
# <head>
# <meta http-equiv="REFRESH" content="0;url=dfshealth.html" />
# <title>Hadoop Administration</title>
# </head>
# </html>

# Теперь, для того, чтобы сервер был доступен для хостовой машины, нужно либо отключить firewalld, либо настроить его
sudo firewall-cmd --permanent --zone=public --add-port=9870/tcp
# success
sudo firewall-cmd --permanent --zone=public --add-port=8088/tcp
# success
sudo firewall-cmd --reload
# success

# Теперь на хостовой машине в браузере я могу открыть ресурсы
# 192.168.68.131:9870 - откроется сайт http://192.168.68.131:9870/dfshealth.html#tab-overview
# 192.168.68.132:8088 - откроется сайт http://192.168.68.131:8088/cluster



# 29. Настроить управление запуском каждого компонента Hadoop при помощи systemd (используя юниты-сервисы).
### VM1
###### Namenode
sudo nano /etc/systemd/system/namenode.service # создаю файл со следующим содержанием:
# [Unit]
# Description=Namenode service for Hadoop
# After=network.target
#
# [Service]
# Type=forking
# User=hdfs
# Group=hadoop
# ExecStart=/usr/local/hadoop/current/bin/hdfs --daemon start namenode
# Restart=on-failure
#
# [Install]
# WantedBy=multi-user.target

sudo systemctl enable namenode.service
# Created symlink from /etc/systemd/system/multi-user.target.wants/namenode.service to /etc/systemd/system/namenode.service.
sudo systemctl start namenode.service
systemctl status namenode.service
# ● namenode.service - Namenode service for Hadoop
#    Loaded: loaded (/etc/systemd/system/namenode.service; disabled; vendor preset: disabled)
#    Active: active (running) since Sun 2022-01-23 19:29:47 MSK; 2s ago
#  Main PID: 8505 (bash)
#    CGroup: /system.slice/namenode.service
#            ├─8505 bash /usr/local/hadoop/current/bin/hdfs --daemon start namenode
#            ├─8544 /usr/lib/jvm/jre-1.8.0-openjdk/bin/java -Dproc_namenode -Djava.net.preferIPv4Stack=true -Dhdfs.a...
#            └─8558 sleep 1
#
# Jan 23 19:29:47 VM1 systemd[1]: Started Namenode service for Hadoop.

###### Resource Manager

sudo nano /etc/systemd/system/resourcemanager.service # Resource Manager. Делаю примерно такой же файл
# [Unit]
# Description=Resource Manager service for Hadoop
# After=network.target
#
# [Service]
# Type=forking
# User=yarn
# Group=hadoop
# ExecStart=/usr/local/hadoop/current/bin/yarn --daemon start resourcemanager
# Restart=on-failure
#
# [Install]
# WantedBy=multi-user.target

sudo systemctl enable resourcemanager.service
# Created symlink from /etc/systemd/system/multi-user.target.wants/resourcemanager.service to /etc/systemd/system/resourcemanager.service.
sudo systemctl start resourcemanager.service
sudo systemctl status resourcemanager.service
# ● resourcemanager.service - Resource Manager service for Hadoop
#    Loaded: loaded (/etc/systemd/system/resourcemanager.service; enabled; vendor preset: disabled)
#    Active: active (running) since Sun 2022-01-23 19:40:25 MSK; 5s ago
#   Process: 9296 ExecStart=/usr/local/hadoop/current/bin/yarn --daemon start resourcemanager (code=exited, status=0/SUCCESS)
#  Main PID: 9340 (java)
#    CGroup: /system.slice/resourcemanager.service
#            └─9340 /usr/lib/jvm/jre-1.8.0-openjdk/bin/java -Dproc_resourcemanager -Djava.net.preferIPv4Stack=true -...
#
# Jan 23 19:40:23 VM1 systemd[1]: Starting Resource Manager service for Hadoop...
# Jan 23 19:40:25 VM1 systemd[1]: Started Resource Manager service for Hadoop.

### VM2
###### Datanode
sudo nano /etc/systemd/system/datanode.service
# [Unit]
# Description=Datanode service for Hadoop
# After=network.target
#
# [Service]
# Type=forking
# User=hdfs
# Group=hadoop
# ExecStart=/usr/local/hadoop/current/bin/hdfs --daemon start datanode
# Restart=on-failure
#
# [Install]
# WantedBy=multi-user.target

sudo systemctl enable datanode.service
sudo systemctl start datanode.service
sudo systemctl status datanode.service
# ● datanode.service - Datanode service for Hadoop
#    Loaded: loaded (/etc/systemd/system/datanode.service; enabled; vendor preset: disabled)
#    Active: active (running) since Sun 2022-01-23 19:54:56 MSK; 6s ago
#   Process: 1976 ExecStart=/usr/local/hadoop/current/bin/hdfs --daemon start datanode (code=exited, status=0/SUCCESS)
#  Main PID: 2020 (java)
#    CGroup: /system.slice/datanode.service
#            └─2020 /usr/lib/jvm/jre-1.8.0-openjdk/bin/java -Dproc_datanode -Djava.net.preferIPv4Stack=true -Dhadoo...
#
# Jan 23 19:54:54 localhost.localdomain systemd[1]: Starting Datanode service for Hadoop...
# Jan 23 19:54:56 localhost.localdomain systemd[1]: Started Datanode service for Hadoop.

###### Nodemanager
sudo nano /etc/systemd/system/nodemanager.service
# [Unit]
# Description=Nodemanager service for Hadoop
# After=network.target
#
# [Service]
# Type=forking
# User=yarn
# Group=hadoop
# ExecStart=/usr/local/hadoop/current/bin/yarn --daemon start nodemanager
# Restart=on-failure
#
# [Install]
# WantedBy=multi-user.target

sudo systemctl enable nodemanager.service
sudo systemctl start nodemanager.service
sudo systemctl status nodemanager.service
# ● nodemanager.service - Nodemanager service for Hadoop
#    Loaded: loaded (/etc/systemd/system/nodemanager.service; enabled; vendor preset: disabled)
#    Active: active (running) since Sun 2022-01-23 19:55:38 MSK; 5s ago
#   Process: 2102 ExecStart=/usr/local/hadoop/current/bin/yarn --daemon start nodemanager (code=exited, status=0/SUCCESS)
#  Main PID: 2144 (java)
#    CGroup: /system.slice/nodemanager.service
#            └─2144 /usr/lib/jvm/jre-1.8.0-openjdk/bin/java -Dproc_nodemanager -Djava.net.preferIPv4Stack=true -Dya...
#
# Jan 23 19:55:36 localhost.localdomain systemd[1]: Starting Nodemanager service for Hadoop...
# Jan 23 19:55:38 localhost.localdomain systemd[1]: Started Nodemanager service for Hadoop.



#####################################################
# Уже постфактум заметил, что при выключенном FirewallD не приходят данные на сервер на VM1 с VM2, но по заданию нет никаких указаний что-нибудь по данному вопросу предпринимать
### VM2
less /usr/local/hadoop/current/logs/hadoop-hdfs-datanode-VM2.log # данный лог выдает ошибки вида
# 2022-01-23 23:39:27,780 INFO org.apache.hadoop.ipc.Client: Retrying connect to server: VM1/192.168.68.131:8020. Already tried 9 time(s); retry policy is RetryUpToMaximumCountWithFixedSleep(maxRetries=10, sleepTime=1000 MILLISECONDS)
### VM1
sudo firewall-cmd --permanent --zone=public --add-port=8020/tcp # разрешаю доступ по данному порту на VM1
# Теперь на http://192.168.68.131:8088/cluster/nodes появилась Node в состоянии RUNNING	по адресу VM2:35899
# В случае необходимости я могу проверить логи и открыть необходимые порты



# Полезные ссылки:
# •	https://hadoop.apache.org/docs/r3.1.2/hadoop-project-dist/hadoop-common/ClusterSetup.html
