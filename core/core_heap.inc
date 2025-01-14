IFNDEF __CORE_HEAP

__CORE_HEAP EQU 1

heap_alloc proto ; void*(*)(long long unsigned size)
heap_free proto ; void(*)(void* block)

ENDIF ; __CORE_HEAP
