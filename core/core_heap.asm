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

g_heap_size qword ?
g_heap_leak_format_string byte "%zu bytes not freed", 10, 0

.code

;
; Heap Initialize
;
heap_initialize proc

	FUNCTION_PROLOGUE

	mov g_heap_size, 0 ; Reset heap size

	FUNCTION_EPILOGUE

	ret

heap_initialize endp

;
; Heap Alloc
;
heap_alloc proc block_size:qword

	FUNCTION_PROLOGUE

	mov rbx, rcx ; Temporary to hold block size

	add rbx, SIZEOF qword       ; Add block primitive size
	ALIGN_UP_REG rbx, PAGE_SIZE ; Align size up to the nearest page boundary

	; Alloc virtual block
	CALL_PROLOGUE_IMM 0h
	xor rcx, rcx                      ; [ARG0] lpAddress
	mov rdx, rbx                      ; [ARG1] dwSize
	mov r8, MEM_COMMIT OR MEM_RESERVE ; [ARG2] flAllocationType
	mov r9, PAGE_READWRITE            ; [ARG3] flProtect
	call VirtualAlloc
	CALL_EPILOGUE_IMM 0h

IFDEF DEBUG
	add g_heap_size, rbx     ; Add block size to overall size
	mov qword ptr [rax], rbx ; Store block size in block
	add rax, SIZEOF qword    ; Increment block past block size
ENDIF ; DEBUG

	FUNCTION_EPILOGUE

heap_alloc endp

;
; Heap Free
;
heap_free proc block:qword

	FUNCTION_PROLOGUE

	; Free virtual block
	CALL_PROLOGUE_IMM 0h
	xor rdx, rdx         ; [ARG1] dwSize
	mov r8, MEM_RELEASE  ; [ARG2] dwFreeType
	call VirtualFree
	CALL_EPILOGUE_IMM 0h

IFDEF DEBUG
	mov rbx, qword ptr [rcx - SIZEOF qword] ; Temporary to hold block size
	sub g_heap_size, rbx                    ; Subtract block size from overall size
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
	cmp g_heap_size, 0
	jz no_leak_found

	; Print leaked byte count
	CALL_PROLOGUE_IMM 8h
	lea rcx, g_heap_leak_format_string ; [ARG0] format
	mov rdx, 1                         ; [ARG1] num_args
	mov rax, g_heap_size
	mov qword ptr [rsp], rax           ; [ARG2] variadic
	call console_log
	CALL_EPILOGUE_IMM 8h

no_leak_found:

	FUNCTION_EPILOGUE

	ret

heap_validate endp

end
