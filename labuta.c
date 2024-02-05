#include <assert.h>
#include <locale.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

time_t start;

static void end(void)
{
    int elapsed = difftime(time(NULL), start) / 60;

    printf("%02d:%02d\n", elapsed / 60, elapsed % 60);
}

void yyparse(void);
void print_week(void);

int main(int argc, char *argv[])
{
    char *category = setlocale(LC_ALL, "pt-BR.UTF8");
    assert(category != NULL);

    if (2 == argc && 'r' == argv[1][0])
    {
        yyparse();
        print_week();
        return 0;
    }

    start = time(NULL);

    if (2 == argc && 'n' == argv[1][0])
    {
        char date[sizeof("DD/MM/YYYY")];
        
        if (!strftime(date, sizeof (date), "%d/%m/%Y", localtime(&start)))
            assert(0);
        puts(date);
    }

    atexit(end);
    getchar();

    return 0;
}
