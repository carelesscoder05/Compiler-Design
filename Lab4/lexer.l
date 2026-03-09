%{
#include "parser.tab.h"
#include <string.h>
%}

%%

[0-9]+ {
        yylval.str = strdup(yytext);
        return NUM;
      }

[a-zA-Z][a-zA-Z0-9]* {
        yylval.str = strdup(yytext);
        return ID;
      }

"=" return '=';
";" return ';';

"+" return '+';
"-" return '-';
"*" return '*';
"/" return '/';

"[" return '[';
"]" return ']';

"(" return '(';
")" return ')';

[ \t\n] ;

. return yytext[0];

%%

int yywrap()
{
    return 1;
}