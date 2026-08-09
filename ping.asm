%include "linux.inc"
%include "asm_functions.asm"


global _start

section .data
    ERROR_MSG db "PING ERROR"
    ERROR_MSG_LEN equ ($ - ERROR_MSG)

section .rodata

section .bss
    READER_BUFFER resb 15

section .text
_start:
;GET STRING FOR IP ADDRES
    mov rsi, READER_BUFFER
    mov rdx, 15
    call _READ

    mov rsi, READER_BUFFER
    mov rdx, rax
    call _PRINT_STR

.noerror:
    mov rax, 60
    mov rdi, 0
    syscall
