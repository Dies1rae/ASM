all:
	nasm -f elf64 -I ./includes/ -g -F dwarf $(source).asm
	ld -o $(source) $(source).o
	rm $(source).o
