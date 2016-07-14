/*
 * Implementation of an absolute value min/max heap.
 * The internal heap stores absolute values
 * Written by Radu Berinde, Feb 2008
 */
#ifndef ABSVALHEAP_H
#define ABSVALHEAP_H

#include <assert.h>
#include "minheap.h"

typedef struct abs_val_heap_t
{
    /* The internal heap stores the absolute values for minheaps, or the
     * absolute values NEGATED for maxheaps. */
    heap_t heap;
    /* Signs are used to store/recover the true signs. */
    char *signs;
    char globalSign;
} abs_val_heap_t;

/*
 * minHeap is non-zero for a min heap (extracts elemnt with minimum absolute
 * value); zero for a max heap (extract element with maximum absolute value)
 */
void AbsValHeapCreate(abs_val_heap_t *ah, int capacity, int minHeap)
{
    MinHeapCreate(&ah->heap, capacity);
    ah->signs = (char *) calloc((capacity + 1), sizeof(char));

    ah->globalSign = minHeap ? +1 : -1;
}

void AbsValHeapClear(abs_val_heap_t *ah)
{
    MinHeapClear(&ah->heap);
}

void AbsValHeapDestroy(abs_val_heap_t *ah)
{
    MinHeapDestroy(&ah->heap);
    free(ah->signs);
}

int AbsValHeapSize(abs_val_heap_t *ah)
{
    return MinHeapSize(&ah->heap);
}

/* Creates a heap of elements 1 to n with given values[1..n]. 
 * Note: modifies values[1..n] (to absolute values) */
void AbsValHeapBuild(abs_val_heap_t *ah, int n, double *values)
{
    int i;
    assert(n <= ah->heap.capacity);
    for (i = 1; i <= n; i++)
    {
        ah->signs[i] = (values[i] >= 0) ? +1 : -1;
        if (values[i] < 0) values[i] = -values[i];
        values[i] *= ah->globalSign;
    }
    MinHeapBuild(&ah->heap, n, values);
}


/* Argument index can be any integer between 0 and heap capacity, as long as
 * there is no other node with this index already inserted */
void AbsValHeapAdd(abs_val_heap_t *ah, int index, double value)
{
    assert(index >= 0 && index <= ah->heap.capacity);

    ah->signs[index] = (value >= 0) ? +1 : -1;
    if (value < 0) value = -value;

    MinHeapAdd(&ah->heap, index, value * ah->globalSign);
}

/* Retrieves the index and value of the top element */
int AbsValHeapGetTop(abs_val_heap_t *ah, int *index, double *value)
{
    if (!MinHeapGetMin(&ah->heap, index, value))
        return 0;
    (*value) *= ah->globalSign * ah->signs[*index];
    return 1;
}

/* Removes the top element from the heap */
void AbsValHeapRemoveTop(abs_val_heap_t *ah)
{
    MinHeapRemoveMin(&ah->heap);
}

/* Returns 0 if no element with given index exists in the heap */
int AbsValHeapGetValue(abs_val_heap_t *ah, int index, double *value)
{
    if (!MinHeapGetValue(&ah->heap, index, value))
        return 0;
    (*value) *= ah->globalSign * ah->signs[index];
    return 1;
}

void AbsValHeapChangeValue(abs_val_heap_t *ah, int index, double value)
{
    assert(index >= 0 && index <= ah->heap.capacity);
    ah->signs[index] = (value >= 0) ? +1 : -1;
    if (value < 0) value = -value;

    MinHeapChangeValue(&ah->heap, index, value * ah->globalSign);
}

/* Adds a number to the value of a given index. If index is not in heap, it is
 * added with initial value delta */
void AbsValHeapAddToValue(abs_val_heap_t *ah, int index, double delta)
{
    double value;
    assert(index >= 0 && index <= ah->heap.capacity);
    if (!AbsValHeapGetValue(ah, index, &value))
    {
        AbsValHeapAdd(ah, index, delta);
        return;
    }
    AbsValHeapChangeValue(ah, index, value + delta);
}



#endif  /* ABSVALHEAP_H */

