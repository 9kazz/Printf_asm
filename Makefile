.PHONY: all clean


all: printf.exe

printf.exe: printf.o
	ld -s -o printf.exe printf.o
	@echo -----------------------------------------------------------------------

printf.o: printf.s
	nasm -f elf64 -l printf.lst -o printf.o printf.s
	@echo -----------------------------------------------------------------------


asminc: asminc.exe

asminc.exe: printf.o test.cpp
	g++ -no-pie printf.o test.cpp -o asminc.exe
	@echo -----------------------------------------------------------------------
	
double:	double_printf.exe

double_printf.exe: double_printf.o
	ld -s -o double_printf.exe double_printf.o
	@echo -----------------------------------------------------------------------

double_printf.o: double_printf.s
	nasm -f elf64 -l double_printf.lst -o double_printf.o double_printf.s
	@echo -----------------------------------------------------------------------	

clean:
	rm -f *.o *.lst *.exe