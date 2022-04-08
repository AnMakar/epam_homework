# Задача 1. Работа с локальным репозиторием

### 1. Создать локальный репозиторий "git-lesson"

`sudo yum install git -y` - установить git

`mkdir git-lesson && cd ./git-lesson` - создать директорию для репозитория и перейдем в неё

`git init` - Эта команда создаёт в текущем каталоге новый подкаталог с именем .git, содержащий все необходимые файлы репозитория — структуру Git репозитория.

### 2. Создать пустой файл README.md и закоммитить изменения.

`nano README.md` - Создаю файл и добавляю в него неекоторый текст командой

`git add README.md` - Добавить файл под версионный контроль

`git commit -m "Add README.md"` - Коммитим изменения с комментарием

Результат:

```
[master (root-commit) 4e37e8c] Add README.md
 Committer: anme <anme@localhost.localdomain>
Your name and email address were configured automatically based
on your username and hostname. Please check that they are accurate.
You can suppress this message by setting them explicitly:

    git config --global user.name "Your Name"
    git config --global user.email you@example.com

After doing this, you may fix the identity used for this commit with:

    git commit --amend --reset-author

 1 file changed, 1 insertion(+)
 create mode 100644 README.md
```

### 3. Создать дополнительную ветку "feat1-add-readme", добавить в файл README.md немного текста. Изменения закоммитить.

`git branch feat1-add-readme` - Добавляю новую ветку

`git branch -a` - Могу посмотреть все ветки

`git checkout feat1-add-readme` - Переключение на новую ветку

```
feat1-add-readme
* master
```

`echo "feat1-add-readme - ветка для проверки добавления изменений в файл README.md" >> README.md` - Добавляю строчку в README.md

`git commit -m "Добавил новую строчку в README.MD"` - пытаюсь коммитить изменения в новой ветке
```
# On branch feat1-add-readme
# Changes not staged for commit:
#   (use "git add <file>..." to update what will be committed)
#   (use "git checkout -- <file>..." to discard changes in working directory)
#
#       modified:   README.md
#
no changes added to commit (use "git add" and/or "git commit -a")
```

Похоже, что после смены ветки файл снова нужно добавлять в отслеживание

`git add README.md`

```
[feat1-add-readme b008144] Добавил новую строчку в README.MD
 Committer: anme <anme@localhost.localdomain>
Your name and email address were configured automatically based
on your username and hostname. Please check that they are accurate.
You can suppress this message by setting them explicitly:

    git config --global user.name "Your Name"
    git config --global user.email you@example.com

After doing this, you may fix the identity used for this commit with:

    git commit --amend --reset-author

 1 file changed, 1 insertion(+)
```

### 4. Переключиться обратно на "master" ветку и так же добавить в README.md немного другого текста

`git checkout master` - переключение на ветку мастер

`echo "Master ветка теперь в файле README.md должна содержать новый текст" >> README.md`

`git commit -a -m "Добавил новую строчку в README.md, которое должно конфликтовать с веткой
feat1-add-readme"`

```
[master b9714ff] Добавил новую строчку в README.md, которое должно конфликтовать с веткой feat1-add-readme
 Committer: anme <anme@localhost.localdomain>
Your name and email address were configured automatically based
on your username and hostname. Please check that they are accurate.
You can suppress this message by setting them explicitly:

    git config --global user.name "Your Name"
    git config --global user.email you@example.com

After doing this, you may fix the identity used for this commit with:

    git commit --amend --reset-author

 1 file changed, 1 insertion(+)
```

### 5. Смержить изменения из "feat1-add-readme" в "master" ветку так, чтобы сохранились изменения только из "feat1-add-readme" ветки

Пробую провести слияние веток
`git merge feat1-add-readme`

Естественно вижу наличие конфликта
```
Auto-merging README.md
CONFLICT (content): Merge conflict in README.md
Automatic merge failed; fix conflicts and then commit the result.
```
Соответственно сейчас файл README.md выглядит так:
```
Привет, это файл README.md, созданный для репозитория git-lesson в ходе изучения урока по системе контроля версий GIT
<<<<<<< HEAD
Master ветка теперь в файле README.md должна содержать новый текст
=======
feat1-add-readme - ветка для проверки добавления изменений в файл README.md
>>>>>>> feat1-add-readme
```

Самый простой способ разрешить конфликт — отредактировать конфликтующий файл. После редактирования файла выполнить команду `git add README.md`, чтобы добавить новое объединенное содержимое в раздел проиндексированных файлов

Открываю README.md, удаляю строки с `<<<<<<< HEAD`, `=======`, `>>>>>>> feat1-add-readme` и конфликтующую строку `Master ветка теперь в файле README.md должна содержать новый текст`, оставляя только строчку из другой ветки

`git add README.md` - отмечаю конфликт как решённый. Добавление файла в индекс означает для Git, что все конфликты в нём исправлены.

В дальнейшем можно использовать графический инструмент для разрешения конфликтов. Можно запустить `git mergetool`, который проведет по всем конфликтам. Если нужно использовать инструмент слияния не по умолчанию или инструмент не выюран/установлен, то `git mergetool` выдаст следующее сообщение:
```
This message is displayed because 'merge.tool' is not configured.
See 'git mergetool --tool-help' or 'git help config' for more details.
'git mergetool' will now attempt to use one of the following tools:
tortoisemerge emerge vimdiff
No known merge tool is available.
```
Т.е. можно выбрать один из следующих инструментов:
* tortoisemerge
* emerge
* vimdiff

Если всё устраивает и все файлы, где были конфликты, добавлены в индекс - выполняю команду `git commit` для создания коммита слияния.

`git commit -m "Проведено слияние веток master и feat1-add-readme, устранен конфликт в файле README.md"`

В качестве дополнительного материала по теме использовал статью https://git-scm.com/book/ru/v2/Ветвление-в-Git-Основы-ветвления-и-слияния

### 6. Переключиться обратно на "feat1-add-readme" ветку, создать файл temp_file и закоммитить изменения

`git checkout feat1-add-readme`

`touch temp_file`

`git add temp_file`

`git commit -a -m "Добавил файл temp_file"`

### 7. Отменить изменения, вносимые первым коммитом ветки "feat1-add-readme"

В `man git revert` есть следующий абзац:
```
Note: git revert is used to record some new commits to reverse the effect of some earlier commits (often only
       a faulty one). If you want to throw away all uncommitted changes in your working directory, you should see
       git-reset(1), particularly the --hard option. If you want to extract specific files as they were in another
       commit, you should see git-checkout(1), specifically the git checkout <commit> -- <filename> syntax. Take care
       with these alternatives as both will discard uncommitted changes in your working directory.
```

Т.е. можно отменить изменения после какого-то коммита несколькими способами:
* `git revert`
* `git reset`
* `git checkout`

Заценим `git log`
```
commit 94e43218a66356ca74792ce283fff6d9316986c7
Author: anme <anme@localhost.localdomain>
Date:   Thu Mar 24 22:26:22 2022 +0300

    Добавил файл temp_file

commit b00814409f817f0db9f7b5fb740fad15fbae3a6b
Author: anme <anme@localhost.localdomain>
Date:   Thu Mar 24 21:30:26 2022 +0300

    Добавил новую строчку в README.MD

commit 4e37e8cebf0a4a3b35a52108d5f75baceecb2bc4
Author: anme <anme@localhost.localdomain>
Date:   Thu Mar 24 21:07:05 2022 +0300

    Add README.md
```

`git revert b00814409f817f0db9f7b5fb740fad15fbae3a6b` - Отменяю изменения, внесенные ранним коммитом

```
[feat1-add-readme b4fe5ff] This reverts commit b00814409f817f0db9f7b5fb740fad15fbae3a6b.
 Committer: anme <anme@localhost.localdomain>
Your name and email address were configured automatically based
on your username and hostname. Please check that they are accurate.
You can suppress this message by setting them explicitly:

    git config --global user.name "Your Name"
    git config --global user.email you@example.com

After doing this, you may fix the identity used for this commit with:

    git commit --amend --reset-author

 1 file changed, 1 deletion(-)
```

`ls` - файл temp_file в директории остался
```
README.md  temp_file
```
`cat README.md` - а вот строка в README.md пропала
```
Привет, это файл README.md, созданный для репозитория git-lesson в ходе изучения урока по системе контроля версий GIT
```

Полезные ссылки:
- [Конфликты слияния](https://www.atlassian.com/ru/git/tutorials/using-branches/merge-conflicts)

# Задача 2. Работа с удаленным репозиторием

### 1. Создать пустой репозиторий в GitHub "git-lesson".

https://github.com/AnMakar/git-lesson

### 2. Сделать этот репозиторий удаленным для локального репозитория из первой задачи

Находясь в директории моего локального репозитория, необходимо использовать команду
`git remote add git-lesson https://github.com/AnMakar/git-lesson.git`

Теперь команда `git remote` выдаст список удаленных репозиториев:
```
git-lesson
```

### 3. Отправить изменения из всех веток в "git-lesson" репозиторий

`git push git-lesson master`
```
Username for 'https://github.com': AnMakar
Password for 'https://AnMakar@github.com':
remote: Support for password authentication was removed on August 13, 2021. Please use a personal access token instead.
remote: Please see https://github.blog/2020-12-15-token-authentication-requirements-for-git-operations/ for more information.
fatal: Authentication failed for 'https://github.com/AnMakar/git-lesson.git/'
```

На данный момент просто с логином-паролем из git авторизацию пройти мне не удалось. Необходимо использовать токен или иные способы. Инструкция для создания токена - https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token

`git push git-lesson master`
```
Username for 'https://github.com': anmakar
Password for 'https://anmakar@github.com':
Counting objects: 10, done.
Compressing objects: 100% (7/7), done.
Writing objects: 100% (10/10), 1.25 KiB | 0 bytes/s, done.
Total 10 (delta 3), reused 0 (delta 0)
remote: Resolving deltas: 100% (3/3), done.
To https://github.com/AnMakar/git-lesson.git
 * [new branch]      master -> master
```

`git push git-lesson feat1-add-readme`
```
Username for 'https://github.com': anmakar
Password for 'https://anmakar@github.com':
Counting objects: 8, done.
Compressing objects: 100% (5/5), done.
Writing objects: 100% (6/6), 602 bytes | 0 bytes/s, done.
Total 6 (delta 1), reused 0 (delta 0)
remote: Resolving deltas: 100% (1/1), completed with 1 local object.
remote:
remote: Create a pull request for 'feat1-add-readme' on GitHub by visiting:
remote:      https://github.com/AnMakar/git-lesson/pull/new/feat1-add-readme
remote:
To https://github.com/AnMakar/git-lesson.git
 * [new branch]      feat1-add-readme -> feat1-add-readme
```

### 4. Заменить содержимое README.md в ветке "feat1-add-readme" строкой "Hello Github", закоммитить и отправить в "git-lesson" репо

Уже нахожусь в ветке feat1-add-readme
`echo "Hello Github" > README.md`

`git commit -am "Заменил всё содержимое README.md для того, чтобы отправить это мзменение на Github"`

`git push git-lesson feat1-add-readme`
```
Username for 'https://github.com': anmakar
Password for 'https://anmakar@github.com':
Counting objects: 5, done.
Compressing objects: 100% (2/2), done.
Writing objects: 100% (3/3), 399 bytes | 0 bytes/s, done.
Total 3 (delta 0), reused 0 (delta 0)
To https://github.com/AnMakar/git-lesson.git
   b4fe5ff..bf3b7f4  feat1-add-readme -> feat1-add-readme
```

### 5. Сделать Pull-Request из ветки "feat1-add-readme" в "master" и добавить меня (@vauboy) ревьювером

К сожалению, я так и не понял как выполнить эту операцию в терминале.

Кроме того, если подразумевалось выполнять данную операцию через интерфейс GitHub, то я пока не смог разобраться в теме ревьюверов и как это в принципе должно выглядеть. При попытке выполнить pull request поле ревьюверов не позволяет выбрать кого-то через @. Не смог однозначно определеить как работает данный функционал.

# Задача 3. Знакомство с GitLab Community Edition

### 1. Запустить Gitlab CE в докере "gitlab/gitlab-ce:latest"

Несколько раз пытался настраивать gitlab в докере, он тормозил, запускался со статусом unhealthy, не был доступен веб-интерфейс и т.д. В итоге подобрал оптимальные настройки для виртуальной машины: 4096 Мб оперативной памяти, половина процессорной мощности - это решило проблемы с unhealthy
  
С хостовой машины никак не удавалось получить доступ к веб-интерфейсу, ни по `gitlab.example.com`, ни по `127.0.0.1`, ни с какими настройками переадресации портов
  
В итоге установил Fedora Linux и все скриншоты снял прямиком из виртуальной машины
  
`mkdir ~/{gitlab,gitlab-runner}` 
`export GITLAB_HOME=$HOME/gitlab` 
`export GITLABR_HOME=$HOME/gitlab-runner`
`sudo docker run --detach --net host --name gitlab --hostname gitlab.example.com --publish 443:443 --publish 80:80 --publish 22:22 --restart always --volume $GITLAB_HOME/config:/etc/gitlab --volume $GITLAB_HOME/logs:/var/log/gitlab --volume $GITLAB_HOME/data:/var/opt/gitlab --shm-size 256m gitlab/gitlab-ce:latest`

GitLab у меня открылся по адресу 127.0.0.1, при этом gitlab.example.com всё ещё не открывался.

`sudo docker exec -it gitlab grep 'Password:' /etc/gitlab/initial_root_password`
onVTDmbg83LUPj+vDtwbjmKkFZdkH8ZopGjwKFjQHRg=

### Необходимо сделать скриншоты на всех последующих этапах и приложить в виде архива

Все скриншоты вложены в архив gitlab.rar
https://github.com/AnMakar/epam_homework/blob/21c95ba83e097597af4eb5c6c88c00f8dd7e0305/gitlab.rar

### 2. Создать группу "devops-course"
### 3. Создать пользователей: developer1 и developer2
### 4. Добавить их в группу и назначить следующие пермишены:
        developer1 – maintainer
        developer2 – developer
### 5. Создать новый проект
### 6. Создать все необходимые для GitFlow ветки в проекте (например main, develop, release-v1, feature1)
### 7. Запретить отправку изменений в “main” ветку для всех пользователей - означает, что никто не может делать push в main ветку. Единственный вариант внесения изменений - через MR Мэинтейнером
### 8. Защитить релизные ветки с помощью wildcard (например release-*) и разрешить слияние только пользователям с уровнем доступа maintainer
### 9. Защитить develop ветку и разрешить создавать Merge Requests всем пользователям. Под всеми пользователями имеются ввиду developer+maintainer
### 10. Разрешить всем вносить любые изменения в "feature-*" ветки

Полезные ссылки:
- [Add users to a group](https://docs.gitlab.com/ee/user/group/#add-users-to-a-group)
- [Default branch](https://docs.gitlab.com/ee/user/project/repository/branches/default.html)
- [Protected branches](https://docs.gitlab.com/ee/user/project/protected_branches.html#protected-branches)

Дополнительно (*)

Добавить GitHub Action скрипт в репозиторий из Задачи 2, который будет выводить фразу "Hello Pull-Request" только при создании PR.

Полезные ссылки:
- [Events that trigger workflows](https://docs.github.com/en/actions/using-workflows/events-that-trigger-workflows)
