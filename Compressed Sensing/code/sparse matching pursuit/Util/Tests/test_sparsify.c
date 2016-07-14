#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "../sparsify.h"

int compare_abs(const void *aptr, const void *bptr)
{
    double a = fabs(*((double *) aptr));
    double b = fabs(*((double *) bptr));
    if (a == b) return 0;
    return a > b ? -1 : 1;
}

/*
 * Checks if A is the correct k-sparsified result for vector B.
 * Vector B should be sorted decreasingly by absolute value.
 * Vector A will be modified (sorted).
 */
void check_result(double *A, double *B, int N, int k)
{
    int i;
    qsort(A, N, sizeof(double), compare_abs);
    for (i = 0; i < k; i++)
        if (A[i] != B[i])
            printf("Comparison failed: i=%d, A[i]=%d, B[i]=%d\n", i, A[i], B[i]);
    for (i = k; i < N; i++)
        if (A[i] != 0)
            printf("A[%d] should be 0, is %d\n", i, A[i]);
}

void test(double *A, int N)
{
    double *B, *C;
    int k;
    B = (double *) malloc(N * sizeof(double));
    C = (double *) malloc(N * sizeof(double));

    memcpy(B, A, N * sizeof(double));
    qsort(B, N, sizeof(double), compare_abs);
    
    for (k = 0; k <= N; k++)
    {
        memcpy(C, A, N * sizeof(double));
        sparsify(C, N, k);
        check_result(C, B, N, k);
    }

    free(B);
    free(C);
}

void gen_random(double *A, int N, int delta)
{
    int i;
    for (i = 0; i < N; i++)
        A[i] = rand() % delta;
}

double A[1000];
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


    printf("Tests complete\n");

    return 0;
}
