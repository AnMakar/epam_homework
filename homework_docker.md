**ДЗ состоит в создании контейнеров, сконфигурированных по аналогии с тем, как это было необходимо сделать для виртуальных машин в экзаменационном задании по Hadoop кластеру.**

Вам потребуется:

### 1.	Создать аккаунт на Docker Hub с публичным репозиторием.

Cоздан репозиторий на Docker Hub - https://hub.docker.com/repository/docker/anmean/epam_homework

public view - https://hub.docker.com/r/anmean/epam_homework

### 2.	Создать Dockerfiles для сборки образов headnode и worker.  Для хранения файлов Namenode и Datanode сервиса HDFS, а также Nodemanager сервиса YARN следует использовать Docker volumes.  Также поменяется способ запуска процессов, они должны стартовать при запуске контейнеров.

**Использовать следующие команды для создания томов для хранения данных:**

```
docker volume create mount1
docker volume create mount2
```

**Использовать следующую команду для создания сети для контейнеров:**
```
docker network create hadoop-net
```

**Создать два dockerfile. Рекомендуется предварительно создать для каждого свои директории:**

**1) dockerfile для headnode**

Создание директорий:
```
mkdir ./docker1
cd ./docker1
```

``` 
FROM centos:7

LABEL name="namenode"

# установка пакетов
# скачивание Hadoop
# создание директорий для namenode
# создание пользователей
RUN yum install wget -y && \
    yum install java-1.8.0-openjdk.x86_64 -y &&  \
      wget https://archive.apache.org/dist/hadoop/common/hadoop-3.1.2/hadoop-3.1.2.tar.gz && \
      tar -xvf hadoop-3.1.2.tar.gz -C /opt/ && \
      rm hadoop-3.1.2.tar.gz && \
    mkdir -p /usr/local/hadoop/ && \
    ln -s /opt/hadoop-3.1.2/ /usr/local/hadoop/current && \
    groupadd hadoop && \
    useradd -g hadoop hadoop && \
    useradd -g hadoop yarn && \
    useradd -g hadoop hdfs && \
    usermod -aG hadoop hadoop && \
    usermod -aG hadoop yarn && \
    usermod -aG hadoop hdfs && \
      mkdir -p /opt/mount{1,2}/namenode-dir && \
      chown hdfs:hadoop /opt/mount{1,2}/namenode-dir

# скачивание и настройка файлов конфигураций
RUN wget https://gist.github.com/rdaadr/2f42f248f02aeda18105805493bb0e9b/raw/6303e424373b3459bcf3720b253c01373666fe7c/hadoop-env.sh -O /usr/local/hadoop/current/etc/hadoop/hadoop-env.sh && \
      sed -i.backup 's|export JAVA_HOME=.*|export JAVA_HOME=/usr/lib/jvm/jre-1.8.0-openjdk|' /usr/local/hadoop/current/etc/hadoop/hadoop-env.sh && \
      sed -i 's|export HADOOP_HOME=.*|export HADOOP_HOME=/usr/local/hadoop/current|' /usr/local/hadoop/current/etc/hadoop/hadoop-env.sh && \
      sed -i 's|export HADOOP_HEAPSIZE_MAX=.*|export HADOOP_HEAPSIZE_MAX=512M|' /usr/local/hadoop/current/etc/hadoop/hadoop-env.sh && \
    wget https://gist.github.com/rdaadr/64b9abd1700e15f04147ea48bc72b3c7/raw/2d416bf137cba81b107508153621ee548e2c877d/core-site.xml -O /usr/local/hadoop/current/etc/hadoop/core-site.xml && \
      sed -i.backup 's|%HDFS_NAMENODE_HOSTNAME%|headnode|' /usr/local/hadoop/current/etc/hadoop/core-site.xml && \
    wget https://gist.github.com/rdaadr/2bedf24fd2721bad276e416b57d63e38/raw/640ee95adafa31a70869b54767104b826964af48/hdfs-site.xml -O /usr/local/hadoop/current/etc/hadoop/hdfs-site.xml && \
      sed -i.backup 's|%NAMENODE_DIRS%|/opt/mount1/namenode-dir,/opt/mount2/namenode-dir|' /usr/local/hadoop/current/etc/hadoop/hdfs-site.xml && \
      sed -i 's|%DATANODE_DIRS%|/opt/mount1/datanode-dir,/opt/mount2/datanode-dir|' /usr/local/hadoop/current/etc/hadoop/hdfs-site.xml && \
    wget https://gist.github.com/Stupnikov-NA/ba87c0072cd51aa85c9ee6334cc99158/raw/bda0f760878d97213196d634be9b53a089e796ea/yarn-site.xml -O /usr/local/hadoop/current/etc/hadoop/yarn-site.xml && \
      sed -i.backup 's|%YARN_RESOURCE_MANAGER_HOSTNAME%|headnode|' /usr/local/hadoop/current/etc/hadoop/yarn-site.xml && \
      sed -i 's|%NODE_MANAGER_LOCAL_DIR%|/opt/mount1/nodemanager-local-dir,/opt/mount2/nodemanager-local-dir|' /usr/local/hadoop/current/etc/hadoop/yarn-site.xml && \
      sed -i 's|%NODE_MANAGER_LOG_DIR%|/opt/mount1/nodemanager-log-dir,/opt/mount2/nodemanager-log-dir|' /usr/local/hadoop/current/etc/hadoop/yarn-site.xml && \
    echo "export HADOOP_HOME=/usr/local/hadoop/current" >> /etc/profile

# настройка для namenode
RUN mkdir -p /usr/local/hadoop/current/logs && \
    chmod -R g+w /usr/local/hadoop/current/logs && \
    chown -R hadoop:hadoop /usr/local/hadoop/current/logs && \
    chmod -R g+w /opt/hadoop-3.1.2 && \
    chown -R hadoop:hadoop /opt/hadoop-3.1.2/

RUN touch /usr/local/hadoop/current/etc/hadoop/start.sh && \
    echo "#!/bin/bash" >> /usr/local/hadoop/current/etc/hadoop/start.sh && \
    echo "su -l hdfs -c \"/usr/local/hadoop/current/bin/hdfs --daemon start namenode\"" >> /usr/local/hadoop/current/etc/hadoop/start.sh && \
    echo "su -l hdfs -c \"/usr/local/hadoop/current/bin/yarn --daemon start resourcemanager\"" >> /usr/local/hadoop/current/etc/hadoop/start.sh && \
    echo "while :" >> /usr/local/hadoop/current/etc/hadoop/start.sh && \
    echo "do" >> /usr/local/hadoop/current/etc/hadoop/start.sh && \
    echo "sleep 10" >> /usr/local/hadoop/current/etc/hadoop/start.sh && \
    echo "done" >> /usr/local/hadoop/current/etc/hadoop/start.sh


ENTRYPOINT ["/bin/bash", "/usr/local/hadoop/current/etc/hadoop/start.sh"]

EXPOSE 9870 8088

ENV JAVA_HOME=/usr/lib/jvm/jre-1.8.0-openjdk HADOOP_HOME=/usr/local/hadoop/current HADOOP_HEAPSIZE_MAX=512M
```

**2) dockerfile для worker**

Создание директорий:
```
mkdir ./docker2
cd ./docker2
```

``` 
FROM centos:7

LABEL name="worker"

# установка пакетов
# скачивание Hadoop
# создание директорий для worker
# создание пользователей
RUN yum install wget -y && \
    yum install java-1.8.0-openjdk.x86_64 -y &&  \
      wget https://archive.apache.org/dist/hadoop/common/hadoop-3.1.2/hadoop-3.1.2.tar.gz && \
      tar -xvf hadoop-3.1.2.tar.gz -C /opt/ && \
      rm hadoop-3.1.2.tar.gz && \
    mkdir -p /usr/local/hadoop/ && \
    ln -s /opt/hadoop-3.1.2/ /usr/local/hadoop/current && \
    groupadd hadoop && \
    useradd -g hadoop hadoop && \
    useradd -g hadoop yarn && \
    useradd -g hadoop hdfs && \
    usermod -aG hadoop hadoop && \
    usermod -aG hadoop yarn && \
    usermod -aG hadoop hdfs && \
      mkdir -p /opt/mount{1,2}/datanode-dir && \
      chown hdfs:hadoop /opt/mount{1,2}/datanode-dir && \
      mkdir /opt/mount{1,2}/nodemanager-local-dir && \
      mkdir /opt/mount{1,2}/nodemanager-log-dir && \
      chown yarn:hadoop /opt/mount{1,2}/nodemanager-*
# последний блок относится к worker

# скачивание и настройка файлов конфигураций
RUN wget https://gist.github.com/rdaadr/2f42f248f02aeda18105805493bb0e9b/raw/6303e424373b3459bcf3720b253c01373666fe7c/hadoop-env.sh -O /usr/local/hadoop/current/etc/hadoop/hadoop-env.sh && \
      sed -i.backup 's|export JAVA_HOME=.*|export JAVA_HOME=/usr/lib/jvm/jre-1.8.0-openjdk|' /usr/local/hadoop/current/etc/hadoop/hadoop-env.sh && \
      sed -i 's|export HADOOP_HOME=.*|export HADOOP_HOME=/usr/local/hadoop/current|' /usr/local/hadoop/current/etc/hadoop/hadoop-env.sh && \
      sed -i 's|export HADOOP_HEAPSIZE_MAX=.*|export HADOOP_HEAPSIZE_MAX=512M|' /usr/local/hadoop/current/etc/hadoop/hadoop-env.sh && \
    wget https://gist.github.com/rdaadr/64b9abd1700e15f04147ea48bc72b3c7/raw/2d416bf137cba81b107508153621ee548e2c877d/core-site.xml -O /usr/local/hadoop/current/etc/hadoop/core-site.xml && \
      sed -i.backup 's|%HDFS_NAMENODE_HOSTNAME%|headnode|' /usr/local/hadoop/current/etc/hadoop/core-site.xml && \
    wget https://gist.github.com/rdaadr/2bedf24fd2721bad276e416b57d63e38/raw/640ee95adafa31a70869b54767104b826964af48/hdfs-site.xml -O /usr/local/hadoop/current/etc/hadoop/hdfs-site.xml && \
      sed -i.backup 's|%NAMENODE_DIRS%|/opt/mount1/namenode-dir,/opt/mount2/namenode-dir|' /usr/local/hadoop/current/etc/hadoop/hdfs-site.xml && \
      sed -i 's|%DATANODE_DIRS%|/opt/mount1/datanode-dir,/opt/mount2/datanode-dir|' /usr/local/hadoop/current/etc/hadoop/hdfs-site.xml && \
    wget https://gist.github.com/Stupnikov-NA/ba87c0072cd51aa85c9ee6334cc99158/raw/bda0f760878d97213196d634be9b53a089e796ea/yarn-site.xml -O /usr/local/hadoop/current/etc/hadoop/yarn-site.xml && \
      sed -i.backup 's|%YARN_RESOURCE_MANAGER_HOSTNAME%|headnode|' /usr/local/hadoop/current/etc/hadoop/yarn-site.xml && \
      sed -i 's|%NODE_MANAGER_LOCAL_DIR%|/opt/mount1/nodemanager-local-dir,/opt/mount2/nodemanager-local-dir|' /usr/local/hadoop/current/etc/hadoop/yarn-site.xml && \
      sed -i 's|%NODE_MANAGER_LOG_DIR%|/opt/mount1/nodemanager-log-dir,/opt/mount2/nodemanager-log-dir|' /usr/local/hadoop/current/etc/hadoop/yarn-site.xml && \
    echo "export HADOOP_HOME=/usr/local/hadoop/current" >> /etc/profile

# настройка для namenode
RUN mkdir -p /usr/local/hadoop/current/logs && \
    chmod -R g+w /usr/local/hadoop/current/logs && \
    chown -R hadoop:hadoop /usr/local/hadoop/current/logs && \
    chmod -R g+w /opt/hadoop-3.1.2 && \
    chown -R hadoop:hadoop /opt/hadoop-3.1.2/

# для worker меняются пара строк в скрипте, убрана строка с форматированием
RUN touch /usr/local/hadoop/current/etc/hadoop/start.sh && \
    echo "#!/bin/bash" >> /usr/local/hadoop/current/etc/hadoop/start.sh && \
    echo "su -l hdfs -c \"/usr/local/hadoop/current/bin/hdfs --daemon start datanode\"" >> /usr/local/hadoop/current/etc/hadoop/start.sh && \
    echo "su -l hdfs -c \"/usr/local/hadoop/current/bin/yarn --daemon start nodemanager\"" >> /usr/local/hadoop/current/etc/hadoop/start.sh && \
    echo "while :" >> /usr/local/hadoop/current/etc/hadoop/start.sh && \
    echo "do" >> /usr/local/hadoop/current/etc/hadoop/start.sh && \
    echo "sleep 10" >> /usr/local/hadoop/current/etc/hadoop/start.sh && \
    echo "done" >> /usr/local/hadoop/current/etc/hadoop/start.sh

ENTRYPOINT ["/bin/bash", "/usr/local/hadoop/current/etc/hadoop/start.sh"]

EXPOSE 9870 8088

ENV JAVA_HOME=/usr/lib/jvm/jre-1.8.0-openjdk HADOOP_HOME=/usr/local/hadoop/current HADOOP_HEAPSIZE_MAX=512M
```

### 3.	Собрать образа и запушить в репозиторий.

**Для создания образов использовать следующие команды:**
```
docker build -t anmean/hadoop:headnode .
docker build -t anmean/hadoop:worker .
```

**После создания образов создать контейнеры с помощью следующих команд:**
```
docker run --name headnode -v mount1:/opt/mount1 -v mount2:/opt/mount2 --network hadoop-net -p 9870:9870 -p 8088:8088 -d anmean/hadoop:headnode
docker run --name worker -v mount1:/opt/mount1 -v mount2:/opt/mount2 --network hadoop-net -d anmean/hadoop:worker
```

**Теперь можно проверить работу ресурсов на хостовой машине через браузер, открыв сайты:**

192.168.68.109:9870 - откроется ресурс http://192.168.68.109:9870/dfshealth.html#tab-overview

192.168.68.109:8088 - откроется ресурс http://192.168.68.109:8088/cluster

*Примечание! У вас может быть другой ip в зависимости от ip виртуальной машины. Например, 127.0.0.1, если произведен проброс портов. В данном случае на виртуальной машине выставлена сеть в режиме сетевого моста*

*Примечание! Я очень много времени потратил на отлаживание образа: были проблемы с его созданием, запуском, работой в фоне. В итоге я уже счастлив от того, что контейнеры работают. При этом у меня на ресурсах не отображаются значения, которые должны быть, хотя вроде бы все как в экзаменационной работе насколько это удалось. Буду рад любым комментариям о том, где что не так и как это исправить)*

**Чтобы запушить образа в Docker Hub можно использовать следующие команды:**
```
docker push anmean/hadoop:headnode
docker push anmean/hadoop:worker
```

4.	Предоставить два Dockerfiles и имена образов в формате <your account>/<image name>:<tag>, которые можно запустить и проверить, что сервисы доступны и работают. При этом предполагается, что проверяющий не знает, что куда монтировать volumes и какие порты необходимо пробрасывать для корректной работы сервисов.

Dockerfile'ы описаны выше.
anmean/hadoop:headnode - образ headnode
anmean/hadoop:worker - образ worker

5.	* Создать docker-compose.yml файл, запускающий оба образа.
  
*В ходе изучения темы стало очевидно, что docker-compose будет очень удобным для работы с образами, но не хватило времени его отладить. Позднее я так или иначе хотел бы в нем разобраться.*
