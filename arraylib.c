#include <stdio.h>

long array_sum(long *arr, int n);
long array_min(long *arr, int n);
long array_max(long *arr, int n);
void array_scale(long *arr, int n, long k);


int main(void) {
    long data[] = {5, -2, 10, 7, 1};
    int n = 5;
    printf("before scale:");
    for (int i = 0; i < n; ++i) {
        printf(" %ld", data[i]);
    }
    printf("\n");

    printf("sum = %ld\n", array_sum(data, n));
    printf("min = %ld\n", array_min(data, n));
    printf("max = %ld\n", array_max(data, n));

    array_scale(data, n, 3);

    printf("after scale:");
    for (int i = 0; i < n; ++i) {
        printf(" %ld", data[i]);
    }
    printf("\n");

    return 0;
}
