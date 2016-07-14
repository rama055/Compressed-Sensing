/*
 * Implementation of a min heap.
 * Written by Radu Berinde, Feb 2008
 */

#ifndef MINHEAP_H
#define MINHEAP_H


#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>

typedef struct heap_node_t
{
    double  value;
    int     index;
} heap_node_t;

typedef struct heap_t
{
    int           size;
    int           capacity;
    /* The actual heap */
    heap_node_t   *nodes;
    /* Position in heap of each element (i.e. nodes[position[i]].index = i) */
    int           *position;
} heap_t;


void MinHeapCreate(heap_t *heap, int capacity)
{
    heap->size = 0;
    heap->capacity = capacity;
    heap->nodes = (heap_node_t *) calloc(capacity+1, sizeof(heap_node_t));
    heap->position = (int *) calloc(capacity+1, sizeof(int));
}

void MinHeapDestroy(heap_t *heap)
{
    free(heap->nodes);
    free(heap->position);
}

void MinHeapClear(heap_t *heap)
{
    heap->size = 0;
    memset(heap->position, 0, sizeof(int) * (heap->capacity+1));
}

int MinHeapSize(heap_t *heap)
{
    return heap->size;
}

void MinHeapSwap(heap_t *heap, int pos1, int pos2)
{
    heap_node_t temp, *nodes = heap->nodes;

    temp = nodes[pos1];
    nodes[pos1] = nodes[pos2];
    nodes[pos2] = temp;

    /* Update position indices */
    heap->position[nodes[pos1].index] = pos1;
    heap->position[nodes[pos2].index] = pos2;
}


void MinHeapSift(heap_t *heap, int pos)
{
    heap_node_t *nodes = heap->nodes;
    int i = pos, size = heap->size, minSon;

#define getMinSon ((2*i >= size || nodes[2*i].value < nodes[2*i+1].value) ? 2*i : 2*i+1)

    for (; i*2 <= size && nodes[minSon = getMinSon].value < nodes[i].value; i = minSon)
        MinHeapSwap(heap, i, minSon);

#undef getMinSon
}

void MinHeapPercolate(heap_t *heap, int pos)
{
    heap_node_t *nodes = heap->nodes;
    int i;

    for (i = pos; i > 1 && nodes[i].value < nodes[i/2].value; i /= 2)
        MinHeapSwap(heap, i, i/2);
}

/* Creates a heap of elements 1 to n with given values[1..n] */
void MinHeapBuild(heap_t *heap, int n, double *values)
{
    int i;
    assert(n <= heap->capacity);
    heap->size = n;
    for (i = 1; i <= n; i++)
    {
        heap->position[i] = i;
        heap->nodes[i].value = values[i];
        heap->nodes[i].index = i;
    }
    for (i = n/2; i >= 1; i--)
        MinHeapSift(heap, i);
}



/* Argument index can be any integer between 0 and heap capacity, as long as
 * there is no other node with this index already inserted */
void MinHeapAdd(heap_t *heap, int index, double value)
{
    assert(heap->size < heap->capacity);
    assert(index >= 0 && index <= heap->capacity);
    assert(heap->position[index] == 0);

    heap->size++;
    heap->nodes[heap->size].index = index;
    heap->nodes[heap->size].value = value;
    heap->position[index] = heap->size;
    MinHeapPercolate(heap, heap->size);
}

/* Peeks at the minimum element. Returns false if heap is empty. Does not
 * modify the heap */
int MinHeapGetMin(heap_t *heap, int *index, double *value)
{
    if (!heap->size)
        return 0;
    *index = heap->nodes[1].index;
    *value = heap->nodes[1].value;
    return 1;
}


void MinHeapRemoveMin(heap_t *heap)
{
    int index;
    assert(heap->size > 0);

    index = heap->nodes[1].index;

    MinHeapSwap(heap, 1, heap->size);
    heap->size--;
    heap->position[index] = 0;

    if (heap->size > 1)
        MinHeapSift(heap, 1);
}

/* Retrieves the value corresponding to a given index. Returns 0 if no element
 * with given index was found */
int MinHeapGetValue(heap_t *heap, int index, double *value)
{
    int pos;
    assert(index >= 0 && index <= heap->capacity);

    pos = heap->position[index];
    if (pos == 0)
        return 0;

    assert(pos >= 1 && pos <= heap->size);
    assert(heap->nodes[pos].index == index);

    *value = heap->nodes[pos].value;
    return 1;
}


void MinHeapChangeValue(heap_t *heap, int index, double value)
{
    double oldVal;
    int pos;

    assert(index >= 0 && index <= heap->capacity);

    pos = heap->position[index];
    assert(pos >= 1 && pos <= heap->size);
    assert(heap->nodes[pos].index == index);

    oldVal = heap->nodes[pos].value;
    heap->nodes[pos].value = value;
    if (value > oldVal)
        MinHeapSift(heap, pos);
    else
        MinHeapPercolate(heap, pos);
}

#endif  /* MINHEAP_H */

