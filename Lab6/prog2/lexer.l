%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "parser.tab.h"
%}

%option noyywrap

%%

[ \t\n]+               { /* Ignore whitespace */ }
[0-9]+                 { yylval.num = atoi(yytext); return NUM; }
[a-zA-Z_][a-zA-Z0-9_]* { yylval.str = strdup(yytext); return ID; }

"+"                    { return PLUS; }
"-"                    { return MINUS; }
"*"                    { return MUL; }
"/"                    { return DIV; }
"="                    { return ASSIGN; }
";"                    { return SEMI; }

.                      { printf("Unknown character: %s\n", yytext); }

%%