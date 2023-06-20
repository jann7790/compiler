%{
#include <stdio.h>
#include <locale.h>

#define LIST     strcat(buf,yytext)
#define token(t) {LIST; printf("<%s>\n",t );}
#define keyword(t) { LIST; printf("<%s>\n",t);}
#define tokenInteger(t,i) {LIST; printf("<%s:%s>\n",t,i);}
#define tokenNumber(t,i) {LIST; printf("<%s:%s>\n",t,i);}
#define tokenString(t,s) {LIST; printf("<%s:%s>\n",t,s);}
#define MAX_LINE_LENG 256
#define DEBUG 0 // change this to 1 to enable debug()
// #define DEBUG 1 // change this to 1 to enable debug()

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

int lookup(char* str)
{
        node* tmp = head;
        while(tmp != NULL)
        {
                if(strcmp(tmp->value,str) == 0)
                        return tmp->index;
                tmp = tmp->next;
        }
        return -1;
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
        debug("dump");
        while(tmp != NULL)
        {
                debug("aaaaaa");

                if(tmp->index >= 0)
                        printf("%d: %s\n",tmp->index,tmp->value);
                tmp = tmp->next;
        }
        debug("dump2");

        return 0;
}
%}


whitespace [ \t]+
digit [0-9]
letter [a-zA-Z]
identifier {letter}({digit}|{letter})*
integer {digit}+
number {integer}(\.{integer})?
comment "%".*

%x STRING_STATE
%x COMMET_STATE

%%

"."     {token(".");}
","     {token(",");}
":"     {token(":");}
";"     {token(";");}
"("     {token("(");}
")"     {token(")");}
"["     {token("[");}
"]"     {token("]");}
"{"     {token("{");}
"}"     {token("}");}
"+"   { token("+"); }
"-"   { token("-"); }
"*"   { token("*"); }
"/"   { token("/"); }
"mod" { token("mod"); }
":="  { token(":="); }
"<"   { token("<"); }
"<="  { token("<="); }
">="  { token(">="); }
">"   { token(">"); }
"="   { token("="); }
"not=" { token("not="); }
"and" { token("and"); }
"or"  { token("or"); }
"not" { token("not"); }

"array" {keyword("ARRAY");}
"begin" {keyword("BEGIN");}
"bool" {keyword("BOOL");}
"char" {keyword("CHAR");}
"const" {keyword("CONST");}
"decreasing" {keyword("DECREASING");}
"default" {keyword("DEFAULT");}
"do" {keyword("DO");}
"else" {keyword("ELSE");}
"end" {keyword("END");}
"exit" {keyword("EXIT");}
"false" {keyword("FALSE");}
"for" {keyword("FOR");}
"function" {keyword("FUNCTION");}
"get" {keyword("GET");}
"if" {keyword("IF");}
"int" {keyword("INT");}
"loop" {keyword("LOOP");}
"of" {keyword("OF");}
"put" {keyword("PUT");}
"procedure" {keyword("PROCEDURE");}
"real" {keyword("REAL");}
"result" {keyword("RESULT");}
"return" {keyword("RETURN");}
"skip" {keyword("SKIP");}
"string" {keyword("STRING");}
"then" {keyword("THEN");}
"true" {keyword("TRUE");}
"var" {keyword("VAR");}
"when" {keyword("WHEN");}



{whitespace}    {LIST;}

{integer}       {tokenInteger("integer",yytext);}

{number}       {tokenNumber("number",yytext);}

{identifier}    {tokenString("identifier",yytext);insert(yytext);}

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
                unput(c);
                str[0] = '\0';
                BEGIN 0;
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
        debug("endline");
        LIST;
        printf("%d: %s", linenum++, buf);
        buf[0] = '\0';
        }

[ \t]*  {LIST;}

.       {
        debug("bad character");
        LIST;
        printf("%d:%s\n", linenum+1, buf);
        printf("bad character:'%s'\n",yytext);
        exit(-1);
        }
%%


int main() {
        setlocale(LC_ALL, "");
        head = create();
        head->index = -1;
        strcpy(head->value,"NULLLLLLLLLLLLL");
        yylex();

        dump();
        exit(0);
}
