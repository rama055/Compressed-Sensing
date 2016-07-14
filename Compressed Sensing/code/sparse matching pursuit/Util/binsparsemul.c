/*
 * Routine that implements a faster sparse matrix (with vector) multiplication
 * for the special case when the sparse matrix is binary.
 *
 * Written by Radu Berinde, MIT, Jan. 2008
 */
#include <stdio.h>
#include <string.h>
#include "mex.h"
#include "matrix.h"


/* mexFunction is the gateway routine for the MEX-file. */ 
void
mexFunction(int nlhs, mxArray *plhs[],
            int nrhs, const mxArray *prhs[])
{
    const mxArray *A, *x;
    size_t *ir, *jc;
    int col, N, M;
    double *xv, *y;

    if (nlhs != 1 || nrhs != 2 || !mxIsSparse(prhs[0]) || !mxIsDouble (prhs[1]) || mxIsComplex (prhs[1]))
       mexErrMsgTxt ("Usage: y = binsparsemul(A, x), where A is a sparse matrix and x is a real vector\n");

    A = prhs[0];
    x = prhs[1];
    N = mxGetN(A);
    M = mxGetM(A);

    {
        int ndims = mxGetNumberOfDimensions (x);
        const size_t *dims = mxGetDimensions (x);
        if (ndims != 2 || dims[1] != 1 || dims[0] != N)
            mexErrMsgTxt ("The second argument must be a column vector; inner sizes must agree.\n");
    }

    plhs[0] = mxCreateDoubleMatrix(M, 1, mxREAL);

    xv = mxGetPr(x);
    y = mxGetPr(plhs[0]);

    ir = mxGetIr(A);
    jc = mxGetJc(A);

    for (col = 0; col < N; col++)
    { 
        int i = jc[col]; 
        int iend = jc[col+1]; 
        double v;

        if (i == iend)
            continue;  /* empty column */
        v = xv[col];
        if (v > -1e-10 && v < 1e-10)
            continue;  /* zero vector entry */
        for (; i < iend; i++)
            y[ir[i]] += v;
    }
}

