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
# 	g++ -no-pie printf.o test.cpp -o asminc.exe
	g++ printf.o test.cpp -o asminc.exe
	@echo -----------------------------------------------------------------------
	
clean:
	rm -f *.o *.lst *.exe