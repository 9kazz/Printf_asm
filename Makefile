FILE = Printf
TARGET = $(FILE).exe
OBJ = $(FILE).o
SRC = $(FILE).s
LST = $(FILE).lst

.PHONY: all clean

all: $(TARGET)

$(TARGET): Printf.o
	ld -s -m elf_i386 -o $(TARGET) $(OBJ)
	@echo -----------------------------------------------------------------------

Printf.o: Printf.s
	nasm -f elf -l $(LST) -o $(OBJ) $(SRC)
	@echo -----------------------------------------------------------------------

clean:
	rm -f *.o *.lst