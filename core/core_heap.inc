IFNDEF __CORE_HEAP

__CORE_HEAP EQU 1

;
; Global API
;

heap_initialize proto ; void(*)(void)
heap_alloc proto ; void*(*)(long long unsigned size)
heap_free proto ; void(*)(void* block)
heap_validate proto ; void(*)(void)

ENDIF ; __CORE_HEAP
