%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "test.tab.h"

void showError();
%}

digit   [0-9]+
if      "if"
else    "else"
cleft   "{"
cright  "}"
rleft   "("
rright  ")"

%%

{if}        { return IF; }
{else}      { return ELSE; }
{cleft}     { return cL; }
{cright}    { return cR; }
{rleft}     { return rL; }
{rright}    { return rR; }

{digit}     { yylval.a = atoi(yytext); return DIGIT; }

";"         { return SEMICOLON; }

[ \t\n]+    { /* ignore whitespace */ }

.           { showError(); return OTHER; }

%%

void showError()
{
    printf("Other input\n");
}

int yywrap(void)
{
    return 1;
}