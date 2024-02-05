%{
#include <assert.h>
#include <stdbool.h>
#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <string.h>
int yylex(void);
void yyerror(char *s);

struct task
{
    struct task *prev;
    char text[];
};

struct day
{
    struct tm date;
    int elapsed;

    struct task *task;
};

static struct days
{
    int n_day;
    struct day them[7];
} days = {0};

static struct day current;

static int iso8601_week(struct tm *date)
{
    char week_str[3];
    if (!strftime(week_str, 3, "%V", date))
        assert(0);
    return atoi(week_str);
}

static void push_task(char *task)
{
    struct task *it = malloc(sizeof (struct task) + 1 + strlen(task));
    assert(it != NULL);
    strcpy(it->text, task);
    it->prev = current.task;
    current.task = it;
}

static void print_tasks_freeing(struct task *it)
{
    if (it != NULL)
    {
        print_tasks_freeing(it->prev);
        printf("%s", it->text);
        free(it);
    }
}

static void print_day(struct day *it)
{
    char weekday[20];

    strftime(weekday, 20, "%A", &it->date);
    weekday[0] = toupper(weekday[0]);
    printf("%s: %dh%dmin\n", weekday, it->elapsed / 60, it->elapsed % 60);

    print_tasks_freeing(it->task);
}

void print_week(void)
{
    char wyear[5];
    if (!strftime(wyear, 5, "%G", &days.them[0].date))
        assert(0);

    char *from = (char [50]){0};
    char *to = (char [50]){0};
    char *from_fmt = "%e de %B";

    if (days.them[0].date.tm_mon == days.them[days.n_day - 1].date.tm_mon)
        from_fmt = "%e";

    if (!strftime(from, 50, from_fmt, &days.them[0].date))
        assert(0);
    if (!strftime(to, 50, "%e de %B", &days.them[days.n_day - 1].date))
        assert(0);

    if (' ' == from[0]) from++;
    if (' ' == to[0]) to++;

    printf(
        "\nSemana %d de %s, do dia %s a %s.\n\n",
        iso8601_week(&days.them[0].date), wyear, from, to
    );

    int total = 0;
    for (int i = 0; i < days.n_day; i++)
    {
        print_day(days.them + i);
        total += days.them[i].elapsed;
    }
    printf("Total: %dh%dmin\n", total / 60, total % 60);
}

static bool same_week(struct tm *one, struct tm *other)
{
    return iso8601_week(one) == iso8601_week(other);
}

static void push_day_maybe_print_week(void)
{
    if (0 == current.elapsed)
    {
        assert(NULL == current.task);
        return;
    }

    if (days.n_day >= 1 && !same_week(&days.them[0].date, &current.date))
    {
        print_week();
        days.n_day = 0;
    }

    days.them[days.n_day++] = current;
}

%}
%token <date>    DATE
%token <elapsed> TIME
%token <task>    TASK
%union {
    struct tm date;
    int       elapsed;
    char     *task;
}
%%
work:
	work { memset(&current, 0, sizeof (current)); }
	DATE { current.date = $3; }
	list { push_day_maybe_print_week(); }
	|
	;

list:
	list TASK { push_task($2); }
	| list TIME { current.elapsed += $2; }
	|
	;
%%
void yyerror(char *s)
{
    fprintf(stderr, "%s\n", s);
}
