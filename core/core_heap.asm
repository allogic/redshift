INCLUDE core_heap.inc

PAGE_SIZE EQU 1000h ; Page size (4 KB)

; Macro to align an immediate value down to the nearest page boundary
ALIGN_DOWN_IMM MACRO imm
	(imm AND NOT (PAGE_SIZE - 1))
ENDM ; ALIGN_DOWN_IMM

; Macro to align an immediate value up to the nearest page boundary
ALIGN_UP_IMM MACRO imm
	((imm + PAGE_SIZE - 1) AND NOT (PAGE_SIZE - 1))
ENDM ; ALIGN_UP_IMM

; Macro to align a register down to the nearest page boundary
ALIGN_DOWN_REG MACRO reg
	and reg, NOT (PAGE_SIZE - 1)
ENDM ; ALIGN_DOWN_REG

; Macro to align a register up to the nearest page boundary
ALIGN_UP_REG MACRO reg
	lea reg, [reg + PAGE_SIZE - 1]
	and reg, NOT (PAGE_SIZE - 1)
ENDM ; ALIGN_UP_REG

MEM_COMMIT EQU 1000h
MEM_RESERVE EQU 2000h
MEM_RELEASE EQU 8000h

PAGE_READWRITE EQU 4h

extern VirtualAlloc : proc
extern VirtualFree : proc

.data

g_heap_size qword 0

.code

heap_alloc proc
	sub rsp, 28h ; Align stack to 16-byte boundary

	mov rbx, rcx ; Temporary to hold block size
	add rbx, SIZEOF qword ; Add block primitive size
	ALIGN_UP_REG rbx ; Align size up to the nearest page boundary

	xor rcx, rcx ; lpAddress
	mov rdx, rbx ; dwSize
	mov r8, MEM_COMMIT OR MEM_RESERVE ; flAllocationType
	mov r9, PAGE_READWRITE ; flProtect
	call VirtualAlloc

IFDEF DEBUG
	add g_heap_size, rbx ; Add block size to overall size
	mov [rax], rbx ; Store block size in block
	add rax, SIZEOF qword ; Increment block past block size
ENDIF ; DEBUG

	add rsp, 28h ; Undo stack alignment
	ret
heap_alloc endp

heap_free proc
	sub rsp, 28h ; Align stack to 16-byte boundary

IFDEF DEBUG
	mov rbx, [rcx - SIZEOF qword] ; Temporary to hold block size
	sub g_heap_size, rbx ; Subtract block size from overall size
ENDIF ; DEBUG

	xor rdx, rdx ; dwSize
	mov r8, MEM_RELEASE ; dwFreeType
	call VirtualFree

	xor rax, rax ; Discard return value

	add rsp, 28h ; Undo stack alignment
	ret
heap_free endp

end
