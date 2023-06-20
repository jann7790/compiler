import random

# List of valid Turing code constructs
turing_code_constructs = [
    "var",
    "if",
    "for",
    "write",
    "func",
    "opt",
    "logic",
]

# List of valid Turing conditions
turing_conditions = [
    "<",
    "<=",
    "=",
    ">=",
    ">",
]

# List of valid Turing arithmetic operations
turing_arithmetic_operations = [
    "+",
    "-",
    "*",
    "/",
]

# List of valid Turing logical operations
turing_logical_operations = [
    "and",
    "not",
    "or",
    "mod",
]

# List to store declared variables
declared_variables = []
def subProgram():
    code = ""
    if depth >= 10:
        return code
    # Generate a random number of code lines
    num_lines = random.randint(1, 5)
    
    for _ in range(num_lines):
        # Choose a random Turing code construct
        construct = random.choice(turing_code_constructs)
        
        # Generate code based on the chosen construct
        if construct == "var":
            variable_name = random.choice(["x", "y", "z"])
            variable_value = random.randint(0, 100)
            declared_variables.append(variable_name)
            code += f"var {variable_name} : int := {variable_value}\n"
        elif construct == "if":
            condition = random.choice(turing_conditions)
            a = random.choice([random.randint(0, 100)] + declared_variables)
            b = random.choice([random.randint(0, 100)] + declared_variables)
            condition = str(a) + condition + str(b)
            code += f"if ({condition})then\n    {generate_random_turing_code(9)}\nend if\n"
        elif construct == "for":
            loop_variable = random.choice(["i", "j", "k"])
            loop_start = random.randint(1, 10)
            loop_end = random.randint(loop_start + 1, 20)
            code += f"for {loop_variable} : {loop_start} .. {loop_end} \n    {generate_random_turing_code(9)}\nend for\n"
        elif construct == "write":
            if declared_variables:
                variable_name = random.choice(declared_variables)
                code += f"put {variable_name}\n"
        elif construct == "func" and depth == 0:
            function_name = random.choice(["func1", "func2", "func3"])
            num_params = random.randint(1, 3)
            params = ", ".join(random.choice(["a:int", "b:int", "c:int"]) for _ in range(num_params))
            r = random.choice(["a", "b", "c"])
            code += f"function {function_name}({params}) : int\n    {generate_random_turing_code(9)}\n    result {r}\nend {function_name}\n"
        elif construct == "opt":
            if declared_variables:
                variable_name = random.choice(declared_variables)
                operand = random.choice([random.randint(0, 100)] + declared_variables)
                code += f"{variable_name} := {variable_name} {random.choice(turing_arithmetic_operations)} {operand}\n"
        elif construct == "logic":
            if declared_variables:
                variable_name = random.choice(declared_variables)
                operand = random.choice([random.randint(0, 100)] + declared_variables)
                # rand choice of logical operation
                code += f"{variable_name} := {variable_name} {random.choice(turing_logical_operations)} {operand}\n"


    return code

# Generate a random Turing code snippet
def generate_random_turing_code(depth):
    code = ""
    if depth >= 10:
        return code
    # Generate a random number of code lines
    num_lines = random.randint(1, 5)
    
    for _ in range(num_lines):
        # Choose a random Turing code construct
        construct = random.choice(turing_code_constructs)
        
        # Generate code based on the chosen construct
        if construct == "var":
            variable_name = random.choice(["x", "y", "z"])
            variable_value = random.randint(0, 100)
            declared_variables.append(variable_name)
            code += f"var {variable_name} : int := {variable_value}\n"
        elif construct == "if":
            condition = random.choice(turing_conditions)
            a = random.choice([random.randint(0, 100)] + declared_variables)
            b = random.choice([random.randint(0, 100)] + declared_variables)
            condition = str(a) + condition + str(b)
            code += f"if ({condition})then\n    {generate_random_turing_code(9)}\nend if\n"
        elif construct == "for":
            loop_variable = random.choice(["i", "j", "k"])
            loop_start = random.randint(1, 10)
            loop_end = random.randint(loop_start + 1, 20)
            code += f"for {loop_variable} : {loop_start} .. {loop_end} \n    {generate_random_turing_code(9)}\nend for\n"
        elif construct == "write":
            if declared_variables:
                variable_name = random.choice(declared_variables)
                code += f"put {variable_name}\n"
        elif construct == "func" and depth == 0:
            function_name = random.choice(["func1", "func2", "func3"])
            num_params = random.randint(1, 3)
            params = ", ".join(random.choice(["a:int", "b:int", "c:int"]) for _ in range(num_params))
            r = random.choice(["a", "b", "c"])
            code += f"function {function_name}({params}) : int\n    {generate_random_turing_code(9)}\n    result {r}\nend {function_name}\n"
        elif construct == "opt":
            if declared_variables:
                variable_name = random.choice(declared_variables)
                operand = random.choice([random.randint(0, 100)] + declared_variables)
                code += f"{variable_name} := {variable_name} {random.choice(turing_arithmetic_operations)} {operand}\n"
        elif construct == "logic":
            if declared_variables:
                variable_name = random.choice(declared_variables)
                operand = random.choice([random.randint(0, 100)] + declared_variables)
                # rand choice of logical operation
                code += f"{variable_name} := {variable_name} {random.choice(turing_logical_operations)} {operand}\n"


    return code

# Generate and print a random Turing code snippet
random_turing_code = generate_random_turing_code(0)
print(random_turing_code)
