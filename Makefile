team:
	@echo -e "Team: ECE468NEW\n"
	@echo -e "Ray Yan"
	@echo -e "yan195\n"
	@echo -e "Quang Nguyen"
	@echo -e "baoquang98"
compiler:
	flex lexer.l
	bison -d microparser.y
	gcc -g -std=gnu99 lexer_driver.c microparser.tab.c lex.yy.c -o parser
clean:
	rm microparser.tab.c
	rm microparser.tab.h
	rm lex.yy.c
	rm parser
