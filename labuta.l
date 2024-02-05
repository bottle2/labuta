%{
#include <assert.h>
#include <time.h>
#include "y.tab.h"
void yyerror(char *);
static int parse_minutes(char *string)
{
    int hours;
    int minutes;
    if (sscanf(string, "%d:%d", &hours, &minutes) != 2)
        assert(0);
    return minutes + hours * 60;
}
static struct tm parse_date(char *string)
{
    struct tm date = {0};
    if (sscanf(string, "%d/%d/%d", &date.tm_mday, &date.tm_mon, &date.tm_year) != 3)
        assert(0);
    date.tm_mon--;
    date.tm_year -= 1900;
    if (-1 == mktime(&date))
        assert(0);
    return date;
}
%}
%%
[0-9]+\/[0-9]+\/20[0-9]+\n { yylval.date    = parse_date(yytext);    return DATE; }
[0-9]+:[0-9]+\n                { yylval.elapsed = parse_minutes(yytext); return TIME; }
[^\n]*\n                               { yylval.task    = yytext;                return TASK; }
%%
int yywrap(void)
{
    return 1;
}
