#ifndef YY_parse_h_included
#define YY_parse_h_included
/*#define YY_USE_CLASS 
*/
#line 1 "/usr/share/bison++/bison.h"
/* before anything */
#ifdef c_plusplus
 #ifndef __cplusplus
  #define __cplusplus
 #endif
#endif


 #line 8 "/usr/share/bison++/bison.h"

#line 251 "parser.y"
typedef union{
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
} yy_parse_stype;
#define YY_parse_STYPE yy_parse_stype
#ifndef YY_USE_CLASS
#define YYSTYPE yy_parse_stype
#endif

#line 21 "/usr/share/bison++/bison.h"
 /* %{ and %header{ and %union, during decl */
#ifndef YY_parse_COMPATIBILITY
 #ifndef YY_USE_CLASS
  #define  YY_parse_COMPATIBILITY 1
 #else
  #define  YY_parse_COMPATIBILITY 0
 #endif
#endif

#if YY_parse_COMPATIBILITY != 0
/* backward compatibility */
 #ifdef YYLTYPE
  #ifndef YY_parse_LTYPE
   #define YY_parse_LTYPE YYLTYPE
/* WARNING obsolete !!! user defined YYLTYPE not reported into generated header */
/* use %define LTYPE */
  #endif
 #endif
/*#ifdef YYSTYPE*/
  #ifndef YY_parse_STYPE
   #define YY_parse_STYPE YYSTYPE
  /* WARNING obsolete !!! user defined YYSTYPE not reported into generated header */
   /* use %define STYPE */
  #endif
/*#endif*/
 #ifdef YYDEBUG
  #ifndef YY_parse_DEBUG
   #define  YY_parse_DEBUG YYDEBUG
   /* WARNING obsolete !!! user defined YYDEBUG not reported into generated header */
   /* use %define DEBUG */
  #endif
 #endif 
 /* use goto to be compatible */
 #ifndef YY_parse_USE_GOTO
  #define YY_parse_USE_GOTO 1
 #endif
#endif

/* use no goto to be clean in C++ */
#ifndef YY_parse_USE_GOTO
 #define YY_parse_USE_GOTO 0
#endif

#ifndef YY_parse_PURE

 #line 65 "/usr/share/bison++/bison.h"

#line 65 "/usr/share/bison++/bison.h"
/* YY_parse_PURE */
#endif


 #line 68 "/usr/share/bison++/bison.h"

#line 68 "/usr/share/bison++/bison.h"
/* prefix */

#ifndef YY_parse_DEBUG

 #line 71 "/usr/share/bison++/bison.h"

#line 71 "/usr/share/bison++/bison.h"
/* YY_parse_DEBUG */
#endif

#ifndef YY_parse_LSP_NEEDED

 #line 75 "/usr/share/bison++/bison.h"

#line 75 "/usr/share/bison++/bison.h"
 /* YY_parse_LSP_NEEDED*/
#endif

/* DEFAULT LTYPE*/
#ifdef YY_parse_LSP_NEEDED
 #ifndef YY_parse_LTYPE
  #ifndef BISON_YYLTYPE_ISDECLARED
   #define BISON_YYLTYPE_ISDECLARED
typedef
  struct yyltype
    {
      int timestamp;
      int first_line;
      int first_column;
      int last_line;
      int last_column;
      char *text;
   }
  yyltype;
  #endif

  #define YY_parse_LTYPE yyltype
 #endif
#endif

/* DEFAULT STYPE*/
#ifndef YY_parse_STYPE
 #define YY_parse_STYPE int
#endif

/* DEFAULT MISCELANEOUS */
#ifndef YY_parse_PARSE
 #define YY_parse_PARSE yyparse
#endif

#ifndef YY_parse_LEX
 #define YY_parse_LEX yylex
#endif

#ifndef YY_parse_LVAL
 #define YY_parse_LVAL yylval
#endif

#ifndef YY_parse_LLOC
 #define YY_parse_LLOC yylloc
#endif

#ifndef YY_parse_CHAR
 #define YY_parse_CHAR yychar
#endif

#ifndef YY_parse_NERRS
 #define YY_parse_NERRS yynerrs
#endif

#ifndef YY_parse_DEBUG_FLAG
 #define YY_parse_DEBUG_FLAG yydebug
#endif

#ifndef YY_parse_ERROR
 #define YY_parse_ERROR yyerror
#endif

#ifndef YY_parse_PARSE_PARAM
 #ifndef __STDC__
  #ifndef __cplusplus
   #ifndef YY_USE_CLASS
    #define YY_parse_PARSE_PARAM
    #ifndef YY_parse_PARSE_PARAM_DEF
     #define YY_parse_PARSE_PARAM_DEF
    #endif
   #endif
  #endif
 #endif
 #ifndef YY_parse_PARSE_PARAM
  #define YY_parse_PARSE_PARAM void
 #endif
#endif

/* TOKEN C */
#ifndef YY_USE_CLASS

 #ifndef YY_parse_PURE
  #ifndef yylval
   extern YY_parse_STYPE YY_parse_LVAL;
  #else
   #if yylval != YY_parse_LVAL
    extern YY_parse_STYPE YY_parse_LVAL;
   #else
    #warning "Namespace conflict, disabling some functionality (bison++ only)"
   #endif
  #endif
 #endif


 #line 169 "/usr/share/bison++/bison.h"
#define	STRING	258
#define	BOOL	259
#define	CHAR	260
#define	FLOAT	261
#define	INT	262
#define	ARRAY	263
#define	REAL	264
#define	STRING_VALUE	265
#define	REAL_VALUE	266
#define	INTEGER_VALUE	267
#define	TRUE_VALUE	268
#define	FALSE_VALUE	269
#define	IDENTIFIER	270
#define	COLON	271
#define	COMMA	272
#define	DOT	273
#define	OF	274
#define	END	275
#define	IF	276
#define	THEN	277
#define	ELSE	278
#define	LOOP	279
#define	FOR	280
#define	DECREASING	281
#define	bg	282
#define	LPAREN	283
#define	RPAREN	284
#define	LBRACKET	285
#define	RBRACKET	286
#define	LBRACE	287
#define	RBRACE	288
#define	FUNCTION	289
#define	PROCEDURE	290
#define	LESS	291
#define	GREATER	292
#define	WHEN	293
#define	SKIP	294
#define	EXIT	295
#define	RESULT	296
#define	RETURN	297
#define	PUT	298
#define	GET	299
#define	AND	300
#define	OR	301
#define	NOT	302
#define	GREATER_EQUAL	303
#define	LESS_EQUAL	304
#define	EQUAL	305
#define	NOT_EQUAL	306
#define	ASSIGN	307
#define	VAR	308
#define	CONST	309
#define	SEMICOLON	310
#define	PLUS	311
#define	MINUS	312
#define	TIMES	313
#define	DIVIDE	314
#define	MOD	315
#define	UMINUS	316


#line 169 "/usr/share/bison++/bison.h"
 /* #defines token */
/* after #define tokens, before const tokens S5*/
#else
 #ifndef YY_parse_CLASS
  #define YY_parse_CLASS parse
 #endif

 #ifndef YY_parse_INHERIT
  #define YY_parse_INHERIT
 #endif

 #ifndef YY_parse_MEMBERS
  #define YY_parse_MEMBERS 
 #endif

 #ifndef YY_parse_LEX_BODY
  #define YY_parse_LEX_BODY  
 #endif

 #ifndef YY_parse_ERROR_BODY
  #define YY_parse_ERROR_BODY  
 #endif

 #ifndef YY_parse_CONSTRUCTOR_PARAM
  #define YY_parse_CONSTRUCTOR_PARAM
 #endif
 /* choose between enum and const */
 #ifndef YY_parse_USE_CONST_TOKEN
  #define YY_parse_USE_CONST_TOKEN 0
  /* yes enum is more compatible with flex,  */
  /* so by default we use it */ 
 #endif
 #if YY_parse_USE_CONST_TOKEN != 0
  #ifndef YY_parse_ENUM_TOKEN
   #define YY_parse_ENUM_TOKEN yy_parse_enum_token
  #endif
 #endif

class YY_parse_CLASS YY_parse_INHERIT
{
public: 
 #if YY_parse_USE_CONST_TOKEN != 0
  /* static const int token ... */
  
 #line 212 "/usr/share/bison++/bison.h"
static const int STRING;
static const int BOOL;
static const int CHAR;
static const int FLOAT;
static const int INT;
static const int ARRAY;
static const int REAL;
static const int STRING_VALUE;
static const int REAL_VALUE;
static const int INTEGER_VALUE;
static const int TRUE_VALUE;
static const int FALSE_VALUE;
static const int IDENTIFIER;
static const int COLON;
static const int COMMA;
static const int DOT;
static const int OF;
static const int END;
static const int IF;
static const int THEN;
static const int ELSE;
static const int LOOP;
static const int FOR;
static const int DECREASING;
static const int bg;
static const int LPAREN;
static const int RPAREN;
static const int LBRACKET;
static const int RBRACKET;
static const int LBRACE;
static const int RBRACE;
static const int FUNCTION;
static const int PROCEDURE;
static const int LESS;
static const int GREATER;
static const int WHEN;
static const int SKIP;
static const int EXIT;
static const int RESULT;
static const int RETURN;
static const int PUT;
static const int GET;
static const int AND;
static const int OR;
static const int NOT;
static const int GREATER_EQUAL;
static const int LESS_EQUAL;
static const int EQUAL;
static const int NOT_EQUAL;
static const int ASSIGN;
static const int VAR;
static const int CONST;
static const int SEMICOLON;
static const int PLUS;
static const int MINUS;
static const int TIMES;
static const int DIVIDE;
static const int MOD;
static const int UMINUS;


#line 212 "/usr/share/bison++/bison.h"
 /* decl const */
 #else
  enum YY_parse_ENUM_TOKEN { YY_parse_NULL_TOKEN=0
  
 #line 215 "/usr/share/bison++/bison.h"
	,STRING=258
	,BOOL=259
	,CHAR=260
	,FLOAT=261
	,INT=262
	,ARRAY=263
	,REAL=264
	,STRING_VALUE=265
	,REAL_VALUE=266
	,INTEGER_VALUE=267
	,TRUE_VALUE=268
	,FALSE_VALUE=269
	,IDENTIFIER=270
	,COLON=271
	,COMMA=272
	,DOT=273
	,OF=274
	,END=275
	,IF=276
	,THEN=277
	,ELSE=278
	,LOOP=279
	,FOR=280
	,DECREASING=281
	,bg=282
	,LPAREN=283
	,RPAREN=284
	,LBRACKET=285
	,RBRACKET=286
	,LBRACE=287
	,RBRACE=288
	,FUNCTION=289
	,PROCEDURE=290
	,LESS=291
	,GREATER=292
	,WHEN=293
	,SKIP=294
	,EXIT=295
	,RESULT=296
	,RETURN=297
	,PUT=298
	,GET=299
	,AND=300
	,OR=301
	,NOT=302
	,GREATER_EQUAL=303
	,LESS_EQUAL=304
	,EQUAL=305
	,NOT_EQUAL=306
	,ASSIGN=307
	,VAR=308
	,CONST=309
	,SEMICOLON=310
	,PLUS=311
	,MINUS=312
	,TIMES=313
	,DIVIDE=314
	,MOD=315
	,UMINUS=316


#line 215 "/usr/share/bison++/bison.h"
 /* enum token */
     }; /* end of enum declaration */
 #endif
public:
 int YY_parse_PARSE(YY_parse_PARSE_PARAM);
 virtual void YY_parse_ERROR(char *msg) YY_parse_ERROR_BODY;
 #ifdef YY_parse_PURE
  #ifdef YY_parse_LSP_NEEDED
   virtual int  YY_parse_LEX(YY_parse_STYPE *YY_parse_LVAL,YY_parse_LTYPE *YY_parse_LLOC) YY_parse_LEX_BODY;
  #else
   virtual int  YY_parse_LEX(YY_parse_STYPE *YY_parse_LVAL) YY_parse_LEX_BODY;
  #endif
 #else
  virtual int YY_parse_LEX() YY_parse_LEX_BODY;
  YY_parse_STYPE YY_parse_LVAL;
  #ifdef YY_parse_LSP_NEEDED
   YY_parse_LTYPE YY_parse_LLOC;
  #endif
  int YY_parse_NERRS;
  int YY_parse_CHAR;
 #endif
 #if YY_parse_DEBUG != 0
  public:
   int YY_parse_DEBUG_FLAG;	/*  nonzero means print parse trace	*/
 #endif
public:
 YY_parse_CLASS(YY_parse_CONSTRUCTOR_PARAM);
public:
 YY_parse_MEMBERS 
};
/* other declare folow */
#endif


#if YY_parse_COMPATIBILITY != 0
 /* backward compatibility */
 /* Removed due to bison problems
 /#ifndef YYSTYPE
 / #define YYSTYPE YY_parse_STYPE
 /#endif*/

 #ifndef YYLTYPE
  #define YYLTYPE YY_parse_LTYPE
 #endif
 #ifndef YYDEBUG
  #ifdef YY_parse_DEBUG 
   #define YYDEBUG YY_parse_DEBUG
  #endif
 #endif

#endif
/* END */

 #line 267 "/usr/share/bison++/bison.h"
#endif
