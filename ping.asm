%include "linux.inc"
%include "asm_functions.asm"


global _start

section .data
    ERROR_MSG db "PING ERROR", 0xA
    ERROR_MSG_LEN equ ($ - ERROR_MSG)

    struc SOCKADDR_IN
        .sin_family resw 1 ;word 2 bytes (AF_INET = 2)
        .sin_port   resw 1 ;word 2 bytes (Port in network byte order)
        .sin_addr   resd 1 ;doubleword 4 bytes (IP address / INADDR_ANY)
        .sin_zero   resb 8 ;bytes 8 bytes (Padding to match sockaddr size)
    endstruc
    SOCKADDR_SIZE equ 16
    SOCKADDR_SIZE_VAR dd 16

    struc ICMP_HDR
        .type       resb 1        ; 8 = ICMP Echo Request
        .code       resb 1        ; 0 = Standard echo request code
        .checksum   resw 1        ; Clear to 0 before calculating checksum!
        .id         resw 1        ; Identifier (Arbitrary or Process ID, Big-Endian)
        .seq        resw 1        ; Sequence Number (e.g., 1 in Big-Endian)
    endstruc
    
    struc TIMEOUT_SOCK
        .second     resq 1
        .ms         resq 1
    endstruc    

    TIMEOUT_VAL:
        istruc TIMEOUT_SOCK
            at TIMEOUT_SOCK.second,  dq 0
            at TIMEOUT_SOCK.ms,      dq 500000
        iend
    TIMEOUT_VAL_SIZE equ 16

    ICMP_PACKET:
        istruc ICMP_HDR
            at ICMP_HDR.type,     db 8          ; Echo Request
            at ICMP_HDR.code,     db 0          ; Always 0 for Echo
            at ICMP_HDR.checksum, dw 0x3762;0x425C     ; MUST be 0 during checksum generation!
            at ICMP_HDR.id,       dw 0x3412     ; ID (Big-Endian format)
            at ICMP_HDR.seq,      dw 0x0100     ; Sequence (Big-Endian format)
        iend
        .payload db "ABCDEFGHIJKLMNOPQRSTUVWXYZ012345"
    ICMP_PACKET_SIZE equ 40


section .rodata
    TIME_KEY db "-t"


section .bss
    READER_BUFFER resb 15
    PRINTER_BUFFER resb 4096    
    PING_ADDR resb 16
    PING_ADDR_RECV resb 16
    RECV_BUFFER resb 4096


section .text
;OPEN RAW SOCKET return in RAX
_GET_RAW_SOCKET:
    push rbp
    mov rbp, rsp

    mov rax, 41
    mov rdi, AF_INET
    mov rsi, 3
    mov rdx, 1
    syscall
    
    mov rsp, rbp
    pop rbp
    ret


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
    
    ;DEBUG PRINTS
    mov rsi, [rsp + 16]
    mov rdx, rax
    call _PRINT_STR
    mov rsi, NEWSTRING
    mov rdx, 1
    call _PRINT_STR
    
    ;CONVERT ADDR TO BIN
    mov rsi, [rsp + 16]
    mov r11, 1
    call _STRIP_TO_BINIP
    ;SOCKADDR STRUCT INIT
    ;CLEAR JUNK
    mov qword [PING_ADDR], 0
    mov qword [PING_ADDR + 8], 0
    ;INIT
    mov word [PING_ADDR + SOCKADDR_IN.sin_family], AF_INET
    mov word [PING_ADDR + SOCKADDR_IN.sin_port], PORT
    mov dword [PING_ADDR + SOCKADDR_IN.sin_addr], eax
    mov qword [PING_ADDR + SOCKADDR_IN.sin_zero], 0
    ;DEBUG PRINT
    mov rdi, [PING_ADDR + SOCKADDR_IN.sin_addr]
    mov rsi, PRINTER_BUFFER
    mov rdx, 4096
    call _PRINT_INT    
    mov rsi, NEWSTRING
    mov rdx, 1
    call _PRINT_STR

    call _GET_RAW_SOCKET
    ;test for sock err
    test rax, rax
    js .errorexit    
    ;storing raw socket
    mov r15, rax

    ;set timeout for sockopt
    ;setsockopt(sock_fd, level, optname, optval, optlen)
    mov rax, 54
    mov rdi, r15                   ; socket file descriptor
    mov rsi, 1
    mov rdx, 20
    mov r10, TIMEOUT_VAL
    mov r8,  TIMEOUT_VAL_SIZE
    syscall    
    ;check errors
    test rax, rax
    js .errorexit
    
.timeout:
    ;sendto syscall (sock_fd, buf, len, flags, dest_addr, addr_len)
    mov rax, 44
    mov rdi, r15
    mov rsi, ICMP_PACKET
    mov rdx, ICMP_PACKET_SIZE
    mov r10, 0
    mov r8, PING_ADDR
    mov r9, 16
    syscall
    ;NEED TO CHECK RAX FOR ERRROR if < 0 error, other bytes send
    cmp rax, 0
    jle .errorexit
    
    ; recvfrom(sock_fd, buf, len, flags, src_addr, addrlen_ptr)
    mov rax, 45
    mov rdi, r15
    mov rsi, RECV_BUFFER
    mov rdx, 4096
    mov r10, 0
    mov r8,  PING_ADDR_RECV
    mov r9,  SOCKADDR_SIZE_VAR
    syscall
    ;NEED TO CHECK RAX FOR ERRROR if < 0 error, other bytes send
    ;THIS IS TIMEOUT
    cmp rax, -11
    je .timeout
    ;THIS IS FATAL ERRIR
    cmp rax, 0
    jle .errorexit
    
    ;NEED TO CHECK RECV_BUFFER ON TIMEOUT AND ICMP PROTO
    mov rsi, RECV_BUFFER
    add rsi, 28
    mov rdx, rax
    sub rdx, 28
    call _PRINT_STR
    ;newstr
    mov rsi, NEWSTRING
    mov rdx, 1
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
