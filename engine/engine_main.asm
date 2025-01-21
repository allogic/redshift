INCLUDE core_common_macros.inc
INCLUDE core_crt_api.inc
INCLUDE core_heap.inc
INCLUDE core_tracy_api.inc

INCLUDE engine_main.inc
INCLUDE engine_context.inc

.CODE

; #################################################################
; ### Engine Loop
; #################################################################

BEGIN_FUNCTION_DEFINITION engine_loop, "engine_loop"

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

END_FUNCTION_DEFINITION engine_loop

; #################################################################
; ### Entry Point
; #################################################################

main PROC

	FUNCTION_PROLOGUE

	; Initialize CRT
	sub       rsp, 20h  ; Allocate shadow space and align stack
	call      _CRT_INIT ; Initialize CRT
	add       rsp, 20h  ; Restore stack

IFDEF __DEBUG

	; Startup tracy profiler
	sub       rsp, 20h                  ; Allocate shadow space and align stack
	call      ___tracy_startup_profiler ; Startup tracy profiler
	add       rsp, 20h                  ; Restore stack

ENDIF ; __DEBUG

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

IFDEF __DEBUG

	; Shutdown tracy profiler
	sub       rsp, 20h                   ; Allocate shadow space and align stack
	call      ___tracy_shutdown_profiler ; Shutdown tracy profiler
	add       rsp, 20h                   ; Restore stack

ENDIF ; __DEBUG

	; Set return value
	xor       rax, rax ; Simply discard it

	FUNCTION_EPILOGUE

	ret

main ENDP

end
