#include "../absvalheap.h"

void DisplayHeap(heap_t *heap)
{
    int i;
    for (i = 1; i <= heap->size; i++)
        printf("%lg ", heap->nodes[i].value);
    printf("\n");
}

int main()
{
    int index;
    double value;
    abs_val_heap_t heap;
    AbsValHeapCreate(&heap, 10, 1);
    AbsValHeapAdd(&heap, 5, -5);
    DisplayHeap(&heap.heap);
    AbsValHeapAdd(&heap, 2, 2);
    DisplayHeap(&heap.heap);
    AbsValHeapAdd(&heap, 3, -3);
    DisplayHeap(&heap.heap);
    AbsValHeapAdd(&heap, 1, 1);
    DisplayHeap(&heap.heap);
    AbsValHeapAdd(&heap, 8, -8);
    DisplayHeap(&heap.heap);

    AbsValHeapAddToValue(&heap, 8, 0.5);
    DisplayHeap(&heap.heap);

    AbsValHeapAddToValue(&heap, 1, -0.5);
    DisplayHeap(&heap.heap);

    AbsValHeapAddToValue(&heap, 2, 10);
    DisplayHeap(&heap.heap);
    while (AbsValHeapGetTop(&heap, &index, &value))
    {
        printf("%d %lg\n", index, value);
        AbsValHeapRemoveTop(&heap);
    }

    {
        double values[11] = {0, 1, 2, -1, 4, -5, -8, -10, 3, -15, 0};
        AbsValHeapBuild(&heap, 10, values);
        DisplayHeap(&heap.heap);
    }

    return 0;
}
