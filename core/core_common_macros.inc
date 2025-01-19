IFNDEF __CORE_MACROS

__CORE_MACROS EQU 1

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
