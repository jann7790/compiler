%{
#include <stdarg.h>
#include <stdio.h>

#define Trace(t)        printf("----------------------[trace]%s", t)
// #define Trace(t)        printf("")
#define DEBUG 0 // change this to 1 to enable debug()
// #define YY_parse_DEBUG 1
int yydebug = 1;
FILE *fp;
int scopeDepth[50];
int currentScope = 0;
int regStack[100];
int regStackTop = 0;
int usingReg= 0;

int labelCount = 0;


int conditionLabel[200];
int conditionLabelTop = 0;
int usedCondition = 0;

int loopLabel[200];
int loopLabelTop = 0;
int usedLoop = 0;

char* mainbuf;
int isMain = 1;
char mainBuffer[5000];

void initRegStack()
{
    for(int i = 0; i < 100; i++)
    {
        regStack[i] = 0;
    }
}




void MyPrintf(const char *format, ...)
{
    va_list args;
    char buffer[1000];

    va_start(args, format);
    vsnprintf(buffer, sizeof buffer, format, args);
    if(isMain)
        strcat(mainBuffer, buffer);
    else
        fprintf(fp, "%s", buffer);
    va_end(args);
}

void saveToMain()
{
    MyPrintf(" return\n");
    MyPrintf(" }\n");
    fprintf(fp, "%s", mainBuffer);
}

//PATH=$PATH:/home/user/javaa


void bp() {
    printf("bp: %d\n", __LINE__);
}
void parser_debug(const char *msg) {
    if (DEBUG) {
        printf("-------[DEBUG]: %s\n", msg);
    }
}



FILE* init_java_file(char* filename)
{
    FILE* fp = fopen(filename, "w");
    fprintf(fp,  "/*-------------------------------------------------*/\n");
    fprintf(fp,  "/* Java Assembly Code */\n");
    fprintf(fp, "class example\n");
    fprintf(fp, "{\n");

    // method public static void main(java.lang.String[])
    // max_stack 15
    // max_locals 15
    // {
    // return
    // }

    MyPrintf(" method public static void main(java.lang.String[])\n");
    MyPrintf(" max_stack 15\n");
    MyPrintf(" max_locals 15\n");
    MyPrintf(" {\n");

    return fp;
}


// begin
//     var aaaaaaaa :int
//     begin
//         var bbbbbbbb :int
//     end
//     begin
//         var cccccc :int
//         var dddddddd :int
//     end
//     var eeeeeee :int
// end


/*

1 aaaa, eeee
2 bbbbb, (cccccccc, ddddd)
3 
4
5

0 
1 
2
3
4
5
6


*/


void init_scopeDepth()
{
    for(int i = 0; i < 50; i++)
    {
        scopeDepth[i] = 0;
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

int subLoopEndCount=0;

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
    int returnType;
    int isDeclare;
    char idVal[256];
    int init;

}typedef unionData;

unionData* createUnionData()
{
    unionData* data = (unionData*)malloc(sizeof(unionData));
    data->type = 0;
    data->init = 0;
    data->returnType = 0;    
    data->isDeclare = 0;
    data->arrSize = 0;
    return data;

}

struct function{
    int scope;
    int returnType;
    int argType[100];
    int argCount;
    int id[100];
    char **argId;
}typedef function;

function funcTable[100];
int funcScopes[100];
int funcCount = 0;

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
    int reg;
    struct symbol *next;
}typedef symbol;

symbol *head = 0;

void load(unionData* data)
{

    
    char* id = data->idVal;
    symbol *temp = head;
    symbol *item = 0;
    while (temp != 0) {

        printf("**********************temp->id: %s, id: %s\n", temp->id, id);

        if (strcmp(temp->id, id) == 0 ) {
            int isArgs = 0;
            for(int i = 0; i < funcCount;i++)
            {
                for (int j = 0; j < funcTable[i].argCount; j++)
                {
                    if (strcmp(funcTable[i].argId[j], id) == 0 && funcScopes[i] == temp->scope)
                    {
                        isArgs = 1;
                        break;
                    }
                }
            }
            if (!isArgs)
                item = temp;
            else if (isArgs && temp->scope == currentScope * 100 + scopeDepth[currentScope])
                item = temp;
            printf("**********************this one temp->id: %s, id: %s\n", temp->id, id);
            
        }
        temp = temp->next;
    }    
    if(strcmp(id, "immediate_const") == 0)
    {
        item = (symbol*)malloc(sizeof(symbol));
        
        // item->scope = 1;
        // item->unionVal.data._const  = 0;
        
        item->symbolType = data->type;
        copyUnionData(&(item->unionVal.data), data);
        // copyUnion(&(item->unionVal), data);
        // something wrong here
        
    }
    else if(item == 0)
    {
        printf("error: %s is not defined\n", id);
        return;
    }
    switch (item->symbolType)
    {
    case _int:
        if(strcmp(id, "immediate_const") == 0 || item->unionVal.data._const)
            MyPrintf( "sipush %d\n", item->unionVal.data.intVal);
        else if(item->scope == 0)
            MyPrintf( "getstatic %s %s%s\n", "int", "example.", id);
        else
            MyPrintf( "iload %d\n", item->reg);

        break;
    case _bool:
        if(strcmp(id, "immediate_const") == 0 || item->unionVal.data._const)
            MyPrintf( "iconst_%d\n", item->unionVal.data.boolVal);
        else if(item->scope == 0)
            MyPrintf( "getstatic %s %s%s\n", "boolean", "example.", id);
        else
            MyPrintf( "iload %d\n", item->reg);
        break;
    case _real:
        if(strcmp(id, "immediate_const") == 0 || item->unionVal.data._const)
            MyPrintf( "sipush %f\n", item->unionVal.data.realVal);
        else if(item->scope == 0)
            MyPrintf( "getstatic %s %s%s\n", "float", "example.", id);
        else
            MyPrintf( "fload %d\n", item->reg);
        break;
    case _str:
        if(strcmp(id, "immediate_const") == 0 || item->unionVal.data._const)
            MyPrintf( "ldc \"%s\"\n", item->unionVal.data.strVal);
        else if(item->scope == 0)
            MyPrintf( "getstatic %s %s%s\n", "string", "example.", id);
        else
            MyPrintf( "aload %d\n", item->reg);
        break;

    }

}

void setReg(char* id, int reg)
{
    symbol *temp = head;
    while (temp != 0) {
        if (strcmp(temp->id, id) == 0) {
            temp->reg = reg;
        }
        temp = temp->next;
    }
}

void set(int type, char* id, unionData* unionPtr)
{
    
    // if (strcmp(unionPtr->idVal, "function_invocation") == 0)
    switch (type)
    {
        case _int :
            if (currentScope == 0)
                if (unionPtr->init!=-1)
                    fprintf(fp,  "field static %s %s = %d\n", "int", id, unionPtr->intVal);
                else
                    fprintf(fp,  "field static %s %s\n", "int", id);
            else
            {
                if(strcmp(unionPtr->idVal, "anonymous") != 0 && strcmp(unionPtr->idVal, "function_invocation") != 0)
                {
                    MyPrintf( "sipush %d\n", unionPtr->intVal);
                    // MyPrintf( "(set) sipush %d\n", unionPtr->intVal);
                }
                MyPrintf( "istore %d\n", usingReg++);
                regStack[regStackTop]++;
                setReg(id, usingReg-1);

            }
            break;
        case _bool :
            if (currentScope == 0)
                fprintf(fp, "field static %s %s = %d\n", "int", id, unionPtr->boolVal);
            else
            {
                if(strcmp(unionPtr->idVal, "anonymous") != 0 && strcmp(unionPtr->idVal, "function_invocation") != 0)
                {
                    // MyPrintf( "(set) iconst_%d\n", unionPtr->boolVal);
                    MyPrintf( "iconst_%d\n", unionPtr->boolVal);
                }
                MyPrintf( "istore %d\n", usingReg++);
                regStack[regStackTop]++;
                setReg(id, usingReg-1);

            }
            break;
        case _real :
            if (currentScope == 0)
                fprintf(fp, "field static %s %s = %f\n", "float", id, unionPtr->realVal);
            else
            {
                if(strcmp(unionPtr->idVal, "anonymous") != 0 && strcmp(unionPtr->idVal, "function_invocation") != 0)
                {
                    // MyPrintf( "(set) fconst_%f\n", unionPtr->realVal);
                    MyPrintf( "fconst_%f\n", unionPtr->realVal);
                }
                MyPrintf( "fstore %d\n", usingReg++);
                regStack[regStackTop]++;
                setReg(id, usingReg-1);

            }
            break;
        case _str :
            if (currentScope == 0)
                fprintf(fp, "field static %s %s = \"%s\"\n", "string", id, unionPtr->strVal);
            else
            {
                if(strcmp(unionPtr->idVal, "anonymous") != 0 && strcmp(unionPtr->idVal, "function_invocation") != 0)
                {
                    MyPrintf( "ldc \"%s\"\n", unionPtr->strVal);
                    // MyPrintf( "(set) ldc \"%s\"\n", unionPtr->strVal);
                }
                MyPrintf( "astore %d\n", usingReg++);
                regStack[regStackTop]++;
                setReg(id, usingReg-1);

            }
            break;

    }
    
    
}

void setArgsRegs(int type, char* id)
{
        usingReg++;
        regStack[regStackTop]++;
        setReg(id, usingReg-1);
}

ret_union* lookup(char *id) {
    symbol *temp = head;
    symbol *result = 0;
    while (temp != 0) {
        if (strcmp(temp->id, id) == 0) {
            // find last one in the same scope
            result = temp;
            strcpy(result->unionVal.data.idVal, id);
        }
        temp = temp->next;
    }
    if (result == 0) {
        return 0;
    }
    return &(result->unionVal);
}

int isExists(char* id, int scope)
{
    symbol *temp = head;
    while (temp != 0) {
        if (strcmp(temp->id, id) == 0 && temp->scope == scope) {
            return 1;
        }
        temp = temp->next;
    }
    return 0;
}

int lookUpScope(char *id)
{
    symbol *temp = head;
    symbol *result = 0;
    while (temp != 0) {
        if (strcmp(temp->id, id) == 0) {
            // find last one in the same scope
            result = temp;
        }
        temp = temp->next;
    }
    if (result == 0) {
        return 0;
    }
    return result->scope;
}

int lookUpReg(char* id)
{
    symbol *temp = head;
    symbol *result = 0;
    while (temp != 0) {
        if (strcmp(temp->id, id) == 0) {
            // find last one in the same scope
            result = temp;
        }
        temp = temp->next;
    }
    if (result == 0) {
        return 0;
    }
    return result->reg;
}

void copyUnionData(unionData *lhs, unionData *rhs) {
    if (lhs == 0 || rhs == 0) {
        return;
    }
    
    lhs->_const = rhs->_const;
    lhs->type = rhs->type;
    strcpy(lhs->strVal, rhs->strVal);
    lhs->intVal = rhs->intVal;
    lhs->boolVal = rhs->boolVal;
    lhs->realVal = rhs->realVal;
    lhs->arrSize = rhs->arrSize;
    lhs->returnType = rhs->returnType;
    strcpy(lhs->idVal, rhs->idVal);
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
    lhs->data.returnType = rhs->data.returnType;


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
    new_entry->scope = currentScope * 100 + scopeDepth[currentScope];
    
    
    return 1;
}



// dump
void dump_symbol() {
    symbol *temp = head;
    printf("\n\n\n\ndumping symbol table\n");
    while (temp != 0) {
        if(temp->symbolType != -1)
        {
            
            printf("id: [%s], scope: [%d], reg: [%d]\n", temp->id, temp->scope, temp->reg);
            printUnion(&(temp->unionVal));
        }
        temp = temp->next;
    }
}



int* getArgs(int scope, char* id){
    symbol *temp = head;
    int* args = (int*)malloc(sizeof(int) * 100);
    int i = 0;
    while (temp != 0) {
        if(temp->symbolType != -1)
        {
            
            if (strcmp(temp->id, id) != 0 && temp->scope == scope) {
                args[i] = temp->unionVal.data.intVal;
                i++;
            }
            
        }
        temp = temp->next;
    }
    args[i] = -1;
    return args;
}

void endClean()
{
    symbol *temp = head;
    

    printf("\n\n\n\ndumping symbol table\n");
    symbol *previous = 0;
    while (temp != 0) {
        if (temp->scope == currentScope * 100 + scopeDepth[currentScope])
        {
            if(!previous)
            {
                head = temp->next;
                free(temp);
                temp = head;
                continue;
            }
            previous->next = temp->next;
            free(temp);
            temp = previous;
        }
        previous = temp;
        temp = previous->next;
    }
}

void printUnion(ret_union *ret) {
    printf("+++++++++++++++++++++++++++++++++++++++++\n");
    switch(ret->data.type) {
        case _function:
            printf("type %s\n", "function");
            printf("return type: %d\n", ret->data.returnType);
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
        int _const;
        int type;
        char strVal[256];
        int intVal;
        int boolVal;
        float realVal;
        union _array{
            int* intArray;
            float* realArray;
        }array;
        int arrSize;
        int returnType;
        int isDeclare;
        char idVal[256];
        int init;
    }data;

    int type;
    char idVal[256];
    int intVal;
    int boolVal;
    float realVal;
    char strVal[256];
};




%type<data> expression arithmetic_expression variable_value bool_expression function_invocation
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
    Trace("Reducing to procedure_invco\n");

    int idx = 0;
    char* argString = (char*)malloc(sizeof(char) * 100);
    char* returnTypeString = (char*)malloc(20 * sizeof(char));

    for(int i = 0; i < funcCount; i++)
    {
        if(strcmp($1, funcTable[i].id) == 0)
        {
            idx = i;
            break;
        }
    }


    for(int i = 0; i < funcTable[idx].argCount; i++)
    {
        switch(funcTable[idx].argType[i])
        {
            case _int:
                strcat(argString, "int");
                break;
            case _real:
                strcat(argString, "real");
                break;
            case _str:
                strcat(argString, "string");
                break;
            case _bool:
                strcat(argString, "bool");
                break;
        }
        if(i != funcTable[idx].argCount - 1)
        {
            strcat(argString, ",");
        }
    }

    MyPrintf( "   invokestatic %s %s(%s)\n", "void", $1, argString);
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
LOOP
{
    currentScope++;
    regStackTop++;

    loopLabelTop++;
    usedLoop++;
    
    loopLabel[loopLabelTop] = usedLoop;
    MyPrintf( "Lbegin%d:\n", currentScope * 100 + scopeDepth[currentScope]);
}
function_contents END LOOP
{
    endClean();
    MyPrintf( "goto Lbegin%d\n", currentScope * 100 + scopeDepth[currentScope]);
    MyPrintf( "Lexit%d:\n", currentScope * 100 + scopeDepth[currentScope]);
    MyPrintf( "	nop\n");
    scopeDepth[currentScope]++;
    currentScope--;
	usingReg -= regStack[regStackTop];
	regStack[regStackTop--] = 0;

    loopLabelTop--;
}
|
FOR 
{
    currentScope++;
    regStackTop++;

    loopLabelTop++;
    usedLoop++;
    
    loopLabel[loopLabelTop] = usedLoop;

}
IDENTIFIER COLON integer_id DOT DOT integer_id 
{

    if ($5 > $8)
    {
        yyerror("Invalid for loop");
    }
    char* id = $3;
    
    unionData* unionPtr = createUnionData();;
    unionPtr->intVal = $5;
    unionPtr->type = _int;
    // exit when $7

    insert_symbol(id, unionPtr);
    set(_int, id, unionPtr);

    MyPrintf( "Lbegin%d:\n", currentScope * 100 + scopeDepth[currentScope]);
    

    int reg = lookUpReg($3);

    MyPrintf( "iload %d\n", reg);
    MyPrintf( "sipush %d\n", $8);
    MyPrintf( "isub\n");
    MyPrintf( "ifgt Ltrue%d\n", labelCount);
    MyPrintf( "   iconst_0\n");
    MyPrintf( "   goto Lfalse%d\n", labelCount);
    MyPrintf( "Ltrue%d:\n", labelCount);
    MyPrintf( "   iconst_1\n");
    MyPrintf( "Lfalse%d:\n", labelCount);
    MyPrintf( "ifne Lexit%d\n", currentScope * 100 + scopeDepth[currentScope]);
    labelCount+=1;

}
function_contents END FOR
{
    char* id = $3;
    int reg = lookUpReg($3);
    if (lookUpScope(id) != currentScope * 100 + scopeDepth[currentScope])
    {
        yyerror("Variable not declared in this scope");
        exit(1);
    }

    
    MyPrintf( "iload %d\n", reg);
    MyPrintf( "sipush 1\n");
    MyPrintf( "iadd\n");
    MyPrintf( "istore %d\n", reg);


  
    



    MyPrintf( "goto Lbegin%d\n", currentScope * 100 + scopeDepth[currentScope]);
    MyPrintf( "Lexit%d:\n", currentScope * 100 + scopeDepth[currentScope]);
    MyPrintf( "	nop\n");

    endClean();
    scopeDepth[currentScope]++;
    currentScope--;
	usingReg -= regStack[regStackTop];
	regStack[regStackTop--] = 0;

    loopLabelTop--;

}

|
FOR 
{
    currentScope++;
    regStackTop++;

    loopLabelTop++;
    usedLoop++;
    
    loopLabel[loopLabelTop] = usedLoop;
}
DECREASING IDENTIFIER COLON integer_id DOT DOT integer_id 
{

    if ($6 < $9)
    {
        yyerror("Invalid for loop");
    }
    char* id = $4;
    
    unionData* unionPtr = createUnionData();
    unionPtr->intVal = $6;
    unionPtr->type = _int;
    // exit when $7

    insert_symbol(id, unionPtr);
    set(_int, id, unionPtr);
    
    MyPrintf( "Lbegin%d:\n", currentScope * 100 + scopeDepth[currentScope]);

    int reg = lookUpReg($4);

    MyPrintf( "iload %d\n", reg);
    MyPrintf( "sipush %d\n", $9);
    MyPrintf( "isub\n");
    MyPrintf( "iflt Ltrue%d\n", labelCount);
    MyPrintf( "   iconst_0\n");
    MyPrintf( "   goto Lfalse%d\n", labelCount);
    MyPrintf( "Ltrue%d:\n", labelCount);
    MyPrintf( "   iconst_1\n");
    MyPrintf( "Lfalse%d:\n", labelCount);
    MyPrintf( "ifne Lexit%d\n", currentScope * 100 + scopeDepth[currentScope]);
    labelCount+=1;
}
function_contents END FOR
{




    char* id = $4;
    int reg = lookUpReg($4);
    if (lookUpScope(id) != currentScope * 100 + scopeDepth[currentScope])
    {
        yyerror("Variable not declared in this scope");
        exit(1);
    }

    
    MyPrintf( "iload %d\n", reg);
    MyPrintf( "sipush 1\n");
    MyPrintf( "isub\n");
    MyPrintf( "istore %d\n", reg);


  
    



    MyPrintf( "goto Lbegin%d\n", currentScope * 100 + scopeDepth[currentScope]);
    MyPrintf( "Lexit%d:\n", currentScope * 100 + scopeDepth[currentScope]);
    MyPrintf( "	nop\n");
    endClean();
    scopeDepth[currentScope]++;
    currentScope--;
	usingReg -= regStack[regStackTop];
	regStack[regStackTop--] = 0;

    loopLabelTop--;


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
    
    unionData* unionPtr = (unionData*)&$1;
    unionPtr->_const = 0;
 
    load(unionPtr);
    Trace("Reducing to args\n");
    
}
|args COMMA expression
{
    
    unionData* unionPtr = (unionData*)&$3;
    unionPtr->_const = 0;
 
    load(unionPtr);
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
bg
{
    currentScope++;regStackTop++;
    Trace("Reducing to blocks\n");
}
function_contents END
{
    endClean();
    scopeDepth[currentScope]++;
    currentScope--;
	usingReg -= regStack[regStackTop];
	regStack[regStackTop--] = 0;

}




simple:
SKIP
{
    MyPrintf( "getstatic java.io.PrintStream java.lang.System.out\ninvokevirtual void java.io.PrintStream.println()\n");
    Trace("Reducing to simple\n");
};
|IDENTIFIER  ASSIGN expression
{


    ret_union* data = lookup($1);

    Trace("id = expression\n");
    if(!data)
    {
        strcat($1, " is not declared\n");
        yyerror($1);
        exit(1);
    }
    else if(data->data._const)
    {
        yyerror("Error: cannot assign to a constant\n");
        exit(1);
    }

    unionData* unionPtr = (unionData*)&$3;
    
    
 
    load(unionPtr);
    if (lookUpScope($1) == 0)
    {
        switch (data->data.type)
        {
            case _int:
                MyPrintf( "   putstatic %s example.%s \n", "int", $1);
                data->data.intVal = unionPtr->intVal;
                break;
            case _real:
                MyPrintf( "   putstatic %s example.%s \n", "float", $1);
                data->data.realVal = unionPtr->realVal;
                break;
            case _bool:
                MyPrintf( "   putstatic %s example.%s \n", "boolean", $1);
                data->data.boolVal = unionPtr->boolVal;
                break;
            case _str:
                MyPrintf( "   putstatic %s example.%s \n", "String", $1);
                strcpy(data->data.strVal, unionPtr->strVal);
                break;
        }
    }
    else
    {
        switch (data->data.type)
        {
            case _int:
                MyPrintf( "   istore %d\n", lookUpReg($1));
                data->data.intVal = unionPtr->intVal;
                break;
            case _real:
                break;
        }        

    }
    // copyUnion(data, (ret_union*)&$3);
    Trace("Reducing to simple\n");

};
|array_reference ASSIGN expression
{

    Trace("Reducing to simple\n");
};
|GET IDENTIFIER
{
    
    Trace("Reducing to simple\n");
};
|PUT 
{
    MyPrintf( "getstatic java.io.PrintStream java.lang.System.out\n");
    Trace("Reducing to ouyttttttttttttput simpel\n");
}
expression
{
    


    unionData* unionPtr = (unionData*)&$3;
    // strcpy(unionPtr->idVal, "immediate_const");
    
    load(unionPtr);
    switch(unionPtr->type)
    {
        case _int:
            MyPrintf( "invokevirtual void java.io.PrintStream.print(int)\n");
            break;
        case _str:
            MyPrintf( "invokevirtual void java.io.PrintStream.print(java.lang.String)\n");
            break;
        case _real:
            MyPrintf( "invokevirtual void java.io.PrintStream.print(float)\n");
            break;
        case _bool:
            MyPrintf( "invokevirtual void java.io.PrintStream.print(boolean)\n");
            break;
    }
    
};
|RESULT expression
{
    unionData* unionPtr = (unionData*)&$2;
    load(unionPtr);
    MyPrintf( "   ireturn\n");
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
    MyPrintf( "ifne Lexit%d\n", currentScope * 100 + scopeDepth[currentScope]);

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
IF 
{

    currentScope++;
    regStackTop++;
    conditionLabelTop++;
    usedCondition++;
    
}
LPAREN expression RPAREN
{
    // if anonymous a + b, a = b, ...., this means that the expression is already evaluated

    load((unionData*)&$4);
    
    if($4.type != _bool)
    {
        yyerror("Error: condition should be a boolean\n");
    }

    conditionLabel[conditionLabelTop] = usedCondition;
    MyPrintf( "ifeq Lfalse%d\n", currentScope * 100 + scopeDepth[currentScope]);



}
THEN function_contents
{
    MyPrintf( "goto Lexit%d\n", currentScope * 100 + scopeDepth[currentScope]);
    

}
else_part
{}
END IF
{
    endClean();
    scopeDepth[currentScope]++;
    currentScope--;
	usingReg -= regStack[regStackTop];
	regStack[regStackTop--] = 0;


    conditionLabelTop--;
  
};

else_part:
ELSE 
{

 // for else scope
   
    MyPrintf( "Lfalse%d:\n", currentScope * 100 + scopeDepth[currentScope]);
    MyPrintf( "	nop\n");
    currentScope++;regStackTop++;

}
function_contents 
{
    currentScope--;
    MyPrintf( "Lexit%d:\n", currentScope * 100 + scopeDepth[currentScope]);
    currentScope++;
    MyPrintf( "	nop\n");

endClean();
    scopeDepth[currentScope]++;
    currentScope--;
	usingReg -= regStack[regStackTop];
	regStack[regStackTop--] = 0;
};
|empty
{
    MyPrintf( "Lfalse%d:\n", currentScope * 100 + scopeDepth[currentScope]);
    MyPrintf( "	nop\n");
    MyPrintf( "Lexit%d:\n", currentScope * 100 + scopeDepth[currentScope]);
    MyPrintf( "	nop\n");

}


expression:
arithmetic_expression
{
    // print $1
    Trace("Reducing to expression\n");

    copyUnionData((unionData*)&$$, (unionData*)&$1);
    


    
}

|function_invocation
{
    Trace("Reducing to expression\n");
    copyUnionData((unionData*)&$$, (unionData*)&$1);
    
}
|array_reference
{
    Trace("Reducing to expression\n");
    
};
|bool_expression
{
    Trace("Reducing to expression\n");
    copyUnionData((unionData*)&$$, (unionData*)&$1);
    
};
/* 註解此處 進入 bool_expression */
/* |variable_value
{
        unionData* unionPtr = (unionData*)&$1;
    

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
    
} */
//added
/* |IDENTIFIER
{
    Trace("Reducing to arithmetic_expression\n");    
    ret_union* ret = lookup($1);
    
    if (!ret)
    {
        printf("[Error]: %s not declared\n", $1);
        exit(1);
    }
    if (ret->data.type == _int)
    {
        $$.intVal = ret->data.intVal;
        $$.type = _int;
    }
    else if (ret->data.type == _real)
    {
        $$.realVal = ret->data.realVal;
        $$.type = _real;
    }
    else if (ret->data.type == _str)
    {
        strcpy($$.strVal,ret->data.strVal);
        $$.type = _str;
    }
    else if (ret->data.type == _bool)
    {
        $$.boolVal = ret->data.boolVal;
        $$.type = _bool;
    }

    strcpy($$.idVal, $1);
    strcpy(ret->data.idVal, $1);

    load(&(ret->data));

};
 */



variable_value:
STRING_VALUE
{


    
    strcpy($$.strVal, $1);
    $$.type = _str;
    $$._const = 1;
    strcpy($$.idVal, "immediate_const" );


};
|TRUE_VALUE
{
    $$.boolVal = 1;
    $$.type = _bool;
    $$._const = 1;
    strcpy($$.idVal, "immediate_const" );
};
|FALSE_VALUE
{
    $$.boolVal = 0;
    $$.type = _bool;
    $$._const = 1;
    strcpy($$.idVal, "immediate_const" );
};
|INTEGER_VALUE
{
    $$.intVal = $1;
    $$.type = _int;
    $$._const = 1;

    strcpy($$.idVal, "immediate_const" );

}
|REAL_VALUE
{
    $$.realVal = $1;
    $$.type = _real;
    strcpy($$.idVal, "immediate_const" );
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

    int idx = 0;
    char* argString = (char*)malloc(sizeof(char) * 100);
    char* returnTypeString = (char*)malloc(20 * sizeof(char));

    $$.type = funcTable[idx].returnType;
    strcpy($$.idVal, "function_invocation");
    for(int i = 0; i < funcCount; i++)
    {
        if(strcmp($1, funcTable[i].id) == 0)
        {
            idx = i;
            break;
        }
    }

    switch(funcTable[idx].returnType)
        {
            case _int:
                strcpy(returnTypeString, "int");
                break;
            case _real:
                strcpy(returnTypeString, "real");
                break;
            case _str:
                strcpy(returnTypeString, "string");
                break;

            case _bool:
                strcpy(returnTypeString, "bool");
                break;
    }

    for(int i = 0; i < funcTable[idx].argCount; i++)
    {
        switch(funcTable[idx].argType[i])
        {
            case _int:
                strcat(argString, "int");
                break;
            case _real:
                strcat(argString, "real");
                break;
            case _str:
                strcat(argString, "string");
                break;
            case _bool:
                strcat(argString, "bool");
                break;
        }
        if(i != funcTable[idx].argCount - 1)
        {
            strcat(argString, ",");
        }
    }

    MyPrintf( "   invokestatic %s %s(%s)\n", returnTypeString, $1, argString);
}

bool_expression:
/* variable_value
{
    $$.type = _bool;
    Trace("Reducing to bool_expression\n");

};
| */
LPAREN expression RPAREN
{
    unionData* unionPtr = (unionData*)&$2;
    load(unionPtr);
    strcpy($$.idVal,"anonymous");  

    copyUnionData((unionData*)&$$, (unionData*)&$2);
    $$.type = _bool;

};
|expression EQUAL expression
{
    $$.type = _bool;
    strcpy($$.idVal,"anonymous");  

    unionData* unionPtr = (unionData*)&$1;
    load(unionPtr);
    unionPtr = (unionData*)&$3;
    load(unionPtr);
    MyPrintf( "   isub\n");
    MyPrintf( "   ifeq Ltrue%d\n", labelCount);
    MyPrintf( "   iconst_0\n");
    MyPrintf( "   goto Lfalse%d\n", labelCount);
    MyPrintf( "Ltrue%d:\n", labelCount);
    MyPrintf( "   iconst_1\n");
    MyPrintf( "Lfalse%d:\n", labelCount);
    MyPrintf( "	nop\n");
    labelCount ++;
    


    if ($1.type == _int && $3.type == _int)
    {
        $$.boolVal = $1.intVal == $3.intVal;
    }
    else if ($1.type == _int && $3.type == _real)
    {
        $$.boolVal = $1.intVal == $3.realVal;
    }
    else if ($1.type == _real && $3.type == _int)
    {
        $$.boolVal = $1.realVal == $3.intVal;
    }
    else if ($1.type == _real && $3.type == _real)
    {
        $$.boolVal = $1.realVal == $3.realVal;
    }
        else if ($1.type == _bool && $3.type == _bool)
    {
        $$.boolVal = $1.boolVal == $3.boolVal;
    }
};
|expression NOT_EQUAL expression
{
    $$.type = _bool;
    strcpy($$.idVal,"anonymous");  

    unionData* unionPtr = (unionData*)&$1;
    load(unionPtr);
    unionPtr = (unionData*)&$3;
    load(unionPtr);
    MyPrintf( "   isub\n");
    MyPrintf( "   ifne Ltrue%d\n", labelCount);
    MyPrintf( "   iconst_0\n");
    MyPrintf( "   goto Lfalse%d\n", labelCount);
    MyPrintf( "Ltrue%d:\n", labelCount);
    MyPrintf( "   iconst_1\n");
    MyPrintf( "Lfalse%d:\n", labelCount);
    MyPrintf( "	nop\n");
    labelCount ++;

    if ($1.type == _int && $3.type == _int)
    {
        $$.boolVal = $1.intVal != $3.intVal;
    }
    else if ($1.type == _int && $3.type == _real)
    {
        $$.boolVal = $1.intVal != $3.realVal;
    }
    else if ($1.type == _real && $3.type == _int)
    {
        $$.boolVal = $1.realVal != $3.intVal;
    }
    else if ($1.type == _real && $3.type == _real)
    {
        $$.boolVal = $1.realVal != $3.realVal;
    }
    else if ($1.type == _bool && $3.type == _bool)
    {
        $$.boolVal = $1.boolVal && $3.boolVal;
    }
};
|expression GREATER expression
{
    $$.type = _bool;
    strcpy($$.idVal,"anonymous");  
    unionData* unionPtr = (unionData*)&$1;
    load(unionPtr);
    unionPtr = (unionData*)&$3;
    load(unionPtr);
    MyPrintf( "   isub\n");
    MyPrintf( "   ifgt Ltrue%d\n", labelCount);
    MyPrintf( "   iconst_0\n");
    MyPrintf( "   goto Lfalse%d\n", labelCount);
    MyPrintf( "Ltrue%d:\n", labelCount);
    MyPrintf( "   iconst_1\n");
    MyPrintf( "Lfalse%d:\n", labelCount);
    MyPrintf( "	nop\n");
    labelCount ++;

    
    if ($1.type == _int && $3.type == _int)
    {
        $$.boolVal = $1.intVal > $3.intVal;
    }
    else if ($1.type == _int && $3.type == _real)
    {
        $$.boolVal = $1.intVal > $3.realVal;
    }
    else if ($1.type == _real && $3.type == _int)
    {
        $$.boolVal = $1.realVal > $3.intVal;
    }
    else if ($1.type == _real && $3.type == _real)
    {
        $$.boolVal = $1.realVal > $3.realVal;
    }
    else if ($1.type == _bool && $3.type == _bool)
    {
        $$.boolVal = $1.boolVal && $3.boolVal;
    }
};
|expression LESS expression
{
    $$.type = _bool;
    unionData* unionPtr = (unionData*)&$1;
    load(unionPtr);
    unionPtr = (unionData*)&$3;
    load(unionPtr);
    MyPrintf( "   isub\n");
    MyPrintf( "   iflt Ltrue%d\n", labelCount);
    MyPrintf( "   iconst_0\n");
    MyPrintf( "   goto Lfalse%d\n", labelCount);
    MyPrintf( "Ltrue%d:\n", labelCount);
    MyPrintf( "   iconst_1\n");
    MyPrintf( "Lfalse%d:\n", labelCount);
    MyPrintf( "	nop\n");
    labelCount ++;
    strcpy($$.idVal,"anonymous");  
    
    if ($1.type == _int && $3.type == _int)
    {
        $$.boolVal = $1.intVal < $3.intVal;
    }
    else if ($1.type == _int && $3.type == _real)
    {
        $$.boolVal = $1.intVal < $3.realVal;
    }
    else if ($1.type == _real && $3.type == _int)
    {
        $$.boolVal = $1.realVal < $3.intVal;
    }
    else if ($1.type == _real && $3.type == _real)
    {
        $$.boolVal = $1.realVal < $3.realVal;
    }
        else if ($1.type == _bool && $3.type == _bool)
    {
        $$.boolVal = $1.boolVal && $3.boolVal;
    }


};
|expression GREATER_EQUAL expression
{
    $$.type = _bool;
    strcpy($$.idVal,"anonymous");  
    unionData* unionPtr = (unionData*)&$1;
    load(unionPtr);
    unionPtr = (unionData*)&$3;
    load(unionPtr);
    MyPrintf( "   isub\n");
    MyPrintf( "   ifge Ltrue%d\n", labelCount);
    MyPrintf( "   iconst_0\n");
    MyPrintf( "   goto Lfalse%d\n", labelCount);
    MyPrintf( "Ltrue%d:\n", labelCount);
    MyPrintf( "   iconst_1\n");
    MyPrintf( "Lfalse%d:\n", labelCount);
    MyPrintf( "	nop\n");
    labelCount ++;

    if ($1.type == _int && $3.type == _int)
    {
        $$.boolVal = $1.intVal >= $3.intVal;
    }
    else if ($1.type == _int && $3.type == _real)
    {
        $$.boolVal = $1.intVal >= $3.realVal;
    }
    else if ($1.type == _real && $3.type == _int)
    {
        $$.boolVal = $1.realVal >= $3.intVal;
    }
    else if ($1.type == _real && $3.type == _real)
    {
        $$.boolVal = $1.realVal >= $3.realVal;
    }
        else if ($1.type == _bool && $3.type == _bool)
    {
        $$.boolVal = $1.boolVal && $3.boolVal;
    }
};
|expression LESS_EQUAL expression
{
    $$.type = _bool;
    strcpy($$.idVal,"anonymous");  
    unionData* unionPtr = (unionData*)&$1;
    load(unionPtr);
    unionPtr = (unionData*)&$3;
    load(unionPtr);
    MyPrintf( "   isub\n");
    MyPrintf( "   ifle Ltrue%d\n", labelCount);
    MyPrintf( "   iconst_0\n");
    MyPrintf( "   goto Lfalse%d\n", labelCount);
    MyPrintf( "Ltrue%d:\n", labelCount);
    MyPrintf( "   iconst_1\n");
    MyPrintf( "Lfalse%d:\n", labelCount);
    MyPrintf( "	nop\n");
    labelCount ++;

    if ($1.type == _int && $3.type == _int)
    {
        $$.boolVal = $1.intVal <= $3.intVal;
    }
    else if ($1.type == _int && $3.type == _real)
    {
        $$.boolVal = $1.intVal <= $3.realVal;
    }
    else if ($1.type == _real && $3.type == _int)
    {
        $$.boolVal = $1.realVal <= $3.intVal;
    }
    else if ($1.type == _real && $3.type == _real)
    {
        $$.boolVal = $1.realVal <= $3.realVal;
    }
        else if ($1.type == _bool && $3.type == _bool)
    {
        $$.boolVal = $1.boolVal <= $3.boolVal;
    }
};
|expression AND expression
{
    bp();
    strcpy($$.idVal,"anonymous");  
    unionData* unionPtr = (unionData*)&$1;
    load(unionPtr);
    unionPtr = (unionData*)&$3;
    load(unionPtr);
    MyPrintf( "   iand\n");



    bp();
    $$.type = _bool;
    if ($1.type == _bool && $3.type == _bool)
    {
        $$.boolVal = $1.boolVal && $3.boolVal;
    }
    else
    {
        printf("Error: AND operator can only be applied to bool types\n");
        exit(1);
    }

};
|expression OR expression
{
    $$.type = _bool;
    strcpy($$.idVal,"anonymous");  
    unionData* unionPtr = (unionData*)&$1;
    load(unionPtr);
    unionPtr = (unionData*)&$3;
    load(unionPtr);
    MyPrintf( "   ior\n");
 
    if ($1.type == _int && $3.type == _int)
    {
        $$.boolVal = $1.intVal || $3.intVal;
    }
    else if ($1.type == _int && $3.type == _real)
    {
        $$.boolVal = $1.intVal || $3.realVal;
    }
    else if ($1.type == _real && $3.type == _int)
    {
        $$.boolVal = $1.realVal || $3.intVal;
    }
    else if ($1.type == _real && $3.type == _real)
    {
        $$.boolVal = $1.realVal || $3.realVal;
    }
    else if ($1.type == _bool || $3.type == _bool)
    {
        $$.boolVal = $1.boolVal || $3.boolVal;
    }
};
|expression NOT expression
{
    $$.type = _bool;
    strcpy($$.idVal,"anonymous");  
    unionData* unionPtr = (unionData*)&$1;
    load(unionPtr);
    unionPtr = (unionData*)&$3;
    load(unionPtr);
    MyPrintf( "   ixor\n");
    
    
    if ($1.type == _int && $3.type == _int)
    {
        $$.boolVal = $1.intVal != $3.intVal;
    }
    else if ($1.type == _int && $3.type == _real)
    {
        $$.boolVal = $1.intVal != $3.realVal;
    }
    else if ($1.type == _real && $3.type == _int)
    {
        $$.boolVal = $1.realVal != $3.intVal;
    }
    else if ($1.type == _real && $3.type == _real)
    {
        $$.boolVal = $1.realVal != $3.realVal;
    }
    else if ($1.type == _bool && $3.type == _bool)
    {
        $$.boolVal = $1.boolVal != $3.boolVal;
    }
};
|arithmetic_expression
{
    $$.type = _bool;
    strcpy($$.idVal,"anonymous");  

    Trace("Reducing to bool_expression\n");

};





arithmetic_expression:
arithmetic_expression TIMES arithmetic_expression
{
    Trace("Reducing to a*b\n");    
    if (currentScope * 100 + scopeDepth[currentScope] != 0 || isMain)
    {
        unionData* unionPtr = (unionData*)&$1;
        load(unionPtr);
        unionPtr = (unionData*)&$3;
        load(unionPtr);

        MyPrintf( "   imul\n");

    }
    strcpy($$.idVal,"anonymous");  

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
    
    Trace("Reducing to a/b\n");   
    if (currentScope * 100 + scopeDepth[currentScope] != 0 || isMain)
    {
        unionData* unionPtr = (unionData*)&$1;
        load(unionPtr);
        unionPtr = (unionData*)&$3;
        load(unionPtr);

        MyPrintf( "   idiv\n");

    }
    strcpy($$.idVal,"anonymous");  
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

    Trace("Reducing to a-b\n");    
    if (currentScope * 100 + scopeDepth[currentScope] != 0 || isMain)
    {
        unionData* unionPtr = (unionData*)&$1;
        load(unionPtr);
        unionPtr = (unionData*)&$3;
        load(unionPtr);

        MyPrintf( "   isub\n");
    }
    strcpy($$.idVal,"anonymous"); 
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
    Trace("Reducing to a+b\n");    
    
    if (currentScope * 100 + scopeDepth[currentScope] != 0 || isMain)
    {
        unionData* unionPtr = (unionData*)&$1;
        load(unionPtr);
        unionPtr = (unionData*)&$3;
        load(unionPtr);

        MyPrintf( "   iadd\n");
    }

    strcpy($$.idVal,"anonymous"); 
    printf("%s 7777777777777\n", $$.idVal);
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

    if (currentScope * 100 + scopeDepth[currentScope] != 0 || isMain)
    {
        strcpy($$.idVal,"anonymous"); 
        unionData* unionPtr = (unionData*)&$1;
        load(unionPtr);
        unionPtr = (unionData*)&$3;
        load(unionPtr);

        MyPrintf( "   irem\n");
    }

    Trace("Reducing to a%b\n");    

    if ($1.type == _int && $3.type == _int)
    {
        $$.intVal = $1.intVal % $3.intVal;
        $$.type = _int;
    }

};
|IDENTIFIER
{
    Trace("Reducing to arithmetic_expression-----------id\n");    
    
    ret_union* ret = lookup($1);
    

    if (!ret)
    {
        printf("[Error]: %s not declared\n", $1);
        exit(1);
    }
    // if (ret->data.type == _int)
    // {
    //     $$.intVal = ret->data.intVal;
    //     $$.type = _int;
    // }
    // else if (ret->data.type == _real)
    // {
    //     $$.realVal = ret->data.realVal;
    //     $$.type = _real;
    // }
    // else if (ret->data.type == _str)
    // {
    //     strcpy($$.strVal,ret->data.strVal);
    //     $$.type = _str;
    // }
    // else if (ret->data.type == _bool)
    // {
    //     $$.boolVal = ret->data.boolVal;
    //     $$.type = _bool;
    // }

    // strcpy($$.idVal, $1);
    copyUnionData((unionData*)&$$, &(ret->data));





};
|variable_value
{
    // Trace("Reducing to arithmetic_expression\n");    
    
    unionData* unionPtr = (unionData*)&$1;
    

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
    else if ($1.type == _str)
    {
        strcpy($$.strVal,$1.strVal);
        $$.type = _str;
    }
    else if ($1.type == _bool)
    {
        $$.boolVal = $1.boolVal;
        $$.type = _bool;
    }


};
|LPAREN arithmetic_expression RPAREN
{
    copyUnionData((unionData*)&$$, (unionData*)&$2);


};
|MINUS arithmetic_expression %prec UMINUS
{

    if (currentScope * 100 + scopeDepth[currentScope] != 0 || isMain)
    {
        strcpy($$.idVal,"anonymous"); 
        unionData* unionPtr = (unionData*)&$2;
        load(unionPtr);

        MyPrintf( "   ineg\n");
    }

       
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
PROCEDURE 
{
    isMain = 0;
    Trace("Reducing to procedure start\n");

    currentScope++;regStackTop++;

    //at most 100 args
    funcTable[funcCount].argId = (char**)malloc(100 * sizeof(char *));
    funcTable[funcCount].argCount = 0;

}
IDENTIFIER LPAREN args_declaration RPAREN
{
    char* id = $3;
    unionData* unionPtr = createUnionData();
    unionPtr->_const = 0;
    unionPtr->type = _procedure;
    
    insert_symbol(id, unionPtr);

    funcScopes[funcCount] = currentScope * 100 + scopeDepth[currentScope];
    char* argString = (char*)malloc(100 * sizeof(char));

    strcpy(funcTable[funcCount].id, id);
    for(int i = 0; i < funcTable[funcCount].argCount; i++)
    {
        switch(funcTable[funcCount].argType[i])
        {
            case _int:
                strcat(argString, "int");
                break;
            case _real:
                strcat(argString, "real");
                break;
            case _str:
                strcat(argString, "string");
                break;
            case _bool:
                strcat(argString, "bool");
                break;
        }
        if(i != funcTable[funcCount].argCount - 1)
        {
            strcat(argString, ",");
        }
    }




    MyPrintf( "   method public static %s %s(%s)\n", "void", id, argString);
    MyPrintf( "   max_stack 15\n");
    MyPrintf( "   max_locals 15\n");
    MyPrintf( "   {\n");
    funcTable[funcCount].returnType = -1;


    

}
 function_contents  END IDENTIFIER
{
    funcCount++;
    endClean();
    scopeDepth[currentScope]++;
    currentScope--;
	usingReg -= regStack[regStackTop];
	regStack[regStackTop--] = 0;

    
    MyPrintf( "   return\n");
    MyPrintf( "   }\n");



    isMain = 1;
}


function_declaration:
FUNCTION
{
    isMain = 0;

    Trace("Reducing to function start\n");

    currentScope++;regStackTop++;

    //at most 100 args
    funcTable[funcCount].argId = (char**)malloc(100 * sizeof(char *));
    funcTable[funcCount].argCount = 0;


}
IDENTIFIER LPAREN args_declaration RPAREN COLON variable_type 
{
    char* id = $3;
    unionData* unionPtr = createUnionData();
    unionPtr->_const = 0;
    unionPtr->type = _function;
    
    funcScopes[funcCount] = currentScope * 100 + scopeDepth[currentScope];
    unionPtr->returnType = $8;
    printf("%d", $8);
    insert_symbol(id, unionPtr);


    strcpy(funcTable[funcCount].id, id);
    char* argString = (char*)malloc(100 * sizeof(char));
    char* returnTypeString = (char*)malloc(20 * sizeof(char));
    switch($8)
        {
            case _int:
                strcpy(returnTypeString, "int");
                break;
            case _real:
                strcpy(returnTypeString, "real");
                break;
            case _str:
                strcpy(returnTypeString, "string");
                break;

            case _bool:
                strcpy(returnTypeString, "bool");
                break;
    }
    for(int i = 0; i < funcTable[funcCount].argCount; i++)
    {
        switch(funcTable[funcCount].argType[i])
        {
            case _int:
                strcat(argString, "int");
                break;
            case _real:
                strcat(argString, "real");
                break;
            case _str:
                strcat(argString, "string");
                break;
            case _bool:
                strcat(argString, "bool");
                break;
        }
        if(i != funcTable[funcCount].argCount - 1)
        {
            strcat(argString, ",");
        }
    }




    MyPrintf( "   method public static %s %s(%s)\n", returnTypeString, id, argString);
    MyPrintf( "   max_stack 15\n");
    MyPrintf( "   max_locals 15\n");
    MyPrintf( "   {\n");
    funcTable[funcCount].returnType = $8;

}
function_contents END IDENTIFIER
{
    funcCount++;
    endClean();
    scopeDepth[currentScope]++;
    currentScope--;
	usingReg -= regStack[regStackTop];
	regStack[regStackTop--] = 0;

    

    MyPrintf( "   }\n");

    isMain = 1;
}





args_declaration:
|IDENTIFIER COLON variable_type
{
    
    char* id = $1;
    unionData* unionPtr = createUnionData();
    unionPtr->_const = 0;
    unionPtr->type = $3;
    insert_symbol(id, unionPtr);
    funcTable[funcCount].argId[0] = id;
    funcTable[funcCount].argType[0] = $3;

    funcTable[funcCount].argCount++;
    setArgsRegs($3, id);
}
|args_declaration more_args_declaration
{
};


more_args_declaration:
COMMA IDENTIFIER COLON variable_type
{
    char* id = $2;
    unionData* unionPtr = createUnionData();
    unionPtr->_const = 0;
    unionPtr->type = $4;
    insert_symbol(id, unionPtr);
    setArgsRegs($4, id);

    funcTable[funcCount].argId[funcTable[funcCount].argCount] = id;
    funcTable[funcCount].argType[funcTable[funcCount].argCount] = $4;
    funcTable[funcCount].argCount++;
    


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
        if (isExists(id, currentScope * 100 + scopeDepth[currentScope]))
    {
        strcat(id, " is already declared");
        yyerror(id);
        exit(1);
    }
    unionData* unionPtr = (unionData*)&$4;
    unionPtr->isDeclare = 1;
    unionPtr->_const = 1;
    
    insert_symbol(id, unionPtr);
    // set($4.type, id, unionPtr);
}
|CONST IDENTIFIER COLON variable_type ASSIGN expression
{
    char* id = $2;
    if (isExists(id, currentScope * 100 + scopeDepth[currentScope]))
    {
        strcat(id, " is already declared");
        yyerror(id);
        exit(1);
    }
    unionData* unionPtr = (unionData*)&$6;
    unionPtr->isDeclare = 1;
    unionPtr->_const = 1;
    if($4 != $6.type)
    {
        printf("---------------[Warning]: type mismatch\n");
    }
    unionPtr->type = $4;
    insert_symbol(id, unionPtr);
    // set($4, id, unionPtr);
}
|VAR IDENTIFIER COLON variable_type
{
    char* id = $2;
    if (isExists(id, currentScope * 100 + scopeDepth[currentScope]))
    {
        strcat(id, " is already declared");
        yyerror(id);
        exit(1);
    }
    
    unionData* unionPtr = createUnionData();
    unionPtr->_const = 0;
    unionPtr->type = $4;
    unionPtr->init = -1;
    unionPtr->isDeclare = 1;


    insert_symbol(id, unionPtr);
    set($4, id, unionPtr);
    
}
|VAR IDENTIFIER COLON variable_type ASSIGN expression
{
    char* id = $2;
    if (isExists(id, currentScope * 100 + scopeDepth[currentScope]))
    {
        strcat(id, " is already declared");
        yyerror(id);
        exit(1);
    }
    
    unionData* unionPtr = (unionData*)&$6;
    unionPtr->isDeclare = 1;
    unionPtr->_const = 0;
    if($4 != $6.type)
    {
        printf("type $4: %d, type $6: %d\n", $4, $6.type);
        printf("---------------[Warning]: type mismatch\n");
    }
    unionPtr->type = $4;
    insert_symbol(id, unionPtr);
    set($6.type, id, unionPtr);
}
|VAR IDENTIFIER ASSIGN expression
{
    char* id = $2;
    if (isExists(id, currentScope * 100 + scopeDepth[currentScope]))
    {
        strcat(id, " is already declared");
        yyerror(id);
        exit(1);
    }
    
    unionData* unionPtr = (unionData*)&$4;
    unionPtr->isDeclare = 1;
    unionPtr->_const = 0;
    
    insert_symbol(id, unionPtr);
    set($4.type, id, unionPtr);
    
}
/* declare array */
|VAR IDENTIFIER COLON ARRAY integer_id DOT DOT integer_id OF variable_type
{
    char* id = $2;
    if (isExists(id, currentScope * 100 + scopeDepth[currentScope]))
    {
        strcat(id, " is already declared");
        yyerror(id);
        exit(1);
    }
    
    unionData* unionPtr = createUnionData();
    unionPtr->_const = 0;
    unionPtr->isDeclare = 1;
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
        if (argc < 2)
        {
            printf("Usage: ./parser <filename>\n");
            exit(1);
        }
        fp = init_java_file(argv[1]);
        mainbuf = malloc(sizeof(char) * 10000);
        head = create_symbol_entry();
        /* open the source program file */
        yyparse();
        init_scopeDepth()  ;   
        dump_symbol();
        saveToMain();
        fprintf(fp,  "}\n");

        fclose(fp);
        initRegStack();
        
	    return 0 ;
        exit(0);

}



int yywrap(void)
{
    return 1;
}


