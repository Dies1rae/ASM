COMPILER ?= ld
ifeq ($(COMPILER), gcc)
	COMPILE_CMD = gcc $(source).c ./includes/$(source).o -o $(source) -no-pie
    else ifeq ($(COMPILER), ld)
	COMPILE_CMD = ld -o $(source) $(source).o -lc -dynamic-linker /lib64/ld-linux-x86-64.so.2
    else
	$(error Unknown COMPILER target. Use 'make COMPILER=gcc' or 'make COMPILER=ld')
    endif

all:
	nasm -f elf64 -I ./includes/ -g -F dwarf ./includes/$(source).asm
	$(COMPILE_CMD)
	rm ./includes/$(source).o

