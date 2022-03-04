# Task 5
# Develop a function that takes a list of integers (by idea not in fact) as an argument and returns list of top-three max integers. If passed list contains not just integers collect them and print the following error message: You've passed some extra elements that I can't parse: [<"elem1", "elem2" .... >]. If return value will have less than 3 elements for some reason it's ok and shouldn't cause any problem, but some list should be returned in any case.

def task5(numbers):
    not_numbers = []
    max_numbers = []
    for i in numbers:
        if type(i) != int:
            not_numbers.append(i)
    if not_numbers:
        print("Вы передали некоторые дополнительные элементы, которые я не могу разобрать:", not_numbers)
        for i in not_numbers: # удалить элементы списка not_numbers из списка
            numbers.remove(i)
    # numbers
    for i in range(3):
        if not numbers:
            break
        max_numbers.append(max(numbers))
        numbers.remove(max(numbers))
    return(max_numbers)

print("---Обычные значения---")
numbers = [1, 2, 3, 10, 200]
print("Заданные значения:", numbers)
print(task5(numbers))

print("---Неверные значения---")
numbers = [1, 2, 1.5, "hello", 3, 10, 200]
print("Заданные значения:", numbers)
print(task5(numbers))

print("---Недостаточно значений---")
print("Заданные значения:", numbers)
numbers = [2, 3]
print(task5(numbers))
