IFNDEF __CORE_HEAP

__CORE_HEAP EQU 1

;
; Global API
;

heap_initialize proto
heap_alloc proto block_size:qword
heap_free proto block:qword
heap_validate proto

ENDIF ; __CORE_HEAP
