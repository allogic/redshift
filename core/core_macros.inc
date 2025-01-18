IFNDEF __CORE_MACROS

__CORE_MACROS EQU 1

; Macro to align an immediate value down to the nearest boundary
ALIGN_DI MACRO imm, align
	(imm AND NOT (align - 1))
ENDM ; ALIGN_DI

; Macro to align an immediate value up to the nearest boundary
ALIGN_UI MACRO imm, align
	((imm + align - 1) AND NOT (align - 1))
ENDM ; ALIGN_UI

; Macro to align a register down to the nearest boundary
ALIGN_DR MACRO reg, align
	and reg, NOT (align - 1)
ENDM ; ALIGN_DR

; Macro to align a register up to the nearest boundary
ALIGN_UR MACRO reg, align
	lea reg, qword ptr [reg + align - 1]
	and reg, NOT (align - 1)
ENDM ; ALIGN_UR

; Macro to store the stack pointer into the base pointer
FUNCTION_PROLOGUE MACRO
	push rbp
	mov rbp, rsp
	ALIGN_DR rsp, 10h
ENDM ; FUNCTION_PROLOGUE

; Macro to restore the stack pointer from the base pointer
FUNCTION_EPILOGUE MACRO
	mov rsp, rbp
	pop rbp
	ALIGN_UR rsp, 10h
ENDM ; FUNCTION_EPILOGUE

ENDIF ; __CORE_MACROS
