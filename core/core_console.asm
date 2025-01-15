INCLUDE core_console.inc
INCLUDE core_macros.inc

STD_INPUT_HANDLE EQU -10
STD_OUTPUT_HANDLE EQU -11
STD_ERROR_HANDLE EQU -12

CP_UTF7 EQU 65000
CP_UTF8 EQU 65001

extern snprintf : proc

extern GetConsoleOutputCP : proc
extern SetConsoleOutputCP : proc
extern GetStdHandle : proc
extern WriteConsoleA : proc

.data

g_console_orig_code_page_ident qword ?
g_console_standard_output qword ?
g_console_format_buffer byte 1000h dup(?)
g_console_format_length qword ?

.code

;
; Console Initialize
;
console_initialize proc

	FUNCTION_PROLOGUE

	; Get original code page identifier
	CALL_PROLOGUE_IMM 0h
	call GetConsoleOutputCP
	mov qword ptr [g_console_orig_code_page_ident], rax ; Store original code page identifier
	CALL_EPILOGUE_IMM 0h

	; Set desired code page identifier
	CALL_PROLOGUE_IMM 0h
	mov rcx, CP_UTF8 ; [ARG0] wCodePageID
	call SetConsoleOutputCP
	CALL_EPILOGUE_IMM 0h

	; Get standard output handle
	CALL_PROLOGUE_IMM 0h
	mov rcx, STD_OUTPUT_HANDLE ; [ARG0] nStdHandle
	call GetStdHandle
	mov qword ptr [g_console_standard_output], rax ; Store console handle
	CALL_EPILOGUE_IMM 0h

	FUNCTION_EPILOGUE

	ret

console_initialize endp

;
; Console Log
;
console_log proc

	FUNCTION_PROLOGUE

	mov rbx, rcx ; Temporary to hold format string
	mov rdi, rdx ; Temporary to hold num args

	sub rdi, 1 ; Subtract 1, since first arg is not on the stack
	shl rdi, 3 ; Multiply by 8, since this is an offset

	; Prepare snprintf register args
	CALL_PROLOGUE_REG rdi
	lea rcx, g_console_format_buffer ; [ARG0] buffer
	mov rdx, 1000h ; [ARG1] count
	mov r8, rbx ; [ARG2] format
	mov r9, qword ptr [rbp + 10h] ; [ARG3] variadic

	; Prepare snprintf stack args
	mov rsi, 0 ; Offset for stack args
	cmp rsi, rdi ; Compare offset
	jge arg_loop_tail
arg_loop_head:
	mov r12, qword ptr [rbp + 18h + rsi] ; Temporary to hold arg
	mov qword ptr [rsp + 20h + rsi], r12 ; [ARGX] variadic
	add rsi, 8h ; Increment offset
	cmp rsi, rdi ; Compare offset
	jl arg_loop_head
arg_loop_tail:

	; Call snprintf
	call snprintf
	mov qword ptr [g_console_format_length], rax ; Store format buffer length
	CALL_EPILOGUE_REG rdi

	; Write formatted output
	CALL_PROLOGUE_IMM 0h
	mov rcx, g_console_standard_output ; [ARG0] hConsoleOutput
	lea rdx, g_console_format_buffer ; [ARG1] lpBuffer
	mov r8, g_console_format_length ; [ARG2] nNumberOfCharsToWrite
	xor r9, r9 ; [ARG3] lpNumberOfCharsWritten
	call WriteConsoleA
	CALL_EPILOGUE_IMM 0h

	FUNCTION_EPILOGUE

	ret

console_log endp

;
; Console Restore
;
console_restore proc

	FUNCTION_PROLOGUE

	; Restore original code page identifier
	CALL_PROLOGUE_IMM 0h
	lea rcx, g_console_orig_code_page_ident ; [ARG0] wCodePageID
	call SetConsoleOutputCP
	CALL_EPILOGUE_IMM 0h

	FUNCTION_EPILOGUE

	ret

console_restore endp

end
