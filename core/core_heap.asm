INCLUDE core_common_macros.inc
INCLUDE core_crt_api.inc
INCLUDE core_heap.inc
INCLUDE core_tracy_api.inc
INCLUDE core_win32_api.inc

.data

ALIGN 4h
g_heap_size qword 0

ALIGN 4h
g_leak_format_string byte "%zu bytes not freed", 10, 0

.code

; #################################################################
; ### Heap Initialize
; #################################################################

BEGIN_FUNCTION_DEFINITION heap_initialize, "heap_initialize"

	; Reset heap size
	mov       g_heap_size, 0 ; Set allocated heap size back to 0

END_FUNCTION_DEFINITION heap_initialize

; #################################################################
; ### Heap Alloc
; #################################################################

BEGIN_FUNCTION_DEFINITION heap_alloc, "heap_alloc"

	mov       r12, rcx ; Store block size into temporary

	; Compute number of bytes to allocate
	add       r12, SIZEOF qword ; Add block primitive size
	ALIGN_UR  r12, PAGE_SIZE    ; Align size up to the nearest page boundary

	; Alloc virtual block
	mov       r9, PAGE_READWRITE            ; [ARG3] flProtect
	mov       r8, MEM_COMMIT OR MEM_RESERVE ; [ARG2] flAllocationType
	mov       rdx, r12                      ; [ARG1] dwSize
	xor       rcx, rcx                      ; [ARG0] lpAddress
	sub       rsp, 20h                      ; Allocate shadow space and align stack
	call      VirtualAlloc                  ; Virtual alloc
	add       rsp, 20h                      ; Restore stack

IFDEF __DEBUG

	; Update overall heap size and store block size into block
	add       g_heap_size, r12     ; Add block size to overall size
	mov       qword ptr [rax], r12 ; Store block size in block
	add       rax, SIZEOF qword    ; Increment block past block size

ENDIF ; __DEBUG

END_FUNCTION_DEFINITION heap_alloc

; #################################################################
; ### Heap Free
; #################################################################

BEGIN_FUNCTION_DEFINITION heap_free, "heap_free"

	mov       r12, rcx ; Store block into temporary

IFDEF __DEBUG

	mov       r13, qword ptr [r12 - SIZEOF qword] ; Store block size into temporary

ENDIF ; __DEBUG

	; Free virtual block
	mov       r8, MEM_RELEASE ; [ARG2] dwFreeType
	xor       rdx, rdx        ; [ARG1] dwSize
	mov       rcx, r12        ; [ARG0] lpAddress
	sub       rsp, 20h        ; Allocate shadow space and align stack
	call      VirtualFree     ; Virtual free
	add       rsp, 20h        ; Restore stack

IFDEF __DEBUG

	sub       g_heap_size, r13 ; Restore heap size

ENDIF ; __DEBUG

END_FUNCTION_DEFINITION heap_free

; #################################################################
; ### Heap Validate
; #################################################################

BEGIN_FUNCTION_DEFINITION heap_validate, "heap_validate"

	; Check heap size
	cmp       g_heap_size, 0 ; Compare allocated heap size
	je        no_leak_found  ; Jump to end if no leak was found

	; Print leaked byte count
	mov       rdx, g_heap_size          ; [ARG1] variadic
	lea       rcx, g_leak_format_string ; [ARG0] format
	sub       rsp, 20h                  ; Allocate shadow space and align stack
	call      printf                    ; Print formatted
	add       rsp, 20h                  ; Restore stack

no_leak_found:

END_FUNCTION_DEFINITION heap_validate

end
