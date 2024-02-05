CFLAGS=-std=c17 -Wpedantic -Wall -Wextra -Wshadow

labuta:labuta.y labuta.l labuta.c
	yacc -yd labuta.y
	lex labuta.l
	$(CC) $(CFLAGS) lex.yy.c y.tab.c labuta.c -o $@

clean:
	rm -f y.tab.c labuta labuta.exe lex.yy.c y.tab.h
