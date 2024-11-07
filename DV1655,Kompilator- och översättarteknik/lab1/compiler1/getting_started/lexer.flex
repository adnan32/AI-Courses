%top{
#include "parser.tab.hh"
#define YY_DECL yy::parser::symbol_type yylex()
#include "Node.h"
int lexical_errors = 0;
}
%option yylineno noyywrap nounput batch noinput stack 
%%

"return"                {return yy::parser::make_RETURN(yytext);}
"class"                 {return yy::parser::make_CLASS(yytext);}
"public"                {return yy::parser::make_PUBLIC(yytext);}
"{"                     {return yy::parser::make_LC(yytext);}
"}"                     {return yy::parser::make_RC(yytext);}
"static"                {return yy::parser::make_STATIC(yytext);}
"void"                  {return yy::parser::make_VOID(yytext);}
"main"                  {return yy::parser::make_MAIN(yytext);}
"String"                {return yy::parser::make_STRTYPE(yytext);}               
"["                     {return yy::parser::make_LB(yytext);}
"]"                     {return yy::parser::make_RB(yytext);}
";"                     {return yy::parser::make_SEMICOLON(yytext);}
"int"                   {return yy::parser::make_INTTYPE(yytext);}
"boolean"               {return yy::parser::make_BOOL(yytext);}
"if"                    {return yy::parser::make_IF(yytext);}
"else"                  {return yy::parser::make_ELSE(yytext);}
"while"                 {return yy::parser::make_WHILE(yytext);}
"System.out.println"    {return yy::parser::make_SYSTEMOUTPRINTLN(yytext);}
"="                     {return yy::parser::make_ASSIGN(yytext);}
"&&"                    {return yy::parser::make_AND(yytext);}
"||"                    {return yy::parser::make_OR(yytext);}
"<"                     {return yy::parser::make_LESSTHAN(yytext);}
","                     {return yy::parser::make_COMMA(yytext);}
">"                     {return yy::parser::make_GREATERTHAN(yytext);}
"=="                    {return yy::parser::make_EQUALTO(yytext);}
"/"                     {return yy::parser::make_DVISON(yytext);}
"."                     {return yy::parser::make_DOT(yytext);}
"length"                {return yy::parser::make_LENGTH(yytext);}
"true"                  {return yy::parser::make_TRUE(yytext);}
"false"                 {return yy::parser::make_FALSE(yytext);}
"this"                  {return yy::parser::make_THIS(yytext);}
"new"                   {return yy::parser::make_NEW(yytext);}
"!"                     {return yy::parser::make_NOT(yytext);}
"+"                     {return yy::parser::make_PLUSOP(yytext);}
"-"                     {return yy::parser::make_MINUSOP(yytext);}
"*"                     {return yy::parser::make_MULTOP(yytext);}
"("                     {return yy::parser::make_LP(yytext);}
")"                     {return yy::parser::make_RP(yytext);}
0|[1-9][0-9]*           {return yy::parser::make_INT(yytext);}
[a-zA-Z_][a-zA-Z0-9_]*  {return yy::parser::make_IDENTIFIER(yytext);}     
[ \t\n\r]+              {/* ignore white space */}
"//".*                  {/* ignore line comments */}
.                       { if(!lexical_errors) fprintf(stderr, "Lexical errors found! See the logs below: \n"); printf("Character %s is not recognized\n", yytext); lexical_errors = 1;}
<<EOF>>                 return yy::parser::make_END();
%%