%include "linux.inc"
%include "asm_functions.asm"
extern printf
extern scanf
extern strlen
extern strcpy
extern strcat

global main

section .data
    fmt_str db "%s", 0
    equal db "==", 0
    less db "<", 0
    greater db ">", 0
    space db " ", 0
    nstr db 0xA

section .rodata

section .bss
    reader_buffer_1 resb 4096
    reader_buffer_2 resb 4096
    writer_buffer resb 4096

section .text
main:
    push rbp
    mov rbp, rsp
    ;sub rsp, 8      ;aded 8, to alligment by 16
;first string    
;scanf(%s, &str_buffer)
    mov rdi, fmt_str
    mov rsi, reader_buffer_1
    xor rax, rax
    call scanf
;second string    
;scanf(%s, &str_buffer)
    mov rdi, fmt_str
    mov rsi, reader_buffer_2
    xor rax, rax
    call scanf

    mov rdi, reader_buffer_1
    call strlen
    mov r15, rax

    mov rdi, reader_buffer_2
    call strlen
    mov r14, rax

    cmp r15, r14
    je .is_equal
    jg .is_greater
    jl .is_less
    jmp .print_result
.is_equal:
; strcpy(dst_ptr, src_ptr)
    mov rdi, writer_buffer  ; dst
    mov rsi, reader_buffer_1  ; src
    call strcpy
    mov rdi, writer_buffer
    mov rsi, space
    call strcat
    mov rdi, writer_buffer  
    mov rsi, equal
    call strcat
    mov rdi, writer_buffer  
    mov rsi, space
    call strcat
    mov rdi, writer_buffer
    mov rsi, reader_buffer_2
    call strcat
    mov rdi, writer_buffer
    mov rsi, nstr
    call strcat
    jmp .print_result
.is_greater:
; strcpy(dst_ptr, src_ptr)
    mov rdi, writer_buffer  ; dst
    mov rsi, reader_buffer_1  ; src
    call strcpy
    mov rdi, writer_buffer  
    mov rsi, space
    call strcat
    mov rdi, writer_buffer
    mov rsi, greater
    call strcat
    mov rdi, writer_buffer  
    mov rsi, space
    call strcat
    mov rdi, writer_buffer
    mov rsi, reader_buffer_2
    call strcat
    mov rdi, writer_buffer
    mov rsi, nstr
    call strcat
    jmp .print_result
.is_less:
; strcpy(dst_ptr, src_ptr)
    mov rdi, writer_buffer  ; dst
    mov rsi, reader_buffer_1  ; src
    call strcpy
    mov rdi, writer_buffer
    mov rsi, space
    call strcat
    mov rdi, writer_buffer
    mov rsi, less
    call strcat
    mov rdi, writer_buffer
    mov rsi, space
    call strcat
    mov rdi, writer_buffer
    mov rsi, reader_buffer_2
    call strcat
    mov rdi, writer_buffer
    mov rsi, nstr
    call strcat
    jmp .print_result
.print_result:
;printf(fmt, src_ptr)
    mov rdi, fmt_str
    mov rsi, writer_buffer
    xor rax, rax
    call printf

    xor rax, rax
    mov rsp, rbp
    pop rbp
    ret
