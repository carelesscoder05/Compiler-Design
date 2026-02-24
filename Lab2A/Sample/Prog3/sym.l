%{
#include "sym.tab.h"
#include <string.h>

/* shared with yacc */
extern int current_scope;
%}

%%
"int"      { return INT; }
"float"    { return FLOAT; }
"char"     { return CHAR; }

[a-zA-Z_][a-zA-Z0-9_]*  {
                            strcpy(yylval.id, yytext);
                            return ID;
                        }

","        { return ','; }
";"        { return ';'; }

"{"        { current_scope++; }
"}"        { current_scope--; }

[ \t\n]+   ;
.          ;
%%
int yywrap(void) { return 1; }


/* run ./sym < sample.txt */