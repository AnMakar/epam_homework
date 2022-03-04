# task1 script
inputlist = input("Введите последовательность чисел (через запятую): ")
inputlist_r = inputlist.replace(',','')

mylist = list(inputlist_r)
print("Это ваш список: ")
print(mylist)

mytuple = tuple(inputlist_r)
print("Это ваш кортеж: ")
print(mytuple)
