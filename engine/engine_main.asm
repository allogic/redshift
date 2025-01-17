INCLUDE core_console.inc
INCLUDE core_heap.inc
INCLUDE core_macros.inc

INCLUDE engine_main.inc
INCLUDE engine_window.inc

extern _CRT_INIT : proc

.data

g_fld_ctrl   word  37Fh
g_mxcsr_ctrl dword 1F80h

; TODO
g_format_string_0 byte "zero", 10, 0
g_format_string_1 byte "first:%zu", 10, 0
g_format_string_2 byte "first:%zu second:%zu", 10, 0
g_format_string_3 byte "first:%zu second:%zu third:%zu", 10, 0

.code

;
; Engine Initialize
;
engine_initialize proc

	FUNCTION_PROLOGUE

	; Initialize heap
	sub       rsp, 28h        ; Allocate shadow space and align stack
	call      heap_initialize ; Initialize heap
	add       rsp, 28h        ; Restore stack

	; Initialize console
	sub       rsp, 28h           ; Allocate shadow space and align stack
	call      console_initialize ; Initialize console
	add       rsp, 28h           ; Restore stack

	; Initialize window
	sub       rsp, 28h          ; Allocate shadow space and align stack
	call      window_initialize ; Initialize window
	add       rsp, 28h          ; Restore stack

	; Create window
	sub       rsp, 28h      ; Allocate shadow space and align stack
	call      window_create ; Create window
	add       rsp, 28h      ; Restore stack

	; Engine loop
	sub       rsp, 28h    ; Allocate shadow space and align stack
	call      engine_loop ; Engine loop
	add       rsp, 28h    ; Restore stack

	; Destroy window
	sub       rsp, 28h       ; Allocate shadow space and align stack
	call      window_destroy ; Destroy window
	add       rsp, 28h       ; Restore stack

	; Restore console
	sub       rsp, 28h        ; Allocate shadow space and align stack
	call      console_restore ; Restore console
	add       rsp, 28h        ; Restore stack

	; Validate heap
	sub       rsp, 28h      ; Allocate shadow space and align stack
	call      heap_validate ; Validate heap
	add       rsp, 28h      ; Restore stack

	FUNCTION_EPILOGUE

	ret

engine_initialize endp

;
; Engine Loop
;
engine_loop proc

	FUNCTION_PROLOGUE

loop_head:

	; Poll Events
	sub       rsp, 28h           ; Allocate shadow space and align stack
	call      window_poll_events ; Poll events
	add       rsp, 28h           ; Restore stack

	; Check if window has closed
	cmp       g_window_should_close, 0 ; Compare window should close
	je        loop_head                ; Continue loop if window should not close

	FUNCTION_EPILOGUE

	ret

engine_loop endp

;
; Entry Point
;
main proc argc:dword, argv:qword, envp:qword

	FUNCTION_PROLOGUE

	; Initialize C Run-Time
	sub       rsp, 28h  ; Allocate shadow space and align stack
	call      _CRT_INIT ; Initialize CRT
	add       rsp, 28h  ; Restore stack

	; Initialize FPU and MXCSR
	lea       rcx, g_fld_ctrl   ; Default FPU control word
	fldcw     [rcx]             ; Load FPU control word
	lea       rdx, g_mxcsr_ctrl ; Default MXCSR control word
	ldmxcsr   [rdx]             ; Load MXCSR control dword

	; TODO
	; mov rcx, 32 ; [ARG0] size
	; call heap_alloc

	; TODO
	; mov rcx, rax ; [ARG0] block
	; call heap_free

	; TODO
	sub       rsp, 28h               ; Allocate shadow space and align stack
	mov       rdx, 0                 ; [ARG1] num_args
	lea       rcx, g_format_string_0 ; [ARG0] format
	call      console_log            ; Console log
	add       rsp, 28h               ; Restore stack

	; TODO
	sub       rsp, 28h               ; Allocate shadow space and align stack
	push      42                     ; [ARG4] variadic
	mov       rdx, 1                 ; [ARG1] num_args
	lea       rcx, g_format_string_1 ; [ARG0] format
	call      console_log            ; Console log
	add       rsp, 28h               ; Restore stack

	; TODO
	sub       rsp, 28h               ; Allocate shadow space and align stack
	push      43                     ; [ARG5] variadic
	push      42                     ; [ARG4] variadic
	mov       rdx, 2                 ; [ARG1] num_args
	lea       rcx, g_format_string_2 ; [ARG0] format
	call      console_log            ; Console log
	add       rsp, 28h               ; Restore stack

	; TODO
	sub       rsp, 28h               ; Allocate shadow space and align stack
	push      44                     ; [ARG6] variadic
	push      43                     ; [ARG5] variadic
	push      42                     ; [ARG4] variadic
	mov       rdx, 3                 ; [ARG1] num_args
	lea       rcx, g_format_string_3 ; [ARG0] format
	call      console_log            ; Console log
	add       rsp, 28h               ; Restore stack

	; Initialize engine
	sub       rsp, 28h          ; Allocate shadow space and align stack
	call      engine_initialize ; Validate heap
	add       rsp, 28h          ; Restore stack

	FUNCTION_EPILOGUE

	xor rax, rax ; Return 0

	ret

main endp

end
