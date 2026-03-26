.PHONY: all clean


all: printf.exe

printf.exe: printf.o
	ld -s -o printf.exe printf.o
	@echo -----------------------------------------------------------------------

printf.o: printf.s
	nasm -f elf64 -l printf.lst -o printf.o printf.s
	@echo -----------------------------------------------------------------------


asminc: asminc.exe

# asminc.exe: printf.o test.cpp
# 	g++ printf.o test.cpp -o asminc.exe
# 	@echo -----------------------------------------------------------------------

asminc.exe: printf.o test.o
	g++ -pie printf.o test.o -o asminc.exe	
	@echo -----------------------------------------------------------------------

test.o: test.cpp
	g++ -fPIE -c test.cpp -o test.o
	@echo -----------------------------------------------------------------------

clean:
	rm -f *.o *.lst *.exe