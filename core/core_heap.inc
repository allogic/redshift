IFNDEF __CORE_HEAP

__CORE_HEAP EQU 1

; #################################################################
; ### Global API
; #################################################################

heap_initialize PROTO
heap_alloc PROTO
heap_free PROTO
heap_validate PROTO

ENDIF ; __CORE_HEAP
