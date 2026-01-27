%{
#include <stdio.h>
%}

%option noyywrap
%x COMMENT

%%
[ \t\n]+            ;

"//".*              ;

"/*"                { BEGIN(COMMENT); }

<COMMENT>[^*\n]+    ;
<COMMENT>"*"+[^*/]  ;
<COMMENT>\n         ;
<COMMENT>"*"+"/"    { BEGIN(INITIAL); }

.                   ;
%%

int main(void)
{
    yylex();
    return 0;
}
