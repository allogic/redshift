IFNDEF __CORE_MACROS

__CORE_MACROS EQU 1

; Macro to align an immediate value down to the nearest boundary
ALIGN_DOWN_IMM MACRO imm, align
	(imm AND NOT (align - 1))
ENDM ; ALIGN_DOWN_IMM

; Macro to align an immediate value up to the nearest boundary
ALIGN_UP_IMM MACRO imm, align
	((imm + align - 1) AND NOT (align - 1))
ENDM ; ALIGN_UP_IMM

; Macro to align a register down to the nearest boundary
ALIGN_DOWN_REG MACRO reg, align
	and reg, NOT (align - 1)
ENDM ; ALIGN_DOWN_REG

; Macro to align a register up to the nearest boundary
ALIGN_UP_REG MACRO reg, align
	lea reg, qword ptr [reg + align - 1]
	and reg, NOT (align - 1)
ENDM ; ALIGN_UP_REG

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

; Macro to allocate stack shadow space, return address and arguments before a function call
CALL_PROLOGUE MACRO size
	sub rsp, 28h
	sub rsp, size
	lea rsp, qword ptr [rsp + 10h - 1]
	and rsp, NOT (10h - 1)
ENDM ; CALL_PROLOGUE

; Macro to restore stack shadow space, return address and arguments after a function call
CALL_EPILOGUE MACRO size
	sub rsp, 28h
	sub rsp, size
	and rsp, NOT (10h - 1)
ENDM ; CALL_EPILOGUE

ENDIF ; __CORE_MACROS
