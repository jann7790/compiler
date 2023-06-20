%{
#include <stdio.h>
#include <locale.h>
#include "y.tab.h"

#define LIST     strcat(buf,yytext)
#define token(t) {LIST; printf("<%s>\n",t );}
#define keyword(t) { LIST; printf("<%s>\n",t);}
#define tokenInteger(t,i) {LIST; printf("<%s:%s>\n",t,i);}
#define tokenreal(t,i) {LIST; printf("<%s:%s>\n",t,i);}
#define tokenString(t,s) {LIST; printf("<%s:%s>\n",t,s);}

// #define token(t) {LIST; printf("<%s>\n",t );return t;}
// #define keyword(t) { LIST; printf("<%s>\n",t);return t;}
// #define tokenInteger(t,i) {LIST; printf("<%s:%s>\n",t,i);return t;}
// #define tokenreal(t,i) {LIST; printf("<%s:%s>\n",t,i);return t;}
// #define tokenString(t,s) {LIST; printf("<%s:%s>\n",t,s);return t;}

#define MAX_LINE_LENG 256
// #define DEBUG 0 // change this to 1 to enable debug()
#define DEBUG 1 // change this to 1 to enable debug()

int linenum = 1;
char buf[MAX_LINE_LENG];
char str[99999];
struct node {
        int index;
        char value[50];
        struct node *next;
}typedef node;

node* head;
node* tail;
int sybol_index = 0;

void debug(const char *msg) {
    if (DEBUG) {
        printf("DEBUG: %s\n", msg);
    }
}


node* create(){
        node* tmp = (node*)malloc(sizeof(node));
        tmp->next = NULL;
        return tmp;
}



int insert(char* str)
{
        node* tmp = head;
        while(tmp->next != NULL)
        {
                if(strcmp(tmp->value,str) == 0)
                {
                        return tmp->index;

                }

                tmp = tmp->next;
        }

        tmp->index = sybol_index++;
        strcpy(tmp->value,str);
        tmp->next = (node*)malloc(sizeof(node));
        tmp->next->index = -1;
        strcpy(tmp->next->value,"NULL");

        return sybol_index-1;
}

void dump()
{
        node* tmp = head;
        printf("\nSymbol Table:\n");
        while(tmp != NULL)
        {

                if(tmp->index >= 0)
                        printf("%d: %s\n",tmp->index,tmp->value);
                tmp = tmp->next;
        }

        return 0;
}
%}


whitespace [ \t]+
digit [0-9]
letter [a-zA-Z]
identifier {letter}({digit}|{letter})*
integer -?{digit}+
real -?{integer}(\.{integer})?
comment "%".*

%x STRING_STATE
%x COMMET_STATE

%%

"."     {token(".");return DOT;}
","     {token(",");return COMMA;}
":"     {token(":");return COLON;}
";"     {token(";");return SEMICOLON;}
"("     {token("(");return LPAREN;}
")"     {token(")");return RPAREN;}
"["     {token("[");return LBRACKET;}
"]"     {token("]");return RBRACKET;}
"{"     {token("{");}
"}"     {token("}");}
"+"   { token("+");return PLUS;}
"-"   { token("-");return MINUS;}
"*"   { token("*");return TIMES;}
"/"   { token("/");return DIVIDE;}
"mod" { token("mod");return MOD;}
":="  { token(":=");return ASSIGN;}
"<"   { token("<");return LESS;}
"<="  { token("<=");return LESS_EQUAL;}
">="  { token(">=");return GREATER_EQUAL;}
">"   { token(">");return GREATER;} 
"="   { token("=");return EQUAL;}
"not=" { token("not=");return NOT_EQUAL;}
"and" { token("and");return AND;}
"or"  { token("or");return OR;}
"not" { token("not");return NOT;}

"array" {keyword("ARRAY");return ARRAY;}
"begin" {keyword("BEGIN");return bg;}
"bool" {keyword("BOOL");return BOOL;}
"char" {keyword("CHAR");return CHAR;}
"const" {keyword("CONST");return CONST;}
"decreasing" {keyword("DECREASING");return DECREASING;}
"default" {keyword("DEFAULT");}
"do" {keyword("DO");}
"else" {keyword("ELSE");return ELSE;}
"end" {keyword("END");return END;}
"exit" {keyword("EXIT");return EXIT;}
"false" {keyword("FALSE");return FALSE_VALUE;}
"for" {keyword("FOR");return FOR;}
"function" {keyword("FUNCTION");return FUNCTION;}
"get" {keyword("GET");return GET;}
"if" {keyword("IF");return IF;}
"int" {keyword("INT");return INT;}
"real" {keyword("REAL");return REAL;}

"loop" {keyword("LOOP");return LOOP;}
"of" {keyword("OF");return OF;}
"put" {keyword("PUT");return PUT;}
"procedure" {keyword("PROCEDURE");return PROCEDURE;}
"real" {keyword("REAL");return REAL;}
"result" {keyword("RESULT");return RESULT;}
"return" {keyword("RETURN");return RETURN;}
"skip" {keyword("SKIP");return SKIP;}
"string" {keyword("STRING");return STRING;}
"then" {keyword("THEN");return THEN;}
"true" {keyword("TRUE");return TRUE_VALUE;}
"var" {keyword("VAR");return VAR;}
"when" {keyword("WHEN");return WHEN;}



{whitespace}    {LIST;}

{integer}       {;tokenInteger("integer",yytext);yylval.intVal=atoi(yytext);return INTEGER_VALUE;}

{real}       {;tokenreal("real",yytext);yylval.realVal = atof(yytext);return REAL_VALUE;}

{identifier}    {tokenString("identifier",yytext);insert(yytext);strcpy(yylval.idVal, yytext);return IDENTIFIER;}

{comment}       {LIST;}

\{%     {
        LIST;
        BEGIN COMMET_STATE;
        }





<COMMET_STATE>%\}\n     {
        LIST;
        printf("%d: %s", linenum++, buf);
        buf[0] = '\0';
        BEGIN 0;
        }


<COMMET_STATE>\n     {
        LIST;

        }


<COMMET_STATE>.     {
        LIST;
        }


\"      {
        LIST;

        BEGIN STRING_STATE;
        }


<STRING_STATE>\"     {

        char c = input();

        if (c != '\"')
        {
                // do not LIST HERE
                tokenString("string",str);
                strcpy(yylval.strVal, str);
                // if c is eof
                if (c != EOF)
                {
                unput(c);
                }
                BEGIN 0;
                str[0] = '\0';
                return STRING_VALUE;
        }
        else
        {
                LIST;
                strcat(buf,"\"");
                strcat(str,yytext);
        }
}


<STRING_STATE>.     {
        LIST;
        strcat(str,yytext);
        }


\n      {
        LIST;
        printf("%d: %s", linenum++, buf);
        buf[0] = '\0';
        }

[ \t]*  {LIST;}

.       {
        LIST;
        printf("%d:%s\n", linenum+1, buf);
        printf("bad character:'%s'\n",yytext);
        exit(-1);
        }
%%


