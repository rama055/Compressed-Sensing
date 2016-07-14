/*
 * Routine that implements a faster implicit countmin matrix multiplication.
 *
 * Written by Radu Berinde, MIT, Jan. 2008
 */
#include <stdio.h>
#include <string.h>
#include "mex.h"
#include "matrix.h"

/* Arguments: N, M, D, B, Ps, As, Bs, x */
/* mexFunction is the gateway routine for the MEX-file. */ 
void
mexFunction(int nlhs, mxArray *plhs[],
            int nrhs, const mxArray *prhs[])
{
    int N, M, D, B, i;
    const unsigned int *Ps, *As, *Bs;
    const double *x;
    double *y;
    int col;
    unsigned int vals[128];

    if (nrhs != 8 && nlhs != 1)
        mexErrMsgTxt("Usage: y = countmin_implicit_twowise_mul(N, M, D, B, Ps, As, Bs, x)");

    for (i = 0; i < 4; i++)
        if (!mxIsDouble(prhs[i]) || mxIsComplex(prhs[i]) ||
            mxGetNumberOfElements(prhs[i]) != 1)
            mexErrMsgTxt("First four arguments should be real scalars.");

    N = (int) (mxGetScalar(prhs[0]) + 0.1);
    M = (int) (mxGetScalar(prhs[1]) + 0.1);
    D = (int) (mxGetScalar(prhs[2]) + 0.1);
    B = (int) (mxGetScalar(prhs[3]) + 0.1);

    if (B*D > M)
        mexErrMsgTxt("D*B should be at most M");

    if (D >= 128)
        mexErrMsgTxt("D should be less than 128");

    for (i = 4; i <= 6; i++)
        if (!mxIsClass(prhs[i], "uint32") || mxGetNumberOfElements(prhs[i]) != D)
            mexErrMsgTxt("Ps, As, Bs must be uint32 vectors of size D.");

    Ps = (const unsigned int *) mxGetData(prhs[4]);
    As = (const unsigned int *) mxGetData(prhs[5]);
    Bs = (const unsigned int *) mxGetData(prhs[6]);

    if (!mxIsDouble(prhs[7]) || mxIsComplex(prhs[7]) || mxGetNumberOfElements(prhs[7]) != N)
        mexErrMsgTxt("x must be a real vector of size N.");

    x = mxGetPr(prhs[7]);

    plhs[0] = mxCreateDoubleMatrix(M, 1, mxREAL);
    y = mxGetPr(plhs[0]);

    /* At each column we want to compute
         pos = (int) (((long long) As[i] * (col+1) + Bs[i]) % Ps[i] % B);

       To speed this up, we mainain the (((long long) As[i] * (col+1) + Bs[i]) %
       Ps[i] terms, and just add As[i] at each step.
     */
    for (i = 0; i < D; i++) 
    {
        vals[i] = Bs[i];
        /* Impose a 2 billion limit on the P primes, so we won't overflow. */
        if (Ps[i] > 2000000000)
            mexErrMsgTxt("Ps should be less than 2 billion.");
    }

    for (col = 0; col < N; col++)
    {
        double val = x[col];
        if (val > -1e-10 && val < 1e-10)
        {
            /* Update vals */
            for (i = 0; i < D; i++)
                vals[i] = (vals[i] + As[i]) % Ps[i];
            continue;  /* zero vector entry */
        }
        for (i = 0; i < D; i++)
        {
            int pos;
            vals[i] = (vals[i] + As[i]) % Ps[i];
            /* pos = (int) (((long long) As[i] * (col+1) + Bs[i]) % Ps[i] % B); */
            pos = vals[i] % B;
            y[i*B + pos] += val;
        }
    }
}
