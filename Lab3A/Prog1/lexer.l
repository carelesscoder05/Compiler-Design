%{
#include "parser.tab.h"
%}

%%

"while"        { return WHILE; }

"("            { return LPAREN; }
")"            { return RPAREN; }
"{"            { return LBRACE; }
"}"            { return RBRACE; }
";"            { return SEMICOLON; }

"<"            { return LT; }
"+"            { return PLUS; }
"="            { return ASSIGN; }

[0-9]+         { return NUMBER; }
[a-zA-Z_][a-zA-Z0-9_]*   { return ID; }

[ \t\n]+       ;   /* ignore whitespace */

.              { printf("Unknown character: %s\n", yytext); }

%%