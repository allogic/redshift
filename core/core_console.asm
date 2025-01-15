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
	sub rsp, 28h ; Allocate shadow space and align stack
	call GetConsoleOutputCP
	mov qword ptr [g_console_orig_code_page_ident], rax ; Store original code page identifier
	add rsp, 28h ; Restore stack

	; Set desired code page identifier
	sub rsp, 28h ; Allocate shadow space and align stack
	mov rcx, CP_UTF8 ; ; [ARG0] wCodePageID
	call SetConsoleOutputCP
	add rsp, 28h ; Restore stack

	; Get standard output handle
	sub rsp, 28h ; Allocate shadow space and align stack
	mov rcx, STD_OUTPUT_HANDLE ; [ARG0] nStdHandle
	call GetStdHandle
	mov qword ptr [g_console_standard_output], rax ; Store console handle
	add rsp, 28h ; Restore stack

	FUNCTION_EPILOGUE

	ret

console_initialize endp

;
; Console Log
;
console_log proc

	FUNCTION_PROLOGUE

	; TODO: args -> shadow space
	mov rbx, rcx ; Temporary to hold format string
	mov rdi, rdx ; Temporary to hold num args

	sub rdi, 1 ; Subtract 1, since first arg is not on the stack
	shl rdi, 3 ; Multiply by 8, since this is an offset

	; Prepare snprintf register args
	sub rsp, 38h ; Allocate shadow space and align stack
	lea rcx, g_console_format_buffer ; [ARG0] buffer
	mov rdx, 1000h ; [ARG1] count
	mov r8, rbx ; [ARG2] format
	; TODO: check if num args is greater 0
	mov r9, qword ptr [rbp + 10h] ; [ARG3] variadic

	; Variadic snprintf stack args
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
	add rsp, 38h ; Restore stack

	; Write formatted output
	sub rsp, 28h ; Allocate shadow space and align stack
	mov rcx, g_console_standard_output ; [ARG0] hConsoleOutput
	lea rdx, g_console_format_buffer ; [ARG1] lpBuffer
	mov r8, g_console_format_length ; [ARG2] nNumberOfCharsToWrite
	xor r9, r9 ; [ARG3] lpNumberOfCharsWritten
	call WriteConsoleA
	add rsp, 28h ; Restore stack

	FUNCTION_EPILOGUE

	ret

console_log endp

;
; Console Restore
;
console_restore proc

	FUNCTION_PROLOGUE

	; Restore original code page identifier
	sub rsp, 28h ; Allocate shadow space and align stack
	lea rcx, g_console_orig_code_page_ident ; [ARG0] wCodePageID
	call SetConsoleOutputCP
	add rsp, 28h ; Restore stack

	FUNCTION_EPILOGUE

	ret

console_restore endp

end
