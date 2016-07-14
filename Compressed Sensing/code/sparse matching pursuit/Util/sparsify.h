/*
 * Routine that "sparsifies" a vector (keeps the highest elements).
 *
 * Written by: Radu Berinde
 */

#ifndef SPARSIFY_H
#define SPARISFY_H

#include <math.h>
#include <stdio.h>
#include "randomized_select.h"

/*
 * Zero out all but the largest (in absolute value) K elements of the given vector.
 * If there are ties, relevant elements are zeroed out left-to-right.
 */
void sparsify(double *z, int N, int K)
{
    int i, num;
    double val;
    double *temp;

    if (K == N)
        return;
    
    if (K == 0)
    {
        memset(z, 0, N * sizeof(double));
        return;
    }

    temp = (double *) malloc(N * sizeof(double));

    for (i = 0; i < N; i++)
        temp[i] = fabs(z[i]);
    val = randomized_select(temp, N, N-K+1);
    for (i = num = 0; i < N; i++)
        if (fabs(z[i]) < val)
            z[i] = 0;
        else
            num++;

    /* There may be more elements equal to val, so num might be > K. Remove some of those elements */
    for (i = 0; num > K && i < N; i++)
        if (fabs(z[i]) == val)
            z[i] = 0, num--;

    if (num > K)
        printf("WARNING: sparsify failed (bug?)\n");

    free(temp);
}

#endif
