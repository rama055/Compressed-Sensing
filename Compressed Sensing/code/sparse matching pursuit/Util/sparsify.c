/*
 * "Sparsifies" a vector - retains the largest (in absolute value) k elements
 * and zeroes out everything else.
 *
 * Usage: res = sparsify(vector, k)
 *
 * Written by Radu Berinde, MIT
 */
#include <stdio.h>
#include <string.h>
#include "mex.h"
#include "matrix.h"
#include "sparsify.h"

/* Arguments: vector, k */
/* Returns: resulting vector */
void
mexFunction(int nlhs, mxArray *plhs[],
            int nrhs, const mxArray *prhs[])
{
    int N, K;
    const double *A;
    double *result;

    if (nrhs != 2 && nlhs != 1)
        mexErrMsgTxt("Usage: res = sparsify(vector, k)");

    if (!mxIsDouble(prhs[0]) || mxIsComplex(prhs[0]))
        mexErrMsgTxt("First argument must be a real vector.");

    A = (const double *) mxGetData(prhs[0]);
    N = mxGetNumberOfElements(prhs[0]);


    if (!mxIsDouble(prhs[1]) || mxIsComplex(prhs[1]) ||
        mxGetNumberOfElements(prhs[1]) != 1)
        mexErrMsgTxt("Second arguments should be real scalar.");

    K = (int) (mxGetScalar(prhs[1]) + 0.1);

    if (K < 0 || K > N)
        mexErrMsgTxt("k should be between 0 and the length of the vector.\n");

    plhs[0] = mxCreateDoubleMatrix(N, 1, mxREAL);
    result = mxGetPr(plhs[0]);

    memcpy(result, A, N * sizeof(double));

    sparsify(result, N, K);
}
