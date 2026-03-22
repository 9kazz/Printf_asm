FILE = Printf
TARGET = $(FILE).exe
OBJ = $(FILE).o
SRC = $(FILE).s
LST = $(FILE).lst

.PHONY: all clean

all: $(TARGET)

$(TARGET): Printf.o
	ld -s -o $(TARGET) $(OBJ)
	@echo -----------------------------------------------------------------------

Printf.o: Printf.s
	nasm -f elf64 -l $(LST) -o $(OBJ) $(SRC)
	@echo -----------------------------------------------------------------------

clean:
	rm -f *.o *.lst *.exe