# Task 6
# Create a function that will take a string as an argument and return a dictionary where keys are symbols from the string and values are the count of inclusion of that symbol.

from collections import Counter # могу воспользоваться уже готовым модулем collections

def task6(string): # или воспользоваться отдельной функцией
    dict = {}
    for i in string:
        counter = 0
        for j in string:
            if i == j:
                counter = counter + 1
        dict[i] = counter
    return(dict)

string = "i don't want to set the world on fire. I just want to start a flame in your heart."
short_string = "aaabcbcd"

print("---С помощью модуля collections---")
print(Counter(string))
print(Counter(short_string))

print("---С помощью функции---")
print(task6(string))
print(task6(short_string))
