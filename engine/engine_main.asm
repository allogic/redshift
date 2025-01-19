INCLUDE core_common_macros.inc
INCLUDE core_crt.inc
INCLUDE core_heap.inc

INCLUDE engine_main.inc
INCLUDE engine_context.inc

.code

;
; Engine Initialize
;
engine_initialize proc

	FUNCTION_PROLOGUE

	; Initialize heap
	sub       rsp, 20h        ; Allocate shadow space and align stack
	call      heap_initialize ; Initialize heap
	add       rsp, 20h        ; Restore stack

	; Create context
	sub       rsp, 20h       ; Allocate shadow space and align stack
	call      context_create ; Create context
	add       rsp, 20h       ; Restore stack

	; Engine loop
	sub       rsp, 20h    ; Allocate shadow space and align stack
	call      engine_loop ; Engine loop
	add       rsp, 20h    ; Restore stack

	; Destroy context
	sub       rsp, 20h        ; Allocate shadow space and align stack
	call      context_destroy ; Destroy context
	add       rsp, 20h        ; Restore stack

	; Validate heap
	sub       rsp, 20h      ; Allocate shadow space and align stack
	call      heap_validate ; Validate heap
	add       rsp, 20h      ; Restore stack

	FUNCTION_EPILOGUE

	ret

engine_initialize endp

;
; Engine Loop
;
engine_loop proc

	FUNCTION_PROLOGUE

	; TODO
	mov       rcx, 100h  ; [ARG0] block_size
	sub       rsp, 20h   ; Allocate shadow space and align stack
	call      heap_alloc ; Heap alloc
	add       rsp, 20h   ; Restore stack

	; TODO
	mov       rcx, rax  ; [ARG0] block
	sub       rsp, 20h  ; Allocate shadow space and align stack
	call      heap_free ; Heap free
	add       rsp, 20h  ; Restore stack

loop_head:

	; Poll events
	sub       rsp, 20h            ; Allocate shadow space and align stack
	call      context_poll_events ; Poll events
	add       rsp, 20h            ; Restore stack

	; Check if window has closed
	cmp       g_window_should_close, 0 ; Compare window should close
	je        loop_head                ; Continue loop if window should not close

loop_tail:

	FUNCTION_EPILOGUE

	ret

engine_loop endp

;
; Entry Point
;
main proc argc:dword, argv:qword, envp:qword

	; Initialize CRT
	sub       rsp, 20h  ; Allocate shadow space and align stack
	call      _CRT_INIT ; Initialize CRT
	add       rsp, 20h  ; Restore stack

	; Initialize engine
	sub       rsp, 20h          ; Allocate shadow space and align stack
	call      engine_initialize ; Initialize engine
	add       rsp, 20h          ; Restore stack

	xor rax, rax ; Return 0

	ret

main endp

end
