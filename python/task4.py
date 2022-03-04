# Task 4
# We took a little look on os module. Write a small script which will print a string using all the types of string formatting which were considered during the lecture with the following context: This script has the following PID: . It was ran by to work happily on -.

import os

ACTUAL_PID_HERE = os.getpid()
ACTUAL_USERNAME_HERE = os.getlogin()
ACTUAL_OS_NAME = os.name
ACTUAL_OS_RELEASE = os.uname().release
# согласно ресурсу https://pythonworld.ru/moduli/modul-os.html
# os.name - имя операционной системы. Доступные варианты: 'posix', 'nt', 'mac', 'os2', 'ce', 'java'.
# если имелось ввиду имя операционной системы "Linux", то можно было бы воспользоваться os.uname().sysname

print("---Оператор %: ")
print("This script has the following PID: %s. It was ran by %s to work happily on %s-%s." % (ACTUAL_PID_HERE, ACTUAL_USERNAME_HERE, ACTUAL_OS_NAME, ACTUAL_OS_RELEASE))
print()

print("---Функция format(): ")
print("This script has the following PID: {}. It was ran by {} to work happily on {}-{}.".format(ACTUAL_PID_HERE, ACTUAL_USERNAME_HERE, ACTUAL_OS_NAME, ACTUAL_OS_RELEASE))
print()

print("---F-строки: ")
print(f"This script has the following PID: {ACTUAL_PID_HERE}. It was ran by {ACTUAL_USERNAME_HERE} to work happily on {ACTUAL_OS_NAME}-{ACTUAL_OS_RELEASE}.")
