%option noyywrap

%{
#include "parser.tab.h"
#include <string.h>
%}

%%

"int"      { return INT; }
"float"    { return FLOAT; }
"char"     { return CHAR; }
"double"   { return DOUBLE; }

"{"        { return LBRACE; }
"}"        { return RBRACE; }
";"        { return SEMICOLON; }

[a-zA-Z_][a-zA-Z0-9_]*  {
                            yylval.str = strdup(yytext);
                            return ID;
                        }

[ \t\n]+   ;

.          { printf("Unknown character: %s\n", yytext); }

%%