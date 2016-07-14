/*
 * Routine that implements SSMP.
 *
 * Written by Radu Berinde, MIT, 2009
 */

/* #undef NDEBUG */

#include <stdio.h>
#include <string.h>
#include <assert.h>
#include "mex.h"
#include "matrix.h"
#include "randomized_select.h"
#include "absvalheap.h"
#include "sparsify.h"
#include "mexutil.h"



int N, M, D, B;
const unsigned int *Neighbors;

double *X;

/* Neighbors of the left (signal) nodes: i is between 1 and N, j is between 0
 * and D-1 */
#define LeftNeighbor(i, j) (Neighbors[(i) - 1 + N * (j)])

/* Neigbbors of the right (sketch) nodes */
int **RightNeighbor, *RightDegree;

/* C is the difference between Y and the sketch of the current recovery, 
 * C = Y - A*X */
double *C;

/* We maintain the current count-median recovery of (A*X-b) as a max abs-val
 * heap */
abs_val_heap_t Uheap;


void ComputeRightNeighbors()
{
    int i, j;
    RightDegree = (int *) calloc(M+1, sizeof(int));
    for (i = 1; i <= N; i++)
        for (j = 0; j < D; j++)
            RightDegree[LeftNeighbor(i, j)]++;
    RightNeighbor = (int **) calloc(M+1, sizeof(int *));

    for (i = 1; i <= M; i++)
    {
        RightNeighbor[i] = (int *) calloc(RightDegree[i], sizeof(int));
        RightDegree[i] = 0;
    }
    for (i = 1; i <= N; i++)
        for (j = 0; j < D; j++)
        {
            int k = LeftNeighbor(i, j);
            RightNeighbor[k][RightDegree[k]++] = i;
        }
}

void FreeRightNeighbors()
{
    int i;
    for (i = 1; i <= M; i++)
        free(RightNeighbor[i]);
    free(RightNeighbor);
    free(RightDegree);
}

double ComputeMedian(int i)
{
    int j;
    double bucket_values[128];
    for (j = 0; j < D; j++)
        bucket_values[j] = C[LeftNeighbor(i, j)];
    return randomized_select(bucket_values, D, (D+1)/2);  /* select median */
}

void ComputeHeap()
{
    int i;
    double *values;

    values = (double *) calloc(N+1, sizeof(double));
    for (i = 1; i <= N; i++)
        values[i] = ComputeMedian(i);

    AbsValHeapBuild(&Uheap, N, values);

    free(values);
}

/* Recompute the Uheap values of the neighbors of right node k */
void UpdateUHeap(int k)
{
    int i, j;
    for (j = 0; j < RightDegree[k]; j++)
    {
        i = RightNeighbor[k][j];
        AbsValHeapChangeValue(&Uheap, i, ComputeMedian(i));
    }
}

/* Main code: do a step of the algorithm */
void Step()
{
    int i, j, ret;
    double value;

    /* Get the element with the largest median estimation (in absolute value) */
    ret = AbsValHeapGetTop(&Uheap, &i, &value);
    assert(ret);

    X[i-1] += value;

    for (j = 0; j < D; j++)
        C[LeftNeighbor(i, j)] -= value;


    for (j = 0; j < D; j++)
        UpdateUHeap(LeftNeighbor(i, j));
}



char* usage =
"Usage: x = smp_queue(N, M, D, neighbors, y, inner_steps, outer_steps, sparsity)\n";

void
mexFunction(int nlhs, mxArray *plhs[],
            int nrhs, const mxArray *prhs[])
{
    int i, j;
    double *x;
    const double *y;
    int inner_steps, outer_steps, sparsity;
    int in_step, out_step;

    if (nrhs != 8 || nlhs != 1)
        mexErrMsgTxt(usage);

    for (i = 0; i < 3; i++)
        if (!mxIsDouble(prhs[i]) || mxIsComplex(prhs[i]) ||
            mxGetNumberOfElements(prhs[i]) != 1)
            mexErrMsgTxt("First three arguments should be real scalars.");

    N = (int) (mxGetScalar(prhs[0]) + 0.1);
    M = (int) (mxGetScalar(prhs[1]) + 0.1);
    D = (int) (mxGetScalar(prhs[2]) + 0.1);

    inner_steps = (int) (mxGetScalar(prhs[5]) + 0.1);
    outer_steps = (int) (mxGetScalar(prhs[6]) + 0.1);
    sparsity = (int) (mxGetScalar(prhs[7]) + 0.1);


    if (D >= 128)
        mexErrMsgTxt("D should be less than 128");

    if (!mxIsClass(prhs[3], "uint32") || mxGetNumberOfElements(prhs[3]) != N*D)
        mexErrMsgTxt("neighbors must be a uint32 NxD matrix.");

    Neighbors = (const unsigned int *) mxGetPr(prhs[3]);

    ComputeRightNeighbors();

    if (!mxIsDouble(prhs[4]) || mxIsComplex(prhs[4]) || mxGetNumberOfElements(prhs[4]) != M)
        mexErrMsgTxt("y must be a real vector of size M.");

    y = mxGetPr(prhs[4]);

    C = (double *) calloc(M+1, sizeof(double));

    for (i = 1; i <= M; i++)
        C[i] = y[i-1];

    plhs[0] = mxCreateDoubleMatrix(N, 1, mxREAL);
    X = mxGetPr(plhs[0]);
    for (i = 0; i < N; i++) X[i] = 0;

    AbsValHeapCreate(&Uheap, N, 0);
    ComputeHeap();

    mexPrintf("Performing queued SMP: %d inner steps, %d outer steps, %d sparsity\n",
              inner_steps, outer_steps, sparsity);
    
    for (out_step = 1; out_step <= outer_steps; out_step++)
    {
        mexPrintf("Outer step %d out of %d..\n", out_step, outer_steps);
        MatlabDrawNow();

        for (in_step = 1; in_step <= inner_steps; in_step++)
            Step();

        if (sparsity > 0)
        {
            sparsify(X, N, sparsity);

            /* Recompute C = Y - A*X*/

            for (i = 1; i <= M; i++)
                C[i] = y[i-1];

            for (i = 1; i <= N; i++)
                for (j = 0; j < D; j++)
                    C[LeftNeighbor(i,j)] -= X[i-1];

            ComputeHeap();
        }
    }

    free(C);
    AbsValHeapDestroy(&Uheap);
    FreeRightNeighbors();
}
