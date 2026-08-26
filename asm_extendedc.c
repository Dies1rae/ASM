#include <stdio.h>


int abs(int x) {
    asm volatile (
        ".intel_syntax noprefix\n\t"
        "mov edx, %0\n\t"
        "sar edx, 31\n\t"
        "xor %0, edx\n\t"
        "sub %0, edx\n\t"
        ".att_syntax prefix\n\t"
        : "+r" (x)
        :                                    
        : "edx", "cc"
    );
    return x;
}


int main (void) {
    int x = 0;
    printf("Введите Х: ");
    scanf("%d", &x);
    
    printf("ABS Х = %d\n", abs(x));
    return 0;
}
