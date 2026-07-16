%include "linux.inc"
%include "asm_functions.asm"


global _start


section .data
HELLO_MSG db "WRITE PATH TO FILE", 0xA
HELLO_MSG_LEN equ ($ - HELLO_MSG)
BYTE_READED db "BYTE READED: "
BYTE_READED_LEN equ ($ - BYTE_READED)


section .rodata


section .bss
filename_buffer resb 4096
reader_buffer resb 4096
data_buff resb 128


section .text
;RDI filepath, return FD in RAX
OPEN_FILE_RO:
    push rbp
    mov rbp, rsp

    mov rax, 2              ; syscall: open
    mov rsi, 0              ; O_RDONLY
    mov rdx, 0              ; режим не нужен (файл не создаём)
    syscall

    test rax, rax           ; rax < 0?
    js .error               ; если отрицательное — ошибка
    
    mov rsp, rbp
    pop rbp
    ret
.error:
    mov rax, -1
    mov rsp, rbp
    pop rbp
    ret


;FD to RDI
CLOSE_FILE:
    push rbp
    mov rbp, rsp

    mov rax, 3
    syscall

    mov rsp, rbp
    pop rbp
    ret


;RDI FD ptr, RSI reader buffer ptr, RDX read data chunk, return size of readed in RAX
_READ_FROM_FILE:
    push rbp
    mov rbp, rsp
.read_loop:
    ; read(fd, buf, 4096)
    mov rax, 0
    syscall
    ; rax = количество прочитанных байт
    test rax, rax
    js .error               ; rax < 0: ошибка
    jz .eof                 ; rax = 0: конец файла
    ; rax > 0: прочитали rax байт, обрабатываем
    add rbx, rax            ; сохранить количество байт
    ; ... обработка buf[0..rbx-1] ...
    jmp .read_loop          ; читать следующую порцию
.eof:
    ; файл прочитан до конца
    jmp .done
.error:
    mov rax, -1
    mov rsp, rbp
    pop rbp
    ret
.done:
    mov rsi, BYTE_READED
    mov rdx, BYTE_READED_LEN
    call _PRINT_STR
    mov rdi, rbx
    mov rsi, data_buff
    mov rdx, 128
    call _PRINT_INT

    mov rax, rbx
    mov rsp, rbp
    pop rbp
    ret


_start:
;PRINT HELLO MESSAGE
    mov rsi, HELLO_MSG
    mov rdx, HELLO_MSG_LEN
    call _PRINT_STR

;GET USER FILEPATH DATA
    mov rsi, filename_buffer
    mov rdx, 4096
    call _READ
;REMOVE LAST 0xA from readed BUFFER filepath
    mov [filename_buffer + rax - 1], 0
;OPEN FILE
    xor rax, rax
    mov rdi, filename_buffer
    call OPEN_FILE_RO

    test rax, rax           ; rax < 0?
    js .exit_err
;SAVE FD
    mov r12, rax
;READ FROM FILE
    mov rdi, r12
    mov rsi, reader_buffer
    mov rdx, 4096
    call _READ_FROM_FILE

    test rax, rax           ; rax < 0?
    js .exit_err
;SAVE READED LEN
    mov rdx, rax
;CLOSE FILE
    mov rdi, r12
    call CLOSE_FILE
;PRINT READED BUFFER
    mov rsi, reader_buffer
    call _PRINT_STR

    jmp .exit_noerr
.exit_err:
    mov rax, 60
    mov rdi, 1
    syscall
.exit_noerr:
    mov rax, 60
    mov rdi, 0
    syscall
