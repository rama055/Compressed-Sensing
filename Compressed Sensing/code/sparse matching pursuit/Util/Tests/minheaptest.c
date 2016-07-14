#include "../minheap.h"


void DisplayHeap(heap_t *heap)
{
    int i;
    for (i = 1; i <= heap->size; i++)
        printf("%lg ", heap->nodes[i].value);
    printf("\n");
}

void test1()
{
    int index;
    double value;
    heap_t heap;
    MinHeapCreate(&heap, 10);
    MinHeapAdd(&heap, 5, 5);
    DisplayHeap(&heap);
    MinHeapAdd(&heap, 2, 2);
    DisplayHeap(&heap);
    MinHeapAdd(&heap, 3, 3);
    DisplayHeap(&heap);
    MinHeapAdd(&heap, 1, 1);
    DisplayHeap(&heap);
    MinHeapAdd(&heap, 8, 8);
    DisplayHeap(&heap);

    MinHeapChangeValue(&heap, 8, 0.5);
    DisplayHeap(&heap);

    MinHeapChangeValue(&heap, 2, 10);
    DisplayHeap(&heap);
    while (MinHeapGetMin(&heap, &index, &value))
    {
        printf("%d %lg\n", index, value);
        MinHeapRemoveMin(&heap);
    }
    MinHeapDestroy(&heap);
}

void test_large(int N)
{
    heap_t h;
    int i, lastv, nr;
    int vals[N+1];
    double v;

    printf("Running large test N=%d\n", N);

    MinHeapCreate(&h, N);
    for (i = 1; i <= N; i++)
    {
        MinHeapAdd(&h, i, vals[i] = rand());
    }
    for (nr = 0; nr < N/2; nr++)
    {
        i = 1 + rand()%N;
        MinHeapChangeValue(&h, i, vals[i] = rand());
    }
    lastv = -1;
    for (nr = 0; nr < N; nr++)
    {
        if (MinHeapSize(&h) != N-nr)
            printf("Incorrect heap size %d, should be %d\n", MinHeapSize(&h), N+1-nr);

        MinHeapGetMin(&h, &i, &v);

        if ((int) v < lastv)
            printf("Minimums not increasing: %d after %d\n", (int) v, lastv);
        lastv = v;


        if (vals[i] != (int) v)
            printf("Incorrect value for %d: %d instead of %d\n", i, (int) v, vals[i]);

        MinHeapRemoveMin(&h);
    }
    MinHeapDestroy(&h);
}

void test_build(int N)
{
    heap_t h;
    int i, nr;
    double v, lastv, vals[N+1];

    printf("Running build test N=%d\n", N);

    MinHeapCreate(&h, N);
    for (i = 1; i <= N; i++)
        vals[i] = rand();
    MinHeapBuild(&h, N, vals);

    lastv = -1;
    for (nr = 0; nr < N; nr++)
    {
        if (MinHeapSize(&h) != N-nr)
            printf("Incorrect heap size %d, should be %d\n", MinHeapSize(&h), N+1-nr);

        MinHeapGetMin(&h, &i, &v);

        if ((int) v < lastv)
            printf("Minimums not increasing: %d after %d\n", (int) v, lastv);
        lastv = v;


        if (vals[i] != (int) v)
            printf("Incorrect value for %d: %d instead of %d\n", i, (int) v, vals[i]);

        MinHeapRemoveMin(&h);
    }
    MinHeapDestroy(&h);
}

      

int main()
{
    test1();
    test_large(10000);
    test_large(100000);
    test_large(1000000);
    test_build(100);
    test_build(10000);

    return 0;
}
