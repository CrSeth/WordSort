TARGET =  WordSort #Name of main .asm file

all: $(TARGET:=.o)
	ld -m elf_i386 $(TARGET:=.o) io.o -o $(TARGET)

$(TARGET:=.o): clean
	nasm -f elf32 $(TARGET:=.asm)

clean:
	-rm -f $(TARGET:=.o)
	-rm -f $(TARGET)
