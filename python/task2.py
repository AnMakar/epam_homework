### Task 2
# Develop a procedure to print all even numbers from a numbers list which is given as an argument. Keep the original order of numbers in list and stop printing if a number 254 was met. Don't forget to add a check of the passed argument type.

def task2(numbers):
    numbers_even = []
    for i in numbers:
        if type(i) != int:
            print("Аргумент ", i, "неверен. Вводите только целые числа")
            break
        else:
            if i != 254:
                if i % 2 == 0:
                    numbers_even.append(i)
            else:
                break
    return numbers_even


print("---Проверка с целыми числами---")
numbers = [1, 2, 3, 4, 5, 10, 15, 301, 302, 254, 11, 12]
print("Входные данные: ")
print(numbers)
print("Вывод: ")
print(task2(numbers))

print("---Проверка с любыми значениями---")
numbers = [1, 2, 3, 4, "lalala", 10, 15.0, 301, 302, 254, 11, 12]
print("Входные данные: ")
print(numbers)
print("Вывод: ")
print(task2(numbers))
