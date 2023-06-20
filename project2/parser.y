%{
// #define Trace(t)        printf("----------------------[trace]%s", t)
#define Trace(t)        printf("")
#define DEBUG 1 // change this to 1 to enable debug()
#define YY_parse_DEBUG 1
int yydebug = 1;

void bp() {
    printf("bp: %d\n", __LINE__);
}

void parser_debug(const char *msg) {
    if (DEBUG) {
        printf("-------[DEBUG]: %s\n", msg);
    }
}


enum type {
    _str,
    _int,
    _bool,
    _real,
    _char,
    _array,
    _function,
    _procedure,
    _int_array,
    _bool_array,
    _real_array
};

int currentScope = 0;
int subLoopEndCount=0;
int usedScopeCount = 0;
int subLoopStartCount = 0;
int union_type_temp_record = _int;

union Array{
    int* intArray;
    float* realArray;
}typedef Array;

struct unionData {
    int _const;
    int type;
    char strVal[256];
    int intVal;
    int boolVal;
    float realVal;
    Array array;
    int arrSize;
}typedef unionData;



typedef union {
    unionData data;
    int type;
    char idVal[256];
    int intVal;
    int boolVal;
    float realVal;
    char strVal[256];
}ret_union;


struct symbol {
    char id[256];
    enum type symbolType;
    ret_union unionVal;
    int scope;
    struct symbol *next;
}typedef symbol;

symbol *head = 0;


ret_union* lookup(char *id) {
    symbol *temp = head;
    while (temp != 0) {
        if (strcmp(temp->id, id) == 0) {
            return &(temp->unionVal);
        }
        temp = temp->next;
    }
    return 0;
}





void copyUnion(ret_union *lhs, ret_union *rhs) {
    if (lhs == 0 || rhs == 0) {
        return;
    }
    lhs->data._const = rhs->data._const;
    lhs->data.type = rhs->data.type;
    strcpy(lhs->data.strVal, rhs->data.strVal);
    lhs->data.intVal = rhs->data.intVal;
    lhs->data.boolVal = rhs->data.boolVal;
    lhs->data.realVal = rhs->data.realVal;
    lhs->data.arrSize = rhs->data.arrSize;

    if (rhs->data.type == _int_array|rhs->data.type == _bool_array)
    {
        lhs->data.array.intArray = (int*)malloc(sizeof(int) * rhs->data.arrSize);
        for(int i = 0; i < rhs->data.arrSize; i++)
        {
            lhs->data.array.intArray[i] = rhs->data.array.intArray[i];
        }
    }
    else if(rhs->data.type == _real_array)
    {
        lhs->data.array.realArray = (float*)malloc(sizeof(float) * rhs->data.arrSize);
        for(int i = 0; i < rhs->data.arrSize; i++)
        {
            lhs->data.array.realArray[i] = rhs->data.array.realArray[i];
        }
        
    }

}

symbol* create_symbol_entry() {
    
    symbol *new_entry = (symbol*)malloc(sizeof(symbol));
    new_entry->next = 0;
    new_entry->scope = 0;
    new_entry->symbolType = -1;

    return new_entry;
}






int insert_symbol(char *id, unionData *data) {
    symbol *temp = head;
    while (1) {
        if (strcmp(temp->id, id) == 0 && temp->scope == currentScope) {
            // already exists
            printf("variable repeat\n");
            yyerror("variable repeat");
            return 0;
        }
        if (temp->next == 0) {
            break;
        }
        temp = temp->next;
    }
    // not exists
    symbol *new_entry = (symbol*)malloc(sizeof(symbol));
    strcpy(new_entry->id, id);
    copyUnion(&(new_entry->unionVal), data);
    new_entry->symbolType = data->type;
    // print the union
    temp->next = new_entry;
    new_entry->next = 0;
    new_entry->scope = currentScope;
    return 1;
}



// dump
void dump_symbol() {
    symbol *temp = head;
    printf("\n\n\n\ndumping symbol table\n");
    while (temp != 0) {
        if(temp->symbolType != -1)
        {
            printf("id: [%s], scope: [%d]\n", temp->id, temp->scope);
            printUnion(&(temp->unionVal));
        }
        temp = temp->next;
    }
}




void printUnion(ret_union *ret) {
    printf("+++++++++++++++++++++++++++++++++++++++++\n");
    switch(ret->data.type) {
        case _function:
            printf("type %s\n", "function");
            break;
        case _procedure:
            printf("type %s\n", "_procedure");
            break;
        case _str:
            printf("type %s %s\n", ret->data._const?"const":"var", "string");
            printf("value: %s\n", ret->data.strVal);
            break;
        case _int:
            printf("type %s %s\n", ret->data._const?"const":"var", "int");
            printf("value: %d\n", ret->data.intVal);
            break;
        case _real:
            printf("type %s %s\n", ret->data._const?"const":"var", "real");
            printf("value: %f\n", ret->data.realVal);
            break;
        case _bool:
            printf("type %s %s\n", ret->data._const?"const":"var", "bool");
            printf("value: %d\n", ret->data.boolVal);
            break;
        case _int_array:
            printf("type %s %s\n", ret->data._const?"const":"var", "int array");
            printf("value: [");
            for(int i = 0; i < ret->data.arrSize; i++)
            {
                printf("%d ", ret->data.array.intArray[i]);
            }
            printf("]\n");
            break;
        case _real_array:
            printf("type %s %s\n", ret->data._const?"const":"var", "real array");
            printf("value: ");
            for(int i = 0; i < ret->data.arrSize; i++)
            {
                printf("%f ", ret->data.array.realArray[i]);
            }
            printf("\n");
            break;
        case _bool_array:
            printf("type %s %s\n", ret->data._const?"const":"var", "bool array");
            printf("value: ");
            for(int i = 0; i < ret->data.arrSize; i++)
            {
                printf("%d ", ret->data.array.intArray[i]);
            }
            printf("\n");
            break;

    }
    printf("+++++++++++++++++++++++++++++++++++++++++\n\n");

}


%}

/* tokens */
/* %start program  */


%union{
    struct _stuct {
        int _conts;
        int type;
        char strVal[256];
        int intVal;
        int boolVal;
        float realVal;
        int* arrayElements;
        int arrSize;
    }data;

    int type;
    char idVal[256];
    int intVal;
    int boolVal;
    float realVal;
    char strVal[256];
};

%type<data> expression arithmetic_expression variable_value bool_expression
%type<type> variable_type
%type<intVal> integer_id

%token<type> STRING BOOL CHAR FLOAT INT ARRAY REAL

%token<strVal>STRING_VALUE
%token<realVal>REAL_VALUE
%token<intVal>INTEGER_VALUE
%token<intVal>TRUE_VALUE
%token<intVal>FALSE_VALUE
%token<idVal>IDENTIFIER

/* %token DOT COMMA COLON SEMICOLON LPAREN RPAREN LBRACKET RBRACKET LBRACE RBRACE PLUS MINUS TIMES DIVIDE MOD ASSIGN LT LTE GTE GT EQ NEQ AND OR NOT
%token ARRAY BEGIN BOOL CHAR CONST DECREASING DEFAULT DO ELSE END EXIT FALSE FOR FUNCTION GET IF INT LOOP OF PUT PROCEDURE REAL RESULT RETURN SKIP STRING THEN TRUE VAR WHEN */

/* do not use begin as a token, program may crash */
/* %token BEGIN */

%start program
%token COLON COMMA DOT OF END IF THEN ELSE LOOP FOR DECREASING bg
%token LPAREN RPAREN LBRACKET RBRACKET LBRACE RBRACE

%token FUNCTION PROCEDURE
%token LESS GREATER
%token WHEN SKIP EXIT RESULT RETURN PUT GET AND OR NOT GREATER_EQUAL LESS_EQUAL EQUAL NOT_EQUAL ASSIGN
%token VAR CONST SEMICOLON 

%left PLUS MINUS
%left TIMES DIVIDE MOD
%nonassoc UMINUS

%%
program: multiple_subprogram
{
    Trace("Reducing to program\n");
}

multiple_subprogram:
subprogram
{}
|multiple_subprogram subprogram
{};

subprogram: 
multi_declaration
{
    Trace("Reducing to subprogram\n");
}
|expression
{
    Trace("Reducing to subprogram\n");
}
|multi_statements
{
    Trace("Reducing to subprogram\n");
}
|conditions
{
    Trace("Reducing to subprogram\n");
}
|loops
{
    Trace("Reducing to subprogram\n");
};
/* |procedure_invocations
{
    Trace("Reducing to subprogram\n");
}; */


procedure_invocations:
procedure_invocation
{
    Trace("Reducing to procedure_invocations\n");
}
|procedure_invocations procedure_invocation
{
    Trace("Reducing to procedure_invocations\n");
};

procedure_invocation:
IDENTIFIER LPAREN args RPAREN
{
    Trace("Reducing to procedure_invocation\n");
}


multi_declaration:
multi_declaration declaration
{
}
|declaration
{
};

declaration:
variable_declaration
{
    Trace("Reducing to variable declaration\n");
}
|function_declaration
{
    Trace("Reducing to function_declaration\n");
}
|procedure_declaration
{
    Trace("Reducing to procedure_declaration\n");
};


loops :
loops loop
{
}
|loop
{
}


loop:
loopStart loopEnd
{
    Trace("Reducing to loop\n");
}

loopStart:
LOOP
{
}
|FOR IDENTIFIER COLON integer_id DOT DOT integer_id 
{
}
|FOR DECREASING IDENTIFIER COLON integer_id DOT DOT integer_id 
{
};


loopEnd:
function_contents END LOOP
{
}
|function_contents END FOR
{
}


integer_id:
IDENTIFIER
{
    ret_union* data = lookup($1);
    if(!data)
    {
        printf("Error: %s is not declared\n", $1);
        exit(1);
    }
    $$ = data->data.intVal;
    Trace("Reducing to integer_id\n");
    
}
|INTEGER_VALUE
{
    Trace("Reducing to integer_id\n");
};


args:
expression
{
    Trace("Reducing to args\n");
    
}
|args COMMA expression
{
    Trace("Reducing to args\n");
    
};
|empty
{
    Trace("Reducing to args\n");
};




function_contents:
function_contents function_content
{
    Trace("Reducing to function_contents\n");
};
|function_content
{
    Trace("Reducing to function_contents\n");
};

function_content:
condition
{
    Trace("Reducing to function_contents\n");
};
|loop
{
    Trace("Reducing to function_contents\n");
};
|multi_declaration
{
    Trace("Reducing to function_contents\n");
};
|multi_statements
{
    Trace("Reducing to function_contents\n");

};
|empty
{
    Trace("Reducing to function_contents\n");

};


multi_statements:
statement
{
    Trace("Reducing to multi_statements\n");
};
|multi_statements statement
{
    Trace("Reducing to multi_statements\n");

};



statement:
blocks
{
    Trace("Reducing to statement\n");
}
|simple
{
    Trace("Reducing to statement\n");
    
}
|procedure_invocation
{
    Trace("Reducing to statement\n");
    
}

blocks:
blockStart blockEnd
{
    Trace("Reducing to blocks\n");
}

blockStart:
bg
{
    currentScope = currentScope + usedScopeCount + 1;
    if(subLoopStartCount != 0)
    {
        currentScope = currentScope - usedScopeCount;
    }
    subLoopStartCount++;
    usedScopeCount++;
}

blockEnd:
function_contents END
{
    currentScope--;
    subLoopEndCount++;
    if(subLoopStartCount == subLoopEndCount)
    {
        currentScope = currentScope - usedScopeCount + subLoopEndCount;
        subLoopEndCount = 0;
        subLoopStartCount = 0;
    }
}




simple:
SKIP
{
    Trace("Reducing to simple\n");
};
|IDENTIFIER ASSIGN expression
{

    ret_union* data = lookup($1);
    if(!data)
    {
        printf("Error: %s is not declared\n", $1);
        exit(1);
    }
    copyUnion(data, (ret_union*)&$3);
    Trace("Reducing to simple\n");
};
|array_reference ASSIGN expression
{

    Trace("Reducing to simple\n");
};
|GET IDENTIFIER
{
    bp();
    Trace("Reducing to simple\n");
};
|PUT expression
{
    Trace("Reducing to simple\n");
};
|RESULT expression
{
    Trace("Reducing to simple\n");
};
|RETURN
{
    Trace("Reducing to simple\n");

};
|EXIT
{
    Trace("Reducing to simple\n");

};
|EXIT WHEN bool_expression
{
    Trace("Reducing to simple\n");

};





conditions:
condition
{
};
|conditions condition
{
};


condition:
IF bool_expression THEN function_contents ELSE function_contents END IF
{
    
    Trace("Reducing to condition\n");
}
|IF bool_expression THEN function_contents END IF
{
    
    Trace("Reducing to condition\n");
}



expression:
arithmetic_expression
{
    // print $1
    Trace("Reducing to expression\n");
    copyUnion((ret_union*)&$$, (ret_union*)&$1);
    
}
|bool_expression
{
    Trace("Reducing to expression\n");
    
};
|function_invocation
{
    Trace("Reducing to expression\n");
    
}
|array_reference
{
    Trace("Reducing to expression\n");
    
};
|variable_value
{
    Trace("Reducing to expression\n");
    switch($1.type)
    {
        case _int:
        {
            $$.intVal = $1.intVal;
            $$.type = _int;
            break;
        }
        case _real:
        {
            $$.intVal = $1.realVal;
            $$.type = _real;
            break;
        }
        case _bool:
        {
            $$.intVal = $1.boolVal;
            $$.type = _bool;
            break;
        }
        case _str:
        {
            strcpy($$.strVal, $1.strVal);
            $$.type = _str;
            break;
        }
        default:
        {
            break;
        }
    }
    
};



variable_value:
STRING_VALUE
{
    char test[100];
    strcpy(test, $1);
    Trace("Reducing to variable_value\n");
    strcpy($$.strVal, $1);
    $$.type = _str;

};
|TRUE_VALUE
{
    Trace("Reducing to variable_value\n");
    $$.boolVal = 1;
    $$.type = _bool;
};
|FALSE_VALUE
{
    Trace("Reducing to variable_value\n");
    $$.boolVal = 0;
    $$.type = _bool;
};
|INTEGER_VALUE
{
    
    Trace("Reducing to variable_value\n");
    $$.intVal = $1;
    $$.type = _int;
}
|REAL_VALUE
{
    Trace("Reducing to variable_value\n");
    $$.realVal = $1;
    $$.type = _real;
};


array_reference:
IDENTIFIER LBRACKET INTEGER_VALUE RBRACKET
{
    Trace("Reducing to array_reference\n");
};





function_invocation:
IDENTIFIER LPAREN args RPAREN
{
    Trace("Reducing to function_invocation\n");
}

bool_expression:
IDENTIFIER
{
    $$.type = _bool;
    Trace("Reducing to bool_expression\n");
    
};
|variable_value
{
    $$.type = _bool;
    Trace("Reducing to bool_expression\n");

};
|LPAREN expression RPAREN
{
    $$.type = _bool;
    Trace("Reducing to bool_expression\n");

};
|expression EQUAL expression
{
    $$.type = _bool;
    Trace("Reducing to bool_expression\n");

};
|expression NOT_EQUAL expression
{
    $$.type = _bool;
    Trace("Reducing to bool_expression\n");

};
|expression GREATER expression
{
    $$.type = _bool;
    Trace("Reducing to bool_expression\n");

};
|expression LESS expression
{
    $$.type = _bool;
    Trace("Reducing to bool_expression\n");

};
|expression GREATER_EQUAL expression
{
    $$.type = _bool;
    Trace("Reducing to bool_expression\n");

};
|expression LESS_EQUAL expression
{
    $$.type = _bool;
    Trace("Reducing to bool_expression\n");

};
|expression AND expression
{
    $$.type = _bool;
    Trace("Reducing to bool_expression\n");

};
|expression OR expression
{
    $$.type = _bool;
    Trace("Reducing to bool_expression\n");

};
|expression NOT expression
{
    $$.type = _bool;
    Trace("Reducing to bool_expression\n");

};






arithmetic_expression:
arithmetic_expression TIMES arithmetic_expression
{
    Trace("Reducing to arithmetic_expression\n");    
    if ($1.type == _int && $3.type == _int)
    {
        $$.intVal = $1.intVal * $3.intVal;
        $$.type = _int;
    }
    else if ($1.type == _int && $3.type == _real)
    {
        $$.realVal = $1.intVal * $3.realVal;
        $$.type = _real;
    }
    else if ($1.type == _real && $3.type == _int)
    {
        $$.realVal = $1.realVal * $3.intVal;
        $$.type = _real;
    }
    else if ($1.type == _real && $3.type == _real)
    {
        $$.realVal = $1.realVal * $3.realVal;
        $$.type = _real;
    }

};
|arithmetic_expression DIVIDE arithmetic_expression
{
    
    Trace("Reducing to arithmetic_expression\n");    
    if ($1.type == _int && $3.type == _int)
    {
        $$.intVal = $1.intVal / $3.intVal;
        $$.type = _int;
    }
    else if ($1.type == _int && $3.type == _real)
    {
        $$.realVal = $1.intVal / $3.realVal;
        $$.type = _real;
    }
    else if ($1.type == _real && $3.type == _int)
    {
        $$.realVal = $1.realVal / $3.intVal;
        $$.type = _real;
    }
    else if ($1.type == _real && $3.type == _real)
    {
        $$.realVal = $1.realVal / $3.realVal;
        $$.type = _real;
    }

};
|arithmetic_expression MINUS arithmetic_expression
{
    

    Trace("Reducing to arithmetic_expression\n");    
    if ($1.type == _int && $3.type == _int)
    {
        $$.intVal = $1.intVal - $3.intVal;
        $$.type = _int;
    }
    else if ($1.type == _int && $3.type == _real)
    {
        $$.realVal = $1.intVal - $3.realVal;
        $$.type = _real;
    }
    else if ($1.type == _real && $3.type == _int)
    {
        $$.realVal = $1.realVal - $3.intVal;
        $$.type = _real;
    }
    else if ($1.type == _real && $3.type == _real)
    {
        $$.realVal = $1.realVal - $3.realVal;
        $$.type = _real;
    }

};
|arithmetic_expression PLUS arithmetic_expression
{
    Trace("Reducing to arithmetic_expression\n");    
    
    if ($1.type == _int && $3.type == _int)
    {
        $$.intVal = $1.intVal + $3.intVal;
        $$.type = _int;
    }
    else if ($1.type == _int && $3.type == _real)
    {
        $$.realVal = $1.intVal + $3.realVal;
        $$.type = _real;
    }
    else if ($1.type == _real && $3.type == _int)
    {
        $$.realVal = $1.realVal + $3.intVal;
        $$.type = _real;
    }
    else if ($1.type == _real && $3.type == _real)
    {
        $$.realVal = $1.realVal + $3.realVal;
        $$.type = _real;
    }

};
|arithmetic_expression MOD arithmetic_expression
{
    
    Trace("Reducing to arithmetic_expression\n");    
    if ($1.type == _int && $3.type == _int)
    {
        $$.intVal = $1.intVal % $3.intVal;
        $$.type = _int;
    }

};
|IDENTIFIER
{
    Trace("Reducing to arithmetic_expression\n");    
    ret_union* ret = lookup($1);
    if (!ret)
    {
        printf("[Error]: %s not declared\n", $1);
        exit(1);
    }
    if (ret->type == _int)
    {
        $$.intVal = ret->data.intVal;
        $$.type = _int;
    }
    else if (ret->type == _real)
    {
        $$.realVal = ret->data.realVal;
        $$.type = _real;
    }
    // todo: check symbol table for id
};
|variable_value
{
    // Trace("Reducing to arithmetic_expression\n");    
    if ($1.type == _int)
    {
        $$.intVal = $1.intVal;
        $$.type = _int;
    }
    else if ($1.type == _real)
    {
        $$.realVal = $1.realVal;
        $$.type = _real;
    }
};
|LPAREN arithmetic_expression RPAREN
{

    // Trace("Reducing to arithmetic_expression\n");    
    if ($2.type == _int)
    {
        $$.intVal = $2.intVal;
        $$.type = _int;
    }
    else if ($2.type == _real)
    {
        $$.realVal = $2.realVal;
        $$.type = _real;
    }
};
|MINUS arithmetic_expression %prec UMINUS
{
    
    // Trace("Reducing to arithmetic_expression\n");    
    if ($2.type == _int)
    {
        $$.intVal = -$2.intVal;
        $$.type = _int;
    }
    else if ($2.type == _real)
    {
        $$.realVal = -$2.realVal;
        $$.type = _real;
    }
};








procedure_declaration:
procedureStart procedureEND
{
        Trace("Reducing to procedure_declaration\n");
}

procedureStart:
PROCEDURE 
{
    Trace("Reducing to procedure start\n");

    currentScope = currentScope + usedScopeCount + 1;
    if(subLoopStartCount != 0)
    {
        currentScope = currentScope - usedScopeCount;
    }
    subLoopStartCount++;
    usedScopeCount++;


}



procedureEND:
IDENTIFIER LPAREN args_declaration RPAREN function_contents END IDENTIFIER
{
    char* id = $1;
    unionData* unionPtr = (unionData*)malloc(sizeof(unionData));
    unionPtr->_const = 0;
    unionPtr->type = _procedure;
    insert_symbol(id, unionPtr);

    currentScope--;
    subLoopEndCount++;
    if(subLoopStartCount == subLoopEndCount)
    {
        currentScope = currentScope - usedScopeCount + subLoopEndCount;
        subLoopEndCount = 0;
        subLoopStartCount = 0;
    }
    printf("currentScope: %d, usedScopeCount: %d, subLoopEndCount: %d, subLoopStartCount: %d\n", currentScope, usedScopeCount, subLoopEndCount, subLoopStartCount);
}







function_declaration:
functionStart functionEND
{
    Trace("Reducing to function_declaration\n");
}

functionStart:
FUNCTION 
{
    Trace("Reducing to function start\n");

    currentScope = currentScope + usedScopeCount + 1;
    if(subLoopStartCount != 0)
    {
        currentScope = currentScope - usedScopeCount;
    }
    subLoopStartCount++;
    usedScopeCount++;


}



functionEND:
IDENTIFIER LPAREN args_declaration RPAREN COLON variable_type function_contents END IDENTIFIER
{
    char* id = $1;
    unionData* unionPtr = (unionData*)malloc(sizeof(unionData));
    unionPtr->_const = 0;
    unionPtr->type = _function;
    insert_symbol(id, unionPtr);

    currentScope--;
    subLoopEndCount++;
    if(subLoopStartCount == subLoopEndCount)
    {
        currentScope = currentScope - usedScopeCount + subLoopEndCount;
        subLoopEndCount = 0;
        subLoopStartCount = 0;
    }
    printf("currentScope: %d, usedScopeCount: %d, subLoopEndCount: %d, subLoopStartCount: %d\n", currentScope, usedScopeCount, subLoopEndCount, subLoopStartCount);
}






args_declaration:
|IDENTIFIER COLON variable_type
{
    
    char* id = $1;
    unionData* unionPtr = (unionData*)malloc(sizeof(unionData));
    unionPtr->_const = 0;
    unionPtr->type = $3;
    insert_symbol(id, unionPtr);
}
|args_declaration more_args_declaration
{
};


more_args_declaration:
COMMA IDENTIFIER COLON variable_type
{
    char* id = $2;
    unionData* unionPtr = (unionData*)malloc(sizeof(unionData));
    unionPtr->_const = 0;
    unionPtr->type = $4;
    insert_symbol(id, unionPtr);
    // Trace("Reducing to more args declare\n");
}

empty:
{
};



variable_declaration: 
/* declare const */
CONST IDENTIFIER ASSIGN expression
{ 
    char* id = $2;
    unionData* unionPtr = (unionData*)&$4;
    unionPtr->_const = 1;
    insert_symbol(id, unionPtr);
}
|CONST IDENTIFIER COLON variable_type ASSIGN expression
{
    char* id = $2;
    unionData* unionPtr = (unionData*)&$6;
    unionPtr->_const = 1;
    if($4 != $6.type)
    {
        printf("---------------[Warning]: type mismatch\n");
    }
    unionPtr->type = $4;
    insert_symbol(id, unionPtr);
}
|VAR IDENTIFIER COLON variable_type
{
    char* id = $2;

    unionData* unionPtr = (unionData*)malloc(sizeof(unionData));
    unionPtr->_const = 0;
    unionPtr->type = $4;

    insert_symbol(id, unionPtr);
}
|VAR IDENTIFIER COLON variable_type ASSIGN expression
{
    char* id = $2;
    unionData* unionPtr = (unionData*)&$6;
    unionPtr->_const = 0;
    if($4 != $6.type)
    {
        printf("---------------[Warning]: type mismatch\n");
    }
    unionPtr->type = $4;
    insert_symbol(id, unionPtr);
}
|VAR IDENTIFIER ASSIGN expression
{
    char* id = $2;
    unionData* unionPtr = (unionData*)&$4;
    unionPtr->_const = 0;
    insert_symbol(id, unionPtr);
}
/* declare array */
|VAR IDENTIFIER COLON ARRAY integer_id DOT DOT integer_id OF variable_type
{
    char* id = $2;
    unionData* unionPtr = (unionData*)malloc(sizeof(unionData));
    unionPtr->_const = 0;
    unionPtr->arrSize = $8 - $5 + 2;
    // allocate memory for array
    switch ($10)
    {
    case _int:
        unionPtr->type = _int_array;
        unionPtr->array.intArray = (int*)malloc(sizeof(int) * unionPtr->arrSize);
        for (int i = 0; i <= $8 - $5 + 1; i++)
        {
            unionPtr->array.intArray[i] = 0;
        }
        break;
    case _real:
        unionPtr->type = _real_array;
        unionPtr->array.realArray = (float*)malloc(sizeof(float) * unionPtr->arrSize);
        for (int i = 0; i <= $8 - $5 + 1; i++)
        {
            unionPtr->array.realArray[i] = 0;
        }
        break;
    case _bool:
        unionPtr->type = _bool_array;
        unionPtr->array.intArray = (int*)malloc(sizeof(int) * unionPtr->arrSize);
        for (int i = 0; i <= $8 - $5 + 1; i++)
        {
            unionPtr->array.intArray[i] = 0;
        }
        break;
    }
    insert_symbol(id, unionPtr);
};



variable_type:
STRING
{
    $$ = _str;
};
|BOOL
{
    $$ = _bool;
};
|CHAR
{
    $$ = _char;
};
|REAL
{
    $$ = _real;
};
|INT
{
    $$ = _int;
};

%%



void yyerror(const char *msg)
{
    printf("!!!!!!!!!!!!!!!!!!!!!!!!![Error]: %s\n", msg);
}

int main(int argc, char *argv[])
{

        head = create_symbol_entry();
        /* open the source program file */
        yyparse();
        dump_symbol();
	    return 0 ;
        exit(0);

}



int yywrap(void)
{
    return 1;
}


