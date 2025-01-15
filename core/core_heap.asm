INCLUDE core_console.inc
INCLUDE core_heap.inc
INCLUDE core_macros.inc

PAGE_SIZE EQU 1000h

MEM_COMMIT EQU 1000h
MEM_RESERVE EQU 2000h
MEM_RELEASE EQU 8000h

PAGE_READWRITE EQU 4h

extern VirtualAlloc : proc
extern VirtualFree : proc

.data

g_heap_size qword 0
g_heap_leak_format_string byte "%zu not freed", 10, 0

.code

;
; Heap Initialize
;
heap_initialize proc

	; Reset heap size
	mov qword ptr [g_heap_size], 0

	ret

heap_initialize endp

;
; Heap Alloc
;
heap_alloc proc

	sub rsp, 28h ; Align stack to 16-byte boundary

	mov rbx, rcx ; Temporary to hold block size
	add rbx, SIZEOF qword ; Add block primitive size
	ALIGN_UP_REG rbx, PAGE_SIZE ; Align size up to the nearest page boundary

	xor rcx, rcx ; [ARG0] lpAddress
	mov rdx, rbx ; [ARG1] dwSize
	mov r8, MEM_COMMIT OR MEM_RESERVE ; [ARG2] flAllocationType
	mov r9, PAGE_READWRITE ; [ARG3] flProtect
	call VirtualAlloc

IFDEF DEBUG
	add g_heap_size, rbx ; Add block size to overall size
	mov qword ptr [rax], rbx ; Store block size in block
	add rax, SIZEOF qword ; Increment block past block size
ENDIF ; DEBUG

	add rsp, 28h ; Restore stack alignment
	ret

heap_alloc endp

;
; Heap Free
;
heap_free proc

	sub rsp, 28h ; Align stack to 16-byte boundary

IFDEF DEBUG
	mov rbx, qword ptr [rcx - SIZEOF qword] ; Temporary to hold block size
	sub g_heap_size, rbx ; Subtract block size from overall size
ENDIF ; DEBUG

	xor rdx, rdx ; [ARG1] dwSize
	mov r8, MEM_RELEASE ; [ARG2] dwFreeType
	call VirtualFree

	add rsp, 28h ; Restore stack alignment

	ret

heap_free endp

;
; Heap Validate
;
heap_validate proc

	; Function prologue
	push rbp
	mov rbp, rsp

	; Check heap size
	cmp g_heap_size, 0
	; jz no_leak_found

	; Print leaked byte count
	sub rsp, 30h ; Allocate shadow space and align stack
	lea rcx, g_heap_leak_format_string ; [ARG0] format
	; TODO
	lea rdx, g_heap_size ; [ARG1] arg0
	call console_log
	add rsp, 30h ; Restore stack

	; Function epilogue
	mov rsp, rbp
	pop rbp

no_leak_found:

	ret

heap_validate endp

end
