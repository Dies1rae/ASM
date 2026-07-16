%include "linux.inc"
%include "asm_functions.asm"


global _start


section .data
HELLO_MSG db "WRITE FULL PATH AND FILENAME TO CREATE", 0xA
HELLO_MSG_LEN equ ($ - HELLO_MSG)
MSG_NXT db "WRITE A DATA TO SAVE IN A FILE", 0xA
MSG_NXT_LEN equ ($ - MSG_NXT)


section .rodata


section .bss
filename_buffer resb 4096
reader_buffer resb 4096
data_buff resb 4096


section .text
;RSI PTR TO DATA, RDX SIZE OF DATA, RDI FD, RAX RETURN
SAVE_TO_FILE:
write_all:
    push rbp
    mov rbp, rsp

    push rbx
    push r13
    push r14

    mov r13, rsi            ; указатель на данные
    mov r14, rdx            ; осталось записать

.write_loop:
    test r14, r14
    jz .done                ; всё записано

    mov rax, 1
    mov rsi, r13
    mov rdx, r14
    syscall

    test rax, rax
    jle .error              ; 0 или отрицательное — ошибка

    add r13, rax            ; сдвинуть указатель
    sub r14, rax            ; уменьшить остаток
    jmp .write_loop
.done:
    mov rax, 0
    pop r14
    pop r13
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
.error:
    ; обработка ошибки
    mov rax, 1
    pop r14
    pop r13
    pop rbx
    mov rsp, rbp
    pop rbp
    ret


;RDI for filepath+name, returned FD in RAX
CREATE_FILE:
    push rbp
    mov rbp, rsp

    mov rax, 2
    mov rsi, 0x241          ; O_WRONLY | O_CREAT | O_TRUNC
    mov rdx, 0o755          ; права: rw-r--r--
    syscall

    test rax, rax
    js .error
    
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
;PRINT NXT MESSAGE
    mov rsi, MSG_NXT
    mov rdx, MSG_NXT_LEN
    call _PRINT_STR
;GET USER INPUT DATA
    mov rsi, reader_buffer
    mov rdx, 4096
    call _READ
;SAVE READED SIZE IN R11
    mov r11, rax
;CREATE FILE WITH 0o755 0x241
    mov rdi, filename_buffer
    call CREATE_FILE
;SAVE FD in R12
    mov r12, rax
;WRITE USER INPUt INTO FILE AND SAVE
    mov rsi, reader_buffer
    mov rdx, r11
    mov rdi, r12
    call SAVE_TO_FILE

    test rax, rax
    js .error
.error:
    mov rax, 60
    mov rdi, 1
    syscall
.exit_good:
    ; close(fd)
    ;CLOSE FILE
    mov rdi, r12
    call CLOSE_FILE
    ;final exit
    mov rax, 60
    mov rdi, 0
    syscall

