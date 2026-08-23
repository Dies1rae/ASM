# ASM STUDY REPO
# SOME ALGOS, MACROS, AND BASIC SOFTWARE FOR STUDIES


# NOTES:

*To check last byte from memory buffer after stdin read:</br>
Lets suppose 0x4020e8 buffer memory addr(ptr to readed data) and readed len in rax\eax after syscall 0</br>
we need just to compare buffer addres - 1 byte + readed len like: cmp BYTE PTR [eax+0x4020e7],0xa</br>

*Faster zeroing:</br>
xor reg, reg and sub reg, reg is faster than mov reg, 0</br>
This:</br>
sub reg, reg / 3 byte</br>
not reg /3 byte</br>
Faster than mov reg, -1 / 10 byte</br>

*Fast strlen inplace:</br>
mov    edi,0x4020e8                 / get ptr to readed buffer</br>
sub    ecx,ecx                      / zeroing len ctr</br>
sub    al,al                        / zeroing what we are find(find last 0 character of C string)</br>
not    ecx                          / reverse ecx to -1 (all bits are 1 with sign bit)</br>
cld                                 / clear direction flags for repnz scas</br>
repnz scas al,BYTE PTR es:[rdi]     / repeat not zero(flag) command scan string by byte al(0) and byte from ptr RDI copied to es reg</br>
not    ecx                          / after scan and count bytes in rcx\ecx reverse it, and zeroing sign bit(if scas count -5 than it will be 4)</br>
dec    ecx                          / set rcx/ex - 1 to remove last \n</br>

*Check Fravias book "The Art of Searching"</br>
