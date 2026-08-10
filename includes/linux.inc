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

;NETWORK EQU FOR SOCKETS
AF_INET      equ 2  ;sin_family
PORT         equ 0  ;sin_port
SOCK_STREAM  equ 1
IPPROTO_TCP  equ 6

%endif
