INCLUDE core_console.inc
INCLUDE core_heap.inc
INCLUDE core_macros.inc

INCLUDE engine_main.inc
INCLUDE engine_window.inc

extern _CRT_INIT : proc

.data

g_window_title byte "Redshift", 0

g_format_string_1 byte "first:%zu", 10, 0
g_format_string_2 byte "first:%zu second:%zu", 10, 0
g_format_string_3 byte "first:%zu second:%zu third:%zu", 10, 0

.code

main proc

	; Function prologue
	push rbp
	mov rbp, rsp

	call _CRT_INIT ; Initialize C Run-Time

	call heap_initialize ; Initialize heap
	call console_initialize ; Initialize console

	; TODO
	; mov rcx, 32 ; [ARG0] size
	; call heap_alloc

	; TODO
	; mov rcx, rax ; [ARG0] block
	; call heap_free

	; TODO
	CALL_PROLOGUE 8h
	lea rcx, g_format_string_1 ; [ARG0] format
	mov rdx, 1 ; [ARG1] num_args
	mov qword ptr [rsp], 42 ; [ARG2] variadic
	call console_log
	CALL_EPILOGUE 8h

	; TODO
	CALL_PROLOGUE 10h
	lea rcx, g_format_string_2 ; [ARG0] format
	mov rdx, 2 ; [ARG1] num_args
	mov qword ptr [rsp], 42 ; [ARG2] variadic
	mov qword ptr [rsp + 8h], 43 ; [ARG3] variadic
	call console_log
	CALL_EPILOGUE 10h

	; TODO
	CALL_PROLOGUE 18h
	lea rcx, g_format_string_3 ; [ARG0] format
	mov rdx, 3 ; [ARG1] num_args
	mov qword ptr [rsp], 42 ; [ARG2] variadic
	mov qword ptr [rsp + 8h], 43 ; [ARG3] variadic
	mov qword ptr [rsp + 10h], 44 ; [ARG4] variadic
	call console_log
	CALL_EPILOGUE 18h

	; Create window
	lea rcx, g_window_title ; [ARG0] title
	call window_alloc

	call console_restore; Restore console
	call heap_validate ; Validate heap

	; Function epilogue
	mov rsp, rbp
	pop rbp

	xor rax, rax ; Return 0

	ret

main endp

end
