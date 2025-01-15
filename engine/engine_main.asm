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

	FUNCTION_PROLOGUE

	; Initialize C Run-Time
	CALL_PROLOGUE_IMM 0h
	call _CRT_INIT
	CALL_EPILOGUE_IMM 0h

	; Initialize heap
	CALL_PROLOGUE_IMM 0h
	call heap_initialize
	CALL_EPILOGUE_IMM 0h

	; Initialize console
	CALL_PROLOGUE_IMM 0h
	call console_initialize
	CALL_EPILOGUE_IMM 0h

	; TODO
	; mov rcx, 32 ; [ARG0] size
	; call heap_alloc

	; TODO
	; mov rcx, rax ; [ARG0] block
	; call heap_free

	; TODO
	CALL_PROLOGUE_IMM 8h
	lea rcx, g_format_string_1 ; [ARG0] format
	mov rdx, 1 ; [ARG1] num_args
	mov qword ptr [rsp], 42 ; [ARG2] variadic
	call console_log
	CALL_EPILOGUE_IMM 8h

	; TODO
	CALL_PROLOGUE_IMM 10h
	lea rcx, g_format_string_2 ; [ARG0] format
	mov rdx, 2 ; [ARG1] num_args
	mov qword ptr [rsp], 42 ; [ARG2] variadic
	mov qword ptr [rsp + 8h], 43 ; [ARG3] variadic
	call console_log
	CALL_EPILOGUE_IMM 10h

	; TODO
	CALL_PROLOGUE_IMM 18h
	lea rcx, g_format_string_3 ; [ARG0] format
	mov rdx, 3 ; [ARG1] num_args
	mov qword ptr [rsp], 42 ; [ARG2] variadic
	mov qword ptr [rsp + 8h], 43 ; [ARG3] variadic
	mov qword ptr [rsp + 10h], 44 ; [ARG4] variadic
	call console_log
	CALL_EPILOGUE_IMM 18h

	; Create window
	; CALL_PROLOGUE_IMM 0h
	; lea rcx, g_window_title ; [ARG0] title
	; call window_alloc
	; CALL_EPILOGUE_IMM 0h

	; Restore console
	CALL_PROLOGUE_IMM 0h
	call console_restore
	CALL_EPILOGUE_IMM 0h

	; Validate heap
	CALL_PROLOGUE_IMM 0h
	call heap_validate
	CALL_EPILOGUE_IMM 0h

	FUNCTION_EPILOGUE

	xor rax, rax ; Discard return

	ret

main endp

end
