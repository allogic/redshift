INCLUDE core_console.inc

STD_INPUT_HANDLE EQU -10
STD_OUTPUT_HANDLE EQU -11
STD_ERROR_HANDLE EQU -12

extern GetStdHandle : proc
extern WriteConsoleA : proc

.data

.code

console_log proc
	sub rsp, 28h ; Align stack to 16-byte boundary

	mov rbx, rcx ; Temporary to hold message ptr
	mov rdi, rdx ; Temporary to hold message length

	mov rcx, STD_OUTPUT_HANDLE ; nStdHandle
	call GetStdHandle

	mov rcx, rax ; hConsoleOutput
	mov rdx, rbx ; lpBuffer
	mov r8, rdi ; nNumberOfCharsToWrite
	xor r9, r9 ; lpNumberOfCharsWritten
	call WriteConsoleA

	xor rax, rax ; Discard return value

	add rsp, 28h ; Undo stack alignment
	ret
console_log endp

end
