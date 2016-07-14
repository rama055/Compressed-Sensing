/*
 * Routine that implements a fast median (countmin) recovery when the matrix is
 * countmin_implicit_twowise.
 *
 * Written by Radu Berinde, MIT, Jan. 2008
 */
#include <stdio.h>
#include <string.h>
#include "mex.h"
#include "matrix.h"
#include "randomized_select.h"

char* usage =
"Usage: x = median_recovery_implcit_twowise(N, M, D, B, Ps, As, Bs, y)\n"
"  N is the signal size, M is the sketch size.\n"
"  D is the degreee (number of neighbors of each element)\n"
"  B is the number of hashes (should be floor(M/D))\n"
"  Ps, As, Bs are the parameters of the hash functions\n"
"  y is the sketch of length M\n"
"\nReturns a vector x of size N so that x(i) is the median of y(neighbors(i))\n";


/*
 * Arguments: N, M, D, B, Ps, As, Bs, y 
 * Returns: x (recovered vector)
 */ 
void
mexFunction(int nlhs, mxArray *plhs[],
            int nrhs, const mxArray *prhs[])
{
    int N, M, D, B, i;
    const unsigned int *Ps, *As, *Bs;
    const double *y;
    double *x;
    int col;
    unsigned int vals[128];
    double bucket_values[128];

    if (nrhs != 8 && nlhs != 1)
        mexErrMsgTxt(usage);

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

    if (!mxIsDouble(prhs[7]) || mxIsComplex(prhs[7]) || mxGetNumberOfElements(prhs[7]) != M)
        mexErrMsgTxt("y must be a real vector of size M.");

    y = mxGetPr(prhs[7]);

    plhs[0] = mxCreateDoubleMatrix(N, 1, mxREAL);
    x = mxGetPr(plhs[0]);

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
        for (i = 0; i < D; i++)
        {
            int pos;
            vals[i] = (vals[i] + As[i]) % Ps[i];
            /* pos = (int) (((long long) As[i] * (col+1) + Bs[i]) % Ps[i] % B); */
            pos = vals[i] % B;
            bucket_values[i] = y[i*B + pos];
        }
        x[col] = randomized_select(bucket_values, D, (D+1)/2);  /* select median */
        if ((col+1) % 1000000 == 0)
            printf("%d columns complete.\n", col+1);
    }
}
