IFNDEF __CORE_MACROS

__CORE_MACROS EQU 1

; #################################################################
; ### Alignment Specific Macros
; #################################################################

; Macro to align an immediate value down to the nearest boundary
ALIGN_DI MACRO imm, alignment
	(imm AND NOT (alignment - 1))
ENDM ; ALIGN_DI

; Macro to align an immediate value up to the nearest boundary
ALIGN_UI MACRO imm, alignment
	((imm + alignment - 1) AND NOT (alignment - 1))
ENDM ; ALIGN_UI

; Macro to align a register down to the nearest boundary
ALIGN_DR MACRO reg, alignment
	and reg, NOT (alignment - 1)
ENDM ; ALIGN_DR

; Macro to align a register up to the nearest boundary
ALIGN_UR MACRO reg, alignment
	lea reg, qword ptr [reg + alignment - 1]
	and reg, NOT (alignment - 1)
ENDM ; ALIGN_UR

; #################################################################
; ### Function Specific Macros
; #################################################################

IFDEF __DEBUG

; Macro to start a function declaration with a dedicated string variable
; followed by a call to start a new tracy frame
BEGIN_FUNCTION_DEFINITION MACRO name, tracy_name

	.data

	ALIGN 4h
	g_&name&_proc_name byte tracy_name, 0

	.code

	; Function name
	name proc

	; Function prologue
	push rbp
	mov rbp, rsp

	; Store registers into temporaries
	mov r12, rax
	mov r13, rcx

	; Track function call
	lea rcx, g_&name&_proc_name
	sub rsp, 20h
	call ___tracy_emit_frame_mark
	add rsp, 20h

	; Track start of function call
	;lea rcx, g_&name&_proc_name
	;sub rsp, 20h
	;call ___tracy_emit_frame_mark_start
	;add rsp, 20h

	; Restore registers from temporaries
	mov rcx, r13
	mov rax, r12

ENDM ; BEGIN_FUNCTION_DEFINITION

; Macro to end a function declaration that causes a call to emit
; the end of a tracy frame
END_FUNCTION_DEFINITION MACRO name

	; Store registers into temporaries
	mov r12, rax
	mov r13, rcx

	; Track end of function call
	;lea rcx, g_&name&_proc_name
	;sub rsp, 20h
	;call ___tracy_emit_frame_mark_end
	;add rsp, 20h

	; Restore registers from temporaries
	mov rcx, r13
	mov rax, r12

	; Function epilogue
	mov rsp, rbp
	pop rbp

	ret

	name endp

ENDM ; END_FUNCTION_DEFINITION

ELSE

; Macro to start a function declaration
BEGIN_FUNCTION_DEFINITION MACRO name
	.code
	name proc
	push rbp
	mov rbp, rsp
ENDM ; BEGIN_FUNCTION_DEFINITION

; Macro to end a function declaration
END_FUNCTION_DEFINITION MACRO name
	mov rsp, rbp
	pop rbp
	ret
	name endp
ENDM ; END_FUNCTION_DEFINITION

ENDIF ; __DEBUG

; Macro to store the stack pointer into the base pointer
FUNCTION_PROLOGUE MACRO
	push rbp
	mov rbp, rsp
ENDM ; FUNCTION_PROLOGUE

; Macro to restore the stack pointer from the base pointer
FUNCTION_EPILOGUE MACRO
	mov rsp, rbp
	pop rbp
ENDM ; FUNCTION_EPILOGUE

ENDIF ; __CORE_MACROS
