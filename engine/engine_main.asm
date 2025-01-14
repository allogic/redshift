INCLUDE core_console.inc
INCLUDE core_heap.inc
INCLUDE core_vector.inc

.data

message byte "Hello, World!", 0 ; TODO: Remove me..
message_length qword 13 ; TODO: Remove me..

.code

main proc
	mov rcx, 32
	call heap_alloc

	mov rcx, rax
	call heap_free

	lea rcx, message
	mov rdx, message_length
	call console_log

	call vector_alloc

	ret
main endp

end
