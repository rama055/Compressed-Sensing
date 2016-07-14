#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "../randomized_select.h"

int compare(const void *aptr, const void *bptr)
{
    double a = *((double *) aptr);
    double b = *((double *) bptr);
    if (a == b) return 0;
    return a < b ? -1 : 1;
}

void test(double *A, int N)
{
    int i;
    double *B;

    B = (double *) malloc(N * sizeof(double));
    memcpy(B, A, N * sizeof(double));
    qsort(B, N, sizeof(double), compare);
    
    for (i = 0; i < N; i++) 
    {
        double val = randomized_select(A, N, i+1);
        if (B[i] != val)
            printf("Error: %d-th element is %lg, should be %lg\n", i+1, val, B[i]);
    }

    free(B);
}

void gen_random(double *A, int N, int delta)
{
    int i;
    for (i = 0; i < N; i++)
        A[i] = rand() % delta;
}

double A[10000];
int N;
int main()
{
    gen_random(A, 4, 10);
    test(A, 4);

    gen_random(A, 4, 2);
    test(A, 4);

    gen_random(A, 10, 100);
    test(A, 10);

    gen_random(A, 10, 10);
    test(A, 10);

    gen_random(A, 10, 2);
    test(A, 10);

    gen_random(A, 1000, 100000);
    test(A, 1000);

    gen_random(A, 1000, 1000);
    test(A, 1000);

    gen_random(A, 1000, 100);
    test(A, 1000);

    gen_random(A, 1000, 10);
    test(A, 1000);

    gen_random(A, 10000, 1000);
    test(A, 10000);

    gen_random(A, 10000, 1);
    test(A, 10000);

    printf("Tests complete\n");

    return 0;
}
