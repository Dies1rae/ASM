# ASM STUDY REPO
# SOME ALGOS, MACROS, AND BASIC SOFTWARE FOR STUDIES


# NOTES:

*To check last byte from memory buffer after stdin read:
Lets suppose 0x4020e8 buffer memory addr(ptr to readed data) and readed len in rax\eax after syscall 0
we need just to compare buffer addres - 1 byte + readed len like: cmp BYTE PTR [eax+0x4020e7],0xa

*Faster zeroing:
xor reg, reg and sub reg, reg is faster than mov reg, 0
This:
sub reg, reg / 3 byte
not reg /3 byte
Faster than mov reg, -1 / 10 byte

*Fast strlen inplace:
mov    edi,0x4020e8                 / get ptr to readed buffer
sub    ecx,ecx                      / zeroing len ctr
sub    al,al                        / zeroing what we are find(find last 0 character of C string)
not    ecx                          / reverse ecx to -1 (all bits are 1 with sign bit)
cld                                 / clear direction flags for repnz scas
repnz scas al,BYTE PTR es:[rdi]     / repeat not zero(flag) command scan string by byte al(0) and byte from ptr RDI copied to es reg
not    ecx                          / after scan and count bytes in rcx\ecx reverse it, and zeroing sign bit(if scas count -5 than it will be 4)
dec    ecx                          / set rcx/ex - 1 to remove last \n

*Check Fravias book "The Art of Searching"
