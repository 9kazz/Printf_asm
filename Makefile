.PHONY: all clean


all: printf.exe

printf.exe: printf.o
	ld -s -o printf.exe printf.o
	@echo -----------------------------------------------------------------------

printf.o: printf.s
	nasm -f elf64 -l printf.lst -o printf.o printf.s
	@echo -----------------------------------------------------------------------


asminc: asminc.exe

asminc.exe: printf.o test.c
	gcc -no-pie printf.o test.c -o asminc.exe
	@echo -----------------------------------------------------------------------
	

clean:
	rm -f *.o *.lst *.exe