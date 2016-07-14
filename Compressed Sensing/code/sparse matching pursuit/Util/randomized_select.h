/*
 * Randomized selection routine (expected linear time).
 * 
 * Written by: Radu Berinde
 */

#ifndef RANDOMIZED_SELECT_H
#define RANDOMIZED_SELECT_H

/*
 * Selects the k-th smallest element from the vector
 * A with N elements. k should be between 1 and N.
 * Modifies (scrambles) the vector!
 */
double randomized_select(double *A, int N, int k)
{
    int j, left, right;
    double midval;

    if (N == 1)
        return A[0];

    midval = A[rand() % N];

    /*
     * We partition the array in the following way:
     *   [0..left)     -- all values < midVal
     *   [left, right) -- all values > midVal (or yet unprocessed values)
     *   [right, N)    -- all values = midVal
     */
    left = 0, right = N;

    for (j = 0; j < right; j++)
    {
        double val = A[j];
        if (val < midval)
        {
            A[j] = A[left];
            A[left++] = val;
        }
        else
            if (val == midval)
            {
                A[j] = A[--right];
                A[right] = val;
                j--;
            }
    }

    /*
    for (j = 0; j < N; j++)
        printf("%lg ", A[j]);
    printf("\nmidVal: %lg left:%d right:%d N:%d k=%d\n", midval, left, right, N, k);
    */

    /* left elements are smaller than midval */
    if (k <= left)
        return randomized_select(A, left, k);
    /* The (left+1)-th to (left+(N-right))-th elements are all equal to midval */
    if (k <= left + (N - right))
        return midval;
    return randomized_select(A + left, right - left, k - left - (N - right));
}

#endif
