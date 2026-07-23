%include "linux.inc"
%include "asm_functions.asm"


global _start


section .data
HELLO_MSG db "ABS PATH OF THIS CATALOG IS:", 0xA
HELLO_MSG_LEN equ ($ - HELLO_MSG)

section .rodata

section .bss
abs_path_buffer resb 4096


section .text
;Ptr to buffer in  RDI, size of buffer in RSI, return buffer addr in RAX or -1
_ABS_PATH:
    push rbp
    mov rbp, rsp

    mov rax, 79
    syscall

    mov rsp, rbp
    pop rbp
    ret


_start:
;PRINT HELLO MESSAGE SYNOPSYS
    mov rsi, HELLO_MSG
    mov rdx, HELLO_MSG_LEN
    call _PRINT_STR
;PREPARING TO GET ABS PATH
    mov rdi, abs_path_buffer
    mov rsi, 4096
    call _ABS_PATH
;ERROR CHECK
    test rax, rax
    js .error

;PRINT ABS PATH with 0xA
    ;CALCULATE LEN OF abs_path_buffer AFTER syscall 79
    mov r12, abs_path_buffer
    add r12, rax
    inc r12
    ;ADD LAST 0xA to abs_path_buffer
    mov [abs_path_buffer + rax], 0xA
    println abs_path_buffer, r12
;ERROR CHECK
    test rax, rax
    js .error

.noerror:
    mov rax, 60
    mov rdi, 0
    syscall
.error:
    mov rax, 60
    mov rdi, 1
    syscall





