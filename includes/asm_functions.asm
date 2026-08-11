section .rodata
    MINUSCHAR db "-"
    NEWSTRING db 0xA

section .text
;Print str, RDX LENGTH OF BUFF, RSI PTR TO DATA
_PRINT_STR:
    push rbp
    mov rbp, rsp

    mov rax, 1
    mov rdi, 1
    syscall

    mov rsp, rbp
    pop rbp
    ret


;read from input to buffer, buffer for read in RSI, max size in RDX, return len in RAX
_READ:
    push rbp
    mov rbp, rsp

    mov rax, 0
    mov rdi, 0
    syscall

    mov rsp, rbp
    pop rbp
    ret


;parse and print int, RDI int var to print, RSI databuffer, RDX databuffer size
_PRINT_INT:
    push rbp
    mov rbp, rsp

    push rbx
    push r12
    push r13
    push r14

    cmp rdi, 0
    jge .is_positive
    neg rdi
    
    push rdi                    ; Preserve our positive number
    push rcx                    ; Preserve buffer pointer
    push rdx
    push rsi
    
    mov rdx, 1
    mov rsi, MINUSCHAR
    call _PRINT_STR
    
    pop rsi
    pop rdx
    pop rcx                     ; Restore buffer pointer
    pop rdi
.is_positive:
    mov r14, rdx
    mov r12, rdi
    lea r13, [rsi + r14 - 1]
    mov byte [r13], 0xA
.loop:
    dec r13
    mov rax, r12
    xor rdx, rdx
    mov rbx, 10
    div rbx
    add dl, '0'
    mov [r13], dl
    mov r12, rax
    test rax, rax
    jnz .loop
    lea rax, [rsi + r14]
    sub rax, r13

    mov rdx, rax
    mov rsi, r13
    call _PRINT_STR
    
    pop r14
    pop r13
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret


;int to rax from buffer, databuffer to RSI, return int data in RAX
_PARSE_INT:
    push rbp
    mov rbp, rsp
    push rbx

    xor r8, r8
    xor rcx, rcx
    xor rax, rax
.loop:
    movzx rbx, byte [rsi + rcx]
    cmp rbx, '-'
    je .is_neg
    
    cmp rbx, '0'
    jl .done

    cmp rbx, '9'
    jg .done

    sub rbx, '0'
    imul rax, 10
    add rax, rbx
    inc rcx
    jmp .loop
.is_neg:
    mov r8, 1
    inc rcx
    jmp .loop
.done:
    cmp r8, 1
    je .do_neg
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
.do_neg:
    neg rax
    xor r8, r8
    jmp .done


;Ptr to bytestr in RSI, bytestr len in RDX, return max int in RAX
_FIND_MAX_IN_CHARSTR:
    push rbp
    mov rbp, rsp
    push r15
    push rbx

    mov rcx, 0
    xor rax, rax
    mov r8, 0x8000000000000000
.loop:
    cmp rcx, rdx
    jge .done
    movzx rbx, byte [rsi + rcx]
    cmp rbx, 0xA
    je .done

    cmp rbx, ' '
    je .skip

    cmp rbx, '-'
    je .negotiate_byte

    cmp rbx, '0'
    jl .done

    cmp rbx, '9'
    jg .done

    sub rbx, '0'
    imul rax, 10
    add rax, rbx
    inc rcx
    jmp .loop
.skip:
    cmp r15, 1
    je .neg_
    cmp r8, rax
    jl .swap
    inc rcx
    xor rax, rax
    jmp .loop
    .neg_:
        neg rax
        xor r15, r15
        jmp .skip
    .swap:
        mov r8, rax
        jmp .skip
.negotiate_byte:
    mov r15, 1
    inc rcx
    jmp .loop
.done:
    cmp r15, 1
    je .neglast_
    cmp r8, rax
    jg .swaplast
    pop rbx
    pop r15
    mov rsp, rbp
    pop rbp
    ret
    .neglast_:
        neg rax
        xor r15, r15
        jmp .done
    .swaplast:
        mov rax, r8
        jmp .done


;Get strbuffer ptr to RSI, get strbuffer max len to RDX,int to RDI, return new buffer in RSI and len in rax 
_PARSE_INT_TO_STR_BUFF:
    push rbp
    mov rbp, rsp
    push rbx

    mov rbx, 10
    mov rax, rdi
    xor rcx, rcx
.loop_convert:
    xor rdx, rdx
    div rbx
    add dl, '0'
    push rdx
    inc rcx
    test rax, rax
    jnz .loop_convert

    mov rdi, rsi
    mov rbx, rcx

.loop_restore:
    pop rdx
    mov [rdi], dl
    inc rdi
    dec rcx
    jnz .loop_restore

    mov byte [rdi], 0xA ; OR MAYBE JUST 0 or nothing 
    inc rbx
    mov rax, rbx

    pop rsi
    pop rbx
    mov rsp, rbp
    pop rbp
    ret


; strlen(rsi) — длина строки, результат в rax
_STRLEN:
    push rbp
    mov rbp, rsp
    xor rax, rax
.loop:
    cmp byte [rsi + rax], 0
    je .done
    cmp byte [rsi + rax], 0xA
    je .done
    inc rax
    jmp .loop
.done:
    mov rsp, rbp
    pop rbp
    ret


;R8 ptr to first str, R9 len of first str, R10 ptr to second str, RAX len of second str, return RSI ptr to appended first str, RAX new len first str 
_APPEND_FIRST_STR:
    push rbp
    mov rbp, rsp

    lea rsi, [r10]
    lea rdi, [r8 + r9 - 1] ;if you do not need \0 in first string get -1 from len
    mov rcx, rax
    cld
    rep movsb
    add rax, r9

    mov rsp, rbp
    pop rbp
    ret


;Gets pointer to ip string in RSI, return binary ip addr for sock in RAX
;if reg R11 store 1 thats big endian, 0 little endian
_STRIP_TO_BINIP:
    push rbp
    mov rbp, rsp
    
    ;fin ip
    xor rax, rax
    ;storing buf
    xor rcx, rcx
    ;curr octet in bin
    xor rdx, rdx
.loop:
    movzx rcx, byte [rsi]
    inc rsi
    ;end of all octets 0
    test rcx, rcx
    jz .endloop
    cmp rcx, 0xA
    je .endloop
    
    ;end octet storing
    cmp rcx, '.'
    je .store_octet

    ;check errors
    cmp rcx, '0'
    jl .errorexit
    cmp rcx, '9'
    jg .errorexit

    ;parse str to tmp octet
    sub rcx, '0'
    imul rdx, 10
    add rdx, rcx
    jmp .loop
.store_octet:
    ;check that octet less than 255
    cmp rdx, 255
    jg .errorexit
    ;store octet
    shl rax, 8
    add rax, rdx  
    xor rdx, rdx
    jmp .loop
.errorexit: 
    mov rax, -1
    mov rsp, rbp
    pop rbp
    ret
.endloop:
    ;get last octet
    shl rax, 8
    add rax, rdx
    ;check if little endian
    test r11, r11
    jz .little_endian
.doneexit:
    mov rsp, rbp
    pop rbp
    ret
.little_endian:
    bswap eax
    jmp .doneexit


;STRCOMPARE(rdi, rdx) COMPARE TO STRINGS BY PTRS
;return rax 1 if queal
_STR_CMP:
    push rbp
    mov rbp, rsp
.loop:
    mov al, [rdi]
    mov bl, [rdx]
    cmp al, bl
    jne .not_equal
    test al, al
    jz .equal               ; оба байта нулевые — конец, строки равны
    inc rdi
    inc rdx
    jmp .loop
.equal:
    mov rax, 1
    mov rsp, rbp
    pop rbp
    ret
.not_equal:
    xor rax, rax
    mov rsp, rbp
    pop rbp
    ret


;SOME MACROSES
%macro print 2
    push rax
    push rdi
    push rsi
    push rdx

    mov  rax, 1
    mov  rdi, 1
    mov  rsi, %1
    mov  rdx, %2
    syscall

    pop  rdx
    pop  rsi
    pop  rdi
    pop  rax
%endmacro


%macro println 2
    print %1, %2
%endmacro


%macro toUpper 1
    push rcx
    push rax
    push rdi
    push rdx
    push r8

    xor rdx, rdx    ;symbol
    xor rcx, rcx    ;ctr
    mov rdi, %1     ;str_buf

    %%loop:
        mov bl, [rdi + rcx]
        cmp bl, 0xA
        je %%end_loop

        cmp bl, 'a'
        jb %%incr

        cmp bl, 'z'
        ja %%incr

        sub bl, 32
        mov [rdi + rcx], bl
        inc rcx
        jmp %%loop

        %%incr:
            inc rcx
            jmp %%loop
    %%end_loop:

    pop r8
    pop rdx
    pop rdi
    pop rax
    pop rcx
%endmacro

