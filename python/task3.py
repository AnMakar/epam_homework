# Task 3
# Something old in a new way :). Self-study positional arguments for Python scripts (sys.argv). Write a script that takes a list of words (or even phrases)aScript should ask a user to write something to stdin until user won't provide one of argument phrases.

from sys import argv

def task3():
        print("Привет, ты в ловушке. Введи слово или фразу из аргументов к этому скрипту, чтобы выбраться! ^_^")
        list = []

        for i in range(1, len(argv)):
                list.append(argv[i])
        print("Нужно ввести одно из этих слов или фраз: ", list)

        check = 0
        while check != 1:
                user_input = input("Введи слово или фразу: ")
                for i in list:
                        if user_input == i:
                                print("Молоток! Ты выбрался!")
                                check = 1
                                break
                        else:
                                continue

task3()
