global array_sum, array_min, array_max, array_scale
;C ABI, args in rdi, rsi, rdx, rcx, r8, r9.
;Function names in global section
;rax result


section .text
;rdi ptr to array, rsi len, rax result
array_sum:
    push rbp
    mov rbp, rsp
    xor rax, rax
    xor rcx, rcx

    cmp rsi, 0
    jle .done
    
.loop:
    cmp rcx, rsi
    jge .done

    add rax, [rdi + (8*rcx)]
    inc rcx
    jmp .loop
.done:
    leave
    ret


;rdi ptr to array, rsi len, rax result
array_min:
    push rbp
    mov rbp, rsp
    xor rax, rax
    xor rcx, rcx

    cmp rsi, 0
    jle .done

    mov rax, [rdi]
.loop:
    cmp rcx, rsi
    jge .done

    cmp rax, [rdi + (8*rcx)]
    jg .chng_min
    inc rcx
    jmp .loop
.chng_min:
    mov rax, [rdi + (8*rcx)]
    inc rcx
    jmp .loop

.done:
    leave
    ret


;rdi ptr to array, rsi len, rax result
array_max:
    push rbp
    mov rbp, rsp
    xor rax, rax 
    xor rcx, rcx

    cmp rsi, 0
    jle .done

    mov rax, [rdi]
.loop:
    cmp rcx, rsi
    jge .done

    cmp rax, [rdi + (8*rcx)]
    jl .chng_max
    inc rcx
    jmp .loop
.chng_max:
    mov rax, [rdi + (8*rcx)]
    inc rcx
    jmp .loop
.done:
    leave
    ret


;rdi ptr to array, rsi len, rdx scaler, rax result 0 is good, other if something bad
array_scale:
    push rbp
    mov rbp, rsp
    xor rax, rax
    xor rcx, rcx
    cmp rsi, 0
    jle .done_err

.loop:
    cmp rcx, rsi
    jge .done
    mov  rax, [rdi + (8*rcx)]
    imul rax, rdx
    mov [rdi + (8*rcx)], rax
    inc rcx
    jmp .loop
.done:
    xor rax, rax
    leave
    ret
.done_err:
    mov rax, -1
    leave
    ret


