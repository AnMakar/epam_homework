For each task please provide a separate file (you can do a special folder for it in your git repository to avoid a mess). If task asks you to provide a procedure/function add a call of it to your script. If procedure/function should have a specific behaviour for various cases add calls of it with args demonstrating the cases.

Для начала устанавливаю Python 3-й версии
```
sudo yum install python3 -y
```
Проверяю установленную версию
```
python3 --version
# Python 3.6.8
```

```
mkdir ~/python && cd ~/python # создаем папку для проекта и тут же заходим в нее
pip3 install virtualenv --user # устанавливаем virtualenv для текущего пользователя
virtualenv .venv -p python3 # создаю виртуальное окружение
```

# Task 1
Self-study input() function. Write a script which accepts a sequence of comma-separated numbers from user and generate a list and a tuple with those numbers and prints these objects as-is (just print(list) without any formatting).

Создаю скрипт [task1.py](https://github.com/AnMakar/epam_homework/blob/homework_python/python/task1.py)


Теперь могу проверить работу скрипта
```
python3 task1.py
```

Результат:
```
Введите последовательность чисел (через запятую): 1,2,3,4,5
Это ваш список:
['1', '2', '3', '4', '5']
Это ваш кортеж:
('1', '2', '3', '4', '5')
```

# Task 2
Develop a procedure to print all even numbers from a numbers list which is given as an argument. Keep the original order of numbers in list and stop printing if a number 254 was met. Don't forget to add a check of the passed argument type.
```
cd ~/task2
virtualenv .venv -p python3 # создаю виртуальное окружение
```
Создаю скрипт [task2.py](https://github.com/AnMakar/epam_homework/blob/homework_python/python/task2.py)

Теперь могу проверить работу скрипта
```
python3 task2.py
```

Результат:
```
---Проверка с целыми числами---
Входные данные:
[1, 2, 3, 4, 5, 10, 15, 301, 302, 254, 11, 12]
Вывод:
[2, 4, 10, 302]
---Проверка с любыми значениями---
Входные данные:
[1, 2, 3, 4, 'lalala', 10, 15.0, 301, 302, 254, 11, 12]
Вывод:
Аргумент  lalala неверен. Вводите только целые числа
[2, 4]

Process finished with exit code 0
```

# Task 3
Something old in a new way :). Self-study positional arguments for Python scripts (sys.argv). Write a script that takes a list of words (or even phrases)aScript should ask a user to write something to stdin until user won't provide one of argument phrases.

Исходя из того, что делает функция sys.argv, я понял задание следующим образом:
Пользователем запускается скрипт командой с аргументами наподобие такой - ```python3 task3.py hello "my friend" 1```, после чего пользователю предлагается ввести одно из значений аргументов, чтобы выйти из скрипта. Странно, но допустим.

Создаю скрипт [task3.py](https://github.com/AnMakar/epam_homework/blob/homework_python/python/task3.py)

Теперь могу проверить работу скрипта
```
python3 task3.py hello "my friend" 1
```

Результат:
```
Привет, ты в ловушке. Введи слово или фразу из аргументов к этому скрипту, чтобы выйти ^_^ :
Нужно ввести одно из этих слов или фраз:  ['hello', 'my friend', '1']
Введи слово или фразу: fsdf
Введи слово или фразу: 2
Введи слово или фразу: bie
Введи слово или фразу: my friend
Молоток! Ты выбрался!
```

# Task 4
We took a little look on os module. Write a small script which will print a string using all the types of string formatting which were considered during the lecture with the following context: This script has the following PID: <ACTUAL_PID_HERE>. It was ran by <ACTUAL_USERNAME_HERE> to work happily on <ACTUAL_OS_NAME>-<ACTUAL_OS_RELEASE>.

Создаю скрипт [task4.py](https://github.com/AnMakar/epam_homework/blob/homework_python/python/task4.py)

Теперь могу проверить работу скрипта
```
python3 task4.py
```

Результат:
```
---Оператор %:
This script has the following PID: 1360. It was ran by anme to work happily on posix-3.10.0-1160.el7.x86_64.

---Функция format():
This script has the following PID: 1360. It was ran by anme to work happily on posix-3.10.0-1160.el7.x86_64.

---F-строки:
This script has the following PID: 1360. It was ran by anme to work happily on posix-3.10.0-1160.el7.x86_64.
```


# Task 5
Develop a function that takes a list of integers (by idea not in fact) as an argument and returns list of top-three max integers. If passed list contains not just integers collect them and print the following error message: You've passed some extra elements that I can't parse: [<"elem1", "elem2" .... >]. If return value will have less than 3 elements for some reason it's ok and shouldn't cause any problem, but some list should be returned in any case.

Создаю скрипт [task5.py](https://github.com/AnMakar/epam_homework/blob/homework_python/python/task5.py).

Теперь могу проверить работу скрипта
```
python3 task5.py
```

Результат:
```
---Обычные значения---
Заданные значения: [1, 2, 3, 10, 200]
[200, 10, 3]
---Неверные значения---
Заданные значения: [1, 2, 1.5, 'hello', 3, 10, 200]
Вы передали некоторые дополнительные элементы, которые я не могу разобрать: [1.5, 'hello']
[200, 10, 3]
---Недостаточно значений---
Заданные значения: [1, 2]
[3, 2]

Process finished with exit code 0
```
# Task 6
Create a function that will take a string as an argument and return a dictionary where keys are symbols from the string and values are the count of inclusion of that symbol.

Создаю скрипт [task6.py](https://github.com/AnMakar/epam_homework/blob/homework_python/python/task6.py)

Теперь могу проверить работу скрипта
```
python3 task6.py
```

Результат:
```
---С помощью модуля collections---
Counter({' ': 18, 't': 11, 'o': 6, 'a': 6, 'n': 5, 'e': 5, 'r': 5, 'i': 3, 'w': 3, 's': 3, 'd': 2, 'h': 2, 'l': 2, 'f': 2, '.': 2, 'u': 2, "'": 1, 'I': 1, 'j': 1, 'm': 1, 'y': 1})
Counter({'a': 3, 'b': 2, 'c': 2, 'd': 1})
---С помощью функции---
{'i': 3, ' ': 18, 'd': 2, 'o': 6, 'n': 5, "'": 1, 't': 11, 'w': 3, 'a': 6, 's': 3, 'e': 5, 'h': 2, 'r': 5, 'l': 2, 'f': 2, '.': 2, 'I': 1, 'j': 1, 'u': 2, 'm': 1, 'y': 1}
{'a': 3, 'b': 2, 'c': 2, 'd': 1}

Process finished with exit code 0
```

# Task 7
Develop a procedure that will have a size argument and print a table where num of columns and rows will be of this size. Cells of table should contain numbers from 1 to n ** 2 placed in a spiral fashion. Spiral should start from top left cell and has a clockwise direction (see the example below).

example:
```
>>> print_spiral(5)
1 2 3 4 5
16 17 18 19 6
15 24 25 20 7
14 23 22 21 8
13 12 11 10 9
```

Я бы хотел в данном задании воспользоваться модулем NumPy для создания матрицы с нулями, поэтому предварительно установлю нужный отсутствующий модуль
```
pip3 install numpy --user
```
Создаю скрипт [task7.py](https://github.com/AnMakar/epam_homework/blob/homework_python/python/task7.py)

Теперь могу проверить работу скрипта
```
python3 task7.py
```
Результат:
```
Введите размерность матрицы: 5
1	2	3	4	5
16	17	18	19	6
15	24	25	20	7
14	23	22	21	8
13	12	11	10	9
```

# Task 8*
You have had AWK homework (3-4), please find a document in a homework Slack thread. Do all the same AWK tasks using Python.

# Task 9*
For this task you need to have docker daemon installed and running.  The task is to create a python script, that has following functions:  1. connects to docker API and print a warning message if there are dead or stopped containers with their ID and name. 2. containers list, similar to docker ps -a  3. image list, similar to docker image ls 4. container information, like docker inspect  Connection function must accept connection string for example 'http://192.168.56.101:2376' and connect to it or use string from environment if no connection string is given.    In order to connect to docker, you can use either Unix socket or reconfigure daemon to use a network socket (https://docs.docker.com/engine/reference/commandline/dockerd/#daemon-socket-option)
