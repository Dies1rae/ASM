extern puts                 ; объявляем что puts — внешний символ

global main

section .data
    msg     db "Hello, world!", 0   ; null-terminated строка

section .text
main:
    push rbp                        ; сохраняем rbp (callee-saved)
    mov rbp, rsp                    ; создаём стековый фрейм
    
    ; puts(msg)
    mov rdi, msg                    ; 1-й аргумент: указатель на строку
    call puts

    ; Возвращаем 0 из main
    xor eax, eax
    
    mov rsp, rbp
    pop rbp
    ret
