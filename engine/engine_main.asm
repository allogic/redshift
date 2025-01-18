INCLUDE core_heap.inc
INCLUDE core_macros.inc

INCLUDE engine_main.inc
INCLUDE engine_window.inc

extern _CRT_INIT : proc

.code

;
; Engine Initialize
;
engine_initialize proc

	FUNCTION_PROLOGUE

	; Allocate shadow space
	sub       rsp, 20h

	; Initialize heap
	call      heap_initialize ; Initialize heap

	; TODO
	mov       rcx, 32    ; [ARG0] block_size
	call      heap_alloc ; Heap alloc

	; TODO
	mov       rcx, rax  ; [ARG0] block
	call      heap_free ; Heap free

	; Initialize window
	call      window_initialize ; Initialize window

	; Create window
	call      window_create ; Create window

	; Engine loop
	call      engine_loop ; Engine loop

	; Destroy window
	call      window_destroy ; Destroy window

	; Validate heap
	call      heap_validate ; Validate heap

	; Restore stack
	add       rsp, 28h

	FUNCTION_EPILOGUE

	ret

engine_initialize endp

;
; Engine Loop
;
engine_loop proc

	FUNCTION_PROLOGUE

	; Allocate shadow space
	sub       rsp, 20h

loop_head:

	; Poll Events
	call      window_poll_events ; Poll events

	; Check if window has closed
	cmp       g_window_should_close, 0 ; Compare window should close
	je        loop_head                ; Continue loop if window should not close

loop_tail:

	; Restore stack
	add       rsp, 28h

	FUNCTION_EPILOGUE

	ret

engine_loop endp

;
; Entry Point
;
main proc argc:dword, argv:qword, envp:qword

	FUNCTION_PROLOGUE

	; Allocate shadow space
	sub       rsp, 20h

	; Initialize CRT
	call      _CRT_INIT ; Initialize CRT

	; Initialize engine
	call      engine_initialize ; Initialize engine

	; Restore stack
	add       rsp, 28h

	FUNCTION_EPILOGUE

	xor rax, rax ; Return 0

	ret

main endp

end
