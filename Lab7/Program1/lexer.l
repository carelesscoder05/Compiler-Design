%{
#include "simple.tab.h"
#include <stdlib.h>
%}
%%
[ \t]+ ;
\n return '\n';
[a-zA-Z][a-zA-Z0-9]* { yylval.str = strdup(yytext); return ID; }
[0-9]+ { yylval.num = atoi(yytext); return NUM; }
"=" return '=';
"+" return '+';
"-" return '-';
"*" return '*';
"/" return '/';
. ;
%%
int yywrap() { return 1; }