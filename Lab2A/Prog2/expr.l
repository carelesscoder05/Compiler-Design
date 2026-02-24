%{
#include "expr.tab.h"
%}

%%
[ \t]+ ;
\n      { return 0; }            ;
[0-9]+                  { return NUM; }
[a-zA-Z_][a-zA-Z0-9_]*  { return ID; }

"&&"    { return AND; }
"||"    { return OR; }
"!"     { return NOT; }

"=="    { return EQ; }
"!="    { return NE; }
"<="    { return LE; }
">="    { return GE; }
"<"     { return LT; }
">"     { return GT; }

"+"     { return '+'; }
"-"     { return '-'; }
"*"     { return '*'; }
"/"     { return '/'; }
"("     { return '('; }
")"     { return ')'; }
%%

int yywrap(void) { return 1; }
