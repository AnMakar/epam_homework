# Task 7
# Develop a procedure that will have a size argument and print a table where num of columns and rows will be of this size. Cells of table should contain numbers from 1 to n ** 2 placed in a spiral fashion. Spiral should start from top left cell and has a clockwise direction (see the example below).

from numpy import zeros
def task7(size):
    N = size ** 2
    i = 0
    j = 0
    k = 1
    matrix = zeros((size,size), dtype=int)

    while k <= N:
        matrix[i][j] = k
        if i <= j+1 and i+j < size-1:
            j += 1
        elif i < j and i+j >= size-1:
            i += 1
        elif i >= j and i+j > size-1:
            j -= 1
        else:
            i -= 1
        k += 1
    for i in matrix:
        print(*i, sep='\t')

size = int(input("Введите размерность матрицы: "))
task7(size)
