%{
#include "parser.tab.h"
#include <string.h>
#include <stdlib.h>
%}

%%

"integer"      { return INTEGER; }
"real"         { return REAL; }
"array"        { return ARRAY; }
"of"           { return OF; }

":"            { return COLON; }
";"            { return SEMI; }
"["            { return LBRACK; }
"]"            { return RBRACK; }
"^"            { return PTR_SYM; }

[0-9]+         { yylval.val = atoi(yytext); return NUM; }

[a-zA-Z][a-zA-Z0-9]* {
                    strcpy(yylval.name, yytext);
                    return ID;
                  }

[ \t\n]+       ;   /* Ignore whitespace */

.              { return yytext[0]; }

%%

int yywrap() { return 1; }