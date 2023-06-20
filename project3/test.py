# global variables
n = 8

# iterative function
def itFibonacci(n):
    Fn = 1
    FNminus1 = 1

    if n <= 2:
        return Fn

    while n > 2:
        temp = Fn
        Fn = Fn + FNminus1
        FNminus1 = temp
        n = n - 1

    return Fn

# main program
print("N: ")
print(n)
print("Result of iterative computation: ", itFibonacci(n))
