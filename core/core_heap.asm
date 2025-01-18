INCLUDE core_heap.inc
INCLUDE core_macros.inc

PAGE_SIZE EQU 1000h

MEM_COMMIT  EQU 1000h
MEM_RESERVE EQU 2000h
MEM_RELEASE EQU 8000h

PAGE_READWRITE EQU 4h

extern printf : proc

extern VirtualAlloc : proc
extern VirtualFree  : proc

.data

g_heap_size               qword 0
g_heap_leak_format_string byte  "%zu bytes not freed", 10, 0

.code

;
; Heap Initialize
;
heap_initialize proc

	FUNCTION_PROLOGUE

	; Reset heap size
	mov       g_heap_size, 0 ; Set allocated heap size back to 0

	FUNCTION_EPILOGUE

	ret

heap_initialize endp

;
; Heap Alloc
;
heap_alloc proc block_size:qword

	FUNCTION_PROLOGUE

	; Temporary variables
	mov       r12, rcx ; Temporary to hold block size

	; Compute number of bytes to allocate
	add       r12, SIZEOF qword ; Add block primitive size
	ALIGN_UR  r12, PAGE_SIZE    ; Align size up to the nearest page boundary

	; Alloc virtual block
	sub       rsp, 28h                      ; Allocate shadow space and align stack
	mov       r9, PAGE_READWRITE            ; [ARG3] flProtect
	mov       r8, MEM_COMMIT OR MEM_RESERVE ; [ARG2] flAllocationType
	mov       rdx, r12                      ; [ARG1] dwSize
	xor       rcx, rcx                      ; [ARG0] lpAddress
	call      VirtualAlloc                  ; Virtual alloc
	add       rsp, 28h                      ; Restore stack

IFDEF DEBUG

	; Store heap size
	add       g_heap_size, r12     ; Add block size to overall size
	mov       qword ptr [rax], r12 ; Store block size in block
	add       rax, SIZEOF qword    ; Increment block past block size

ENDIF ; DEBUG

	FUNCTION_EPILOGUE

	ret

heap_alloc endp

;
; Heap Free
;
heap_free proc block:qword

	FUNCTION_PROLOGUE

	; Temporary variables
	mov       r12, rcx                            ; Temporary to hold block
	mov       r13, qword ptr [r12 - SIZEOF qword] ; Temporary to hold block size

	; Free virtual block
	sub       rsp, 28h        ; Allocate shadow space and align stack
	mov       r8, MEM_RELEASE ; [ARG2] dwFreeType
	xor       rdx, rdx        ; [ARG1] dwSize
	mov       rcx, r12        ; [ARG0] lpAddress
	call      VirtualFree     ; Virtual free
	add       rsp, 28h        ; Restore stack

IFDEF DEBUG

	; Restore heap size
	sub       g_heap_size, r13 ; Subtract block size from overall size

ENDIF ; DEBUG

	FUNCTION_EPILOGUE

	ret

heap_free endp

;
; Heap Validate
;
heap_validate proc

	FUNCTION_PROLOGUE

	; Check heap size
	cmp       g_heap_size, 0 ; Compare allocated heap size
	je        no_leak_found  ; Jump to end if no leak was found

	; Print leaked byte count
	sub       rsp, 28h                       ; Allocate shadow space and align stack
	mov       rdx, g_heap_size               ; [ARG1] variadic
	lea       rcx, g_heap_leak_format_string ; [ARG0] format
	call      printf                         ; Print formatted
	add       rsp, 28h                       ; Restore stack

no_leak_found:

	FUNCTION_EPILOGUE

	ret

heap_validate endp

end
