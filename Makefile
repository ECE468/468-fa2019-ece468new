team:
	@echo -e "Team: ECE468NEW\n"
	@echo -e "Ray Yan"
	@echo -e "yan195\n"
	@echo -e "Quang Nguyen"
	@echo -e "baoquang98"
compiler:
	flex parser.l
	gcc -std=gnu99 parser_driver.c lex.yy.c -o parser
clean:
	rm lex.yy.c
	rm parser
