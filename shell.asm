global _start

section .data
    MSG db "Shell code hello", 0xA
    MSG_LEN equ ($ - MSG)

section .bss

section .rodata

section .text
_start:
; Socket(AF_INET, SOCK_STREAM, IPPROTO_IP)
; rdi = family, rsi = type, rdx = protocol
    xor rdx, rdx            ; rdx = 0 (IPPROTO_IP) 
    mov rsi, 1              ; rsi = 1 (SOCK_STREAM)
    mov rdi, 2              ; rdi = 2 (AF_INET / IPv4)                                          
    mov rax, 41             ; (41)
    syscall 
; SOCKET SAVE
    mov rdi, rax
    mov r15, rdi
; SOCKADDR IN ON STACK(SHORTLY) (16 байт): [2 байта family][2 байта port][4 байта IP][8 байт нулей]
    push rdx    ;8 byte 
;IP (4 bytes), PORT (2 BYTES), Family (2 BYTES)
    mov rbx, 0xFEFFFF80C6EAFFFD ;0.0.0.0:5433
    not rbx
    push rbx
    mov rsi, rsp            ; rsi = ptr to begin struc of sockaddr_in on stack
;CONNECT PART
    mov rdx, 16              ; rdx = 16 size of struc
    mov rax, 42
    syscall
;what we do ? just connect, or hello?
    mov rdi, r15
    mov rax, 1
    mov rsi, MSG
    mov rdx, MSG_LEN
    syscall

    mov rax, 60
    mov rdi, 0
    syscall
