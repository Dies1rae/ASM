%include "linux.inc"
%include "asm_functions.asm"


global _start

section .data
    ERROR_MSG db "PING ERROR", 0xA
    ERROR_MSG_LEN equ ($ - ERROR_MSG)

section .rodata

section .bss
    READER_BUFFER resb 15

section .text
_start:
;GET STRING FOR IP ADDRES
    mov rbx, [rsp]
;More than 3 arg (name, addr, -t opt)
    cmp rbx, 3
    jg .errorexit
;Less than 2arg (name, addr)    
    cmp rbx, 1
    jle .errorexit

    lea r12, [rsp + 8]

    mov rsi, [rsp + 16]
    call _STRLEN

    mov rsi, [rsp + 16]
    mov rdx, rax
    call _PRINT_STR

.noerrorexit:
    mov rax, 60
    mov rdi, 0
    syscall

.errorexit:
    mov rsi, ERROR_MSG
    mov rdx, ERROR_MSG_LEN
    call _PRINT_STR

    mov rax, 60
    mov rdi, 1
    syscall
