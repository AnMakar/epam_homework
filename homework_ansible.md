# 1. Создать 3 ВМ

192.168.68.119 - ansible_1 # master\
192.168.68.120 - ansible_2 \
192.168.68.121 - ansible_3


# 2. На одной из них установить ansible и создать отдельного пользователя, из-под которого он будет запускаться

```
sudo yum install epel-release -y
sudo yum install ansible -y # from epel
sudo useradd ansible
sudo passwd ansible
sudo usermod -aG wheel ansible
su ansible # переключаюсь на УЗ, с которой будет осуществляться управление Ansible
```

# 3. Используя ansible ad-hoc:

## 3.1 ansible hosts-file
Редактирую /etc/ansible/hosts. Добавляю строки
```
[nodes]
ansible_1 ansible_host=192.168.68.119
ansible_2 ansible_host=192.168.68.120
ansible_3 ansible_host=192.168.68.121
```
Можно проверить
```
ansible all --list-hosts
```
```
  hosts (3):
    ansible_1
    ansible_2
    ansible_3
```
Так работает, пробую с помощью YAML \

## 3.2 ansible inventory.yaml-file

Создаю inventory.yaml
```
all:
  children:
    Nodes:
      hosts:
        ansible_1:
          ansible_host: 192.168.68.120
        ansible_2:
          ansible_host: 192.168.68.121
```

Добавил в /etc/ansible/ansible.cfg несколько настроек
```
[defaults]
inventory       = /home/ansible/inventory.yaml

[inventory]
enable_plugins = yaml
```

Для проверки соединения с хостом ```ansible ansible_1 -m ping -u root -k```
Консоль запрашивает SSH password и затем выводит в консоль следующее:
```
ansible_1 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    },
    "changed": false,
    "ping": "pong"
}
```

(В некоторых случаях может выдавать ошибку типа ```Using a SSH password instead of a key is not possible because Host Key checking is enabled and sshpass does not support this.  Please add this host's fingerprint to your known_hosts file to manage this host```, тогда можно отключить опцию host_key_checking в ansible.conf)
(Причина: You are getting this error because when we do SSH in the remote system it will ask yes or no. But Ansible doesn't have the capability to ask this in run time.)

###  - создать такого же пользователя на остальных машинах

```
ansible all -k -u root -m user -a name=ansible
```
```
ansible_1 | CHANGED => {
  "ansible_facts": {
      "discovered_interpreter_python": "/usr/bin/python"
  },
  "changed": true,
  "comment": "",
  "create_home": true,
  "group": 1001,
  "home": "/home/ansible",
  "name": "ansible",
  "shell": "/bin/bash",
  "state": "present",
  "system": false,
  "uid": 1001
}
ansible_2 | CHANGED => {
  "ansible_facts": {
      "discovered_interpreter_python": "/usr/bin/python"
  },
  "changed": true,
  "comment": "",
  "create_home": true,
  "group": 1001,
  "home": "/home/ansible",
  "name": "ansible",
  "shell": "/bin/bash",
  "state": "present",
  "system": false,
  "uid": 1001
}
```

###  - подложить ему ssh-ключи
```
ansible all -k -u root -m user -a "name=ansible generate_ssh_key=yes"
```
_(Полагаю тут можно было бы обойтись и просто созданием папки .ssh, но я просто предполагал, что эта команда сможет сгенерировать и переслать все ключи как надо. Не удалось, поэтому придется копировать)_

Сначала сгенерирую ключи
```
ssh-keygen -t rsa
```
Теперь скопирую
```
ansible all -k -u root -m copy -a "src=/home/ansible/.ssh/id_rsa.pub mode=644 dest=/home/ansible/.ssh/authorized_keys"
```
Теперь можно изменить inventory и добавить туда авторизацию по ключу
```
all:
  children:
    Nodes:
      hosts:
        ansible_1:
          ansible_host: 192.168.68.120
          ansible_user: ansible
          ansible_ssh_private_key_file: /home/ansible/.ssh/id_rsa
        ansible_2:
          ansible_host: 192.168.68.121
          ansible_user: ansible
          ansible_ssh_private_key_file: /home/ansible/.ssh/id_rsa
```
Теперь можно проверить работу без запроса SSH-password
```
ansible all -m ping
```
```
ansible_1 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    },
    "changed": false,
    "ping": "pong"
}
ansible_2 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    },
    "changed": false,
    "ping": "pong"
}
```

Однако замечу, что пусть здесь и сработало, но в остальных командах далее наблюдались ошибки при попытке использовать команды без опции -k, т.е. почему-то ssh-ключи не срабатывали. Ошибка следующая:
```
fatal: [ansible_1]: UNREACHABLE! => {"changed": false, "msg": "Failed to connect to the host via ssh: Permission denied (publickey,gssapi-keyex,gssapi-with-mic,password).", "unreachable": true}
```
Решения найти пока не удалось. В целом ситуация с SSH-ключами неоднозначная. Вероятно, должен быть способ настраивать подключение через них гораздо проще. Казалось бы, что в этом должна помогать команда ```generate_ssh_key=yes```, но она, похоже, немного для другого.

###  - дать возможность использовать sudo (помните о том, что редактирование /etc/sudoers не через visudo - плохая идея)
Добавить в группу wheel (хотя я сделал это еще на предыдущем пункте после создания пользователя)
Это легко делается командой
```
ansible all -k -u root -m user -a "name=ansible groups=wheel append=yes"
```

# 4. написать плейбук, со ролями, которые позволят:
###  - создать пользователя из п.2; обновить все пакеты в системе

```
sudo ansible-playbook playbook_user.yaml -k --check
sudo ansible-playbook playbook_user.yaml -k

PLAY [all] *******************************************************************************************

TASK [Gathering Facts] *******************************************************************************
ok: [ansible_2]
ok: [ansible_1]

TASK [add_user : Add new user ansible] ***************************************************************
ok: [ansible_1]
ok: [ansible_2]

TASK [add_user : Update packages] ********************************************************************
changed: [ansible_2]
changed: [ansible_1]

PLAY RECAP *******************************************************************************************
ansible_1                  : ok=3    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
ansible_2                  : ok=3    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

###  - установить ntp-сервер и заменить его стандартный конфиг на кастомный (примеры можно поискать в сети)
```
sudo ansible-playbook playbook_ntp.yaml -k

PLAY [all] *******************************************************************************************

TASK [Gathering Facts] *******************************************************************************
ok: [ansible_1]
ok: [ansible_2]

TASK [install_ntp : Install NTP server] **************************************************************
ok: [ansible_1]
ok: [ansible_2]

TASK [install_ntp : Copy config file for NTP] ********************************************************
ok: [ansible_2]
ok: [ansible_1]

PLAY RECAP *******************************************************************************************
ansible_1                  : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
ansible_2                  : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

###  - установить mysql-сервер, создать пользователя БД и саму базу данных

Написание плейбука для MySQL далось очень тяжело, перелопатил много разных вариантов плейбуков в интернете, чтобы разобраться как оно хоть примерно должно бы отрабатывать. Ранее я не углублялся в работу MySQL и не очень понимаю как оно без и плейбука-то должно работать. Поэтому большая часть плейбука выполняется и я уже рад. Финальную ошибку устранить пока не удалось.

```
sudo ansible-playbook playbook_mysql.yaml -k
SSH password:

PLAY [all] *******************************************************************************************

TASK [Gathering Facts] *******************************************************************************
ok: [ansible_2]
ok: [ansible_1]

TASK [install_mysql : create directory] **************************************************************
ok: [ansible_2]
ok: [ansible_1]

TASK [install_mysql : download sources] **************************************************************
ok: [ansible_1]
ok: [ansible_2]

TASK [install_mysql : Install MySQL package] *********************************************************
ok: [ansible_1]
ok: [ansible_2]

TASK [install_mysql : install mysql server] **********************************************************
ok: [ansible_2]
ok: [ansible_1]

TASK [install_mysql : Start up the mysqld service] ***************************************************
ok: [ansible_2]
ok: [ansible_1]

TASK [install_mysql : update mysql root password for all root accounts] ******************************
fatal: [ansible_1]: FAILED! => {"msg": "The task includes an option with an undefined variable. The error was: 'item' is undefined\n\nThe error appears to be in '/home/ansible/playbook/roles/install_mysql/tasks/main.yaml': line 30, column 3, but may\nbe elsewhere in the file depending on the exact syntax problem.\n\nThe offending line appears to be:\n\n\n- name: update mysql root password for all root accounts\n  ^ here\n"}
fatal: [ansible_2]: FAILED! => {"msg": "The task includes an option with an undefined variable. The error was: 'item' is undefined\n\nThe error appears to be in '/home/ansible/playbook/roles/install_mysql/tasks/main.yaml': line 30, column 3, but may\nbe elsewhere in the file depending on the exact syntax problem.\n\nThe offending line appears to be:\n\n\n- name: update mysql root password for all root accounts\n  ^ here\n"}

PLAY RECAP *******************************************************************************************
ansible_1                  : ok=6    changed=0    unreachable=0    failed=1    skipped=0    rescued=0    ignored=0
ansible_2                  : ok=6    changed=0    unreachable=0    failed=1    skipped=0    rescued=0    ignored=0

``` 

###  - * установить nginx и настроить его так, чтобы он обслуживал сайт example.com; содержимое сайта должно лежать в /var/www-data/example.com и представлять из себя любой валидный html-документ
##  - * установить docker в соответствии с инструкцией https://docs.docker.com/engine/install/centos/

```
sudo ansible-playbook playbook_docker.yaml -k
SSH password:

PLAY [all] *******************************************************************************************

TASK [Gathering Facts] *******************************************************************************
ok: [ansible_2]
ok: [ansible_1]

TASK [install_docker : Install yum utils, device-mapper-persistent-data] *****************************
ok: [ansible_1]
ok: [ansible_2]

TASK [install_docker : add docker repo] **************************************************************
ok: [ansible_2]
ok: [ansible_1]

TASK [install_docker : install docker engine] ********************************************************
ok: [ansible_2]
ok: [ansible_1]

TASK [install_docker : start docker] *****************************************************************
ok: [ansible_2]
ok: [ansible_1]

PLAY RECAP *******************************************************************************************
ansible_1                  : ok=5    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
ansible_2                  : ok=5    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

```