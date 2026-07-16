; файл: linux.inc
%ifndef LINUX_INC
%define LINUX_INC

SYS_READ   equ 0
SYS_WRITE  equ 1
SYS_EXIT   equ 60

STDIN      equ 0
STDOUT     equ 1
STDERR     equ 2

EXIT_OK    equ 0
EXIT_ERR   equ 1

NEWLINE    equ 10

%endif
