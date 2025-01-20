INCLUDE core_common_macros.inc
INCLUDE core_crt.inc
INCLUDE core_heap.inc
INCLUDE core_tracy_api.inc

INCLUDE engine_main.inc
INCLUDE engine_context.inc

.data

ALIGN 4h
g_main_thread_name byte "main_thread", 0

.code

; #################################################################
; ### Engine Initialize
; #################################################################

BEGIN_FUNCTION_DEFINITION engine_initialize, "engine_initialize"

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

END_FUNCTION_DEFINITION engine_initialize

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

main proc

	FUNCTION_PROLOGUE

	; TODO
	; ALIGN_DR  rsp, 10h ; Align stack pointer

	; Initialize CRT
	sub       rsp, 20h  ; Allocate shadow space and align stack
	call      _CRT_INIT ; Initialize CRT
	add       rsp, 20h  ; Restore stack

IFDEF __DEBUG

	; Set main thread name for tracy
	lea       rcx, g_main_thread_name  ; [ARG0] name
	sub       rsp, 20h                 ; Allocate shadow space and align stack
	call      ___tracy_set_thread_name ; Set thread name
	add       rsp, 20h                 ; Restore stack

ENDIF ; __DEBUG

	; Initialize engine
	sub       rsp, 20h          ; Allocate shadow space and align stack
	call      engine_initialize ; Initialize engine
	add       rsp, 20h          ; Restore stack

	xor       rax, rax ; Return 0

	FUNCTION_EPILOGUE

	ret

main endp

end
