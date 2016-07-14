/*
 * Routine that implements a fast median (Count-Min) recovery; the neighbours of
 * each element are given explicitly.
 *
 * Written by Radu Berinde, MIT, Jan. 2008
 */
#include <stdio.h>
#include <string.h>
#include "mex.h"
#include "matrix.h"
#include "randomized_select.h"

char* usage =
"Usage: x = median_recovery_explicit(N, M, D, neighbors, y)\n"
"  N is the signal size, M is the sketch size.\n"
"  D is the degreee (number of neighbors of each element)\n"
"  neighbors is an N by D uint32 matrix with the D neighbors of each element (numbers between 1 and M)\n"
"  y is the sketch (of length M).\n"
"\nReturns a vector x of size N so that x(i) is the median of y(neighbors(i))\n";

void
mexFunction(int nlhs, mxArray *plhs[],
            int nrhs, const mxArray *prhs[])
{
    int N, M, D, B, i, j;
    const unsigned int *neighbors;
    const double *y;
    double *x;
    double bucket_values[128];

    if (nrhs != 5 && nlhs != 1)
        mexErrMsgTxt(usage);

    for (i = 0; i < 3; i++)
        if (!mxIsDouble(prhs[i]) || mxIsComplex(prhs[i]) ||
            mxGetNumberOfElements(prhs[i]) != 1)
            mexErrMsgTxt("First three arguments should be real scalars.");

    N = (int) (mxGetScalar(prhs[0]) + 0.1);
    M = (int) (mxGetScalar(prhs[1]) + 0.1);
    D = (int) (mxGetScalar(prhs[2]) + 0.1);

    if (D >= 128)
        mexErrMsgTxt("D should be less than 128");

    if (!mxIsClass(prhs[3], "uint32") || mxGetNumberOfElements(prhs[3]) != N*D)
        mexErrMsgTxt("neighbors must be a uint32 NxD matrix.");

    neighbors = (const unsigned int *) mxGetPr(prhs[3]);

    if (!mxIsDouble(prhs[4]) || mxIsComplex(prhs[4]) || mxGetNumberOfElements(prhs[4]) != M)
        mexErrMsgTxt("y must be a real vector of size M.");

    y = mxGetPr(prhs[4]);

    plhs[0] = mxCreateDoubleMatrix(N, 1, mxREAL);
    x = mxGetPr(plhs[0]);

    for (i = 0; i < N; i++)
    {
        for (j = 0; j < D; j++)
        {
            int pos = neighbors[i + N * j] - 1;
            bucket_values[j] = y[pos];
        }
        x[i] = randomized_select(bucket_values, D, (D+1)/2);  /* select median */
        if ((i+1) % 1000000 == 0)
            printf("%d columns complete.\n", i+1);
    }
}
