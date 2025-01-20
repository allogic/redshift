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

; Macro to start a function definition
BEGIN_FUNCTION_DEFINITION MACRO name, tracy_name

	.data

	ALIGN 4h
	g_&name&_proc_name byte tracy_name, 0 ; TODO: maybe unused..

	ALIGN 4h
	g_&name&_tracy_zone_ctx ___tracy_c_zone_context {}

	ALIGN 4h
	g_&name&_tracy_src_loc_data ___tracy_source_location_data {}

	.code

	; Begin function definition
	name proc

	; Function prologue
	push      rbp
	mov       rbp, rsp

	; Store registers into temporaries
	mov       r12, rax
	mov       r13, rcx
	mov       r14, rdx

	; TODO: only do this once!
	; Fill tracy src location data
	;mov       g_&name&_tracy_src_loc_data.loc_name, 0
	;mov       g_&name&_tracy_src_loc_data.func_name, 0
	;mov       g_&name&_tracy_src_loc_data.file_name, 0
	;mov       g_&name&_tracy_src_loc_data.line_number, 666
	;mov       g_&name&_tracy_src_loc_data.color, 88000000h

	; static const struct ___tracy_source_location_data TracyConcat(__tracy_source_location,TracyLine) = { name, __func__,  TracyFile, (uint32_t)TracyLine, color }
	; TracyCZoneCtx ctx = ___tracy_emit_zone_begin( &TracyConcat(__tracy_source_location,TracyLine), active );

	; Emit tracy zone begin
	;mov       rdx, 1                              ; [ARG1] active
	;lea       rcx, g_&name&_tracy_src_loc_data    ; [ARG0] srcloc
	;sub       rsp, 20h                            ; Allocate shadow space and align stack
	;call      ___tracy_emit_zone_begin            ; Emit tracy zone start
	;add       rsp, 20h                            ; Restore stack
	;mov       g_&name&_tracy_zone_ctx.id, eax     ; Store context id
	;shr       rax, 20h                            ; Shift right to access the lower half
	;mov       g_&name&_tracy_zone_ctx.active, eax ; Store context active

	; Track function call
	;lea rcx, g_&name&_proc_name ; TODO: naming and alignment..
	;sub rsp, 20h
	;call ___tracy_emit_frame_mark
	;add rsp, 20h

	; Track start of function call
	;lea rcx, g_&name&_proc_name
	;sub rsp, 20h
	;call ___tracy_emit_frame_mark_start
	;add rsp, 20h

	; Restore registers from temporaries
	mov rdx, r14
	mov rcx, r13
	mov rax, r12

ENDM ; BEGIN_FUNCTION_DEFINITION

; Macro to end a function definition
END_FUNCTION_DEFINITION MACRO name

	; Store registers into temporaries
	mov       r12, rax
	mov       r13, rcx

	; Emit tracy zone end
	;xor       rcx, rcx                            ; Zero RCX
	;mov       ecx, g_&name&_tracy_zone_ctx.active ; Set context active
	;shl       rcx, 20h                            ; Shift id into upper half
	;xor       ecx, g_&name&_tracy_zone_ctx.id     ; Set context id
	;sub       rsp, 20h                            ; Allocate shadow space and align stack
	;call      ___tracy_emit_zone_end              ; Emit tracy zone end
	;add       rsp, 20h                            ; Restore stack

	; Track end of function call
	;lea rcx, g_&name&_proc_name
	;sub rsp, 20h
	;call ___tracy_emit_frame_mark_end
	;add rsp, 20h

	; Restore registers from temporaries
	mov       rcx, r13
	mov       rax, r12

	; Function epilogue
	mov       rsp, rbp
	pop       rbp

	; Return
	ret

	; End function definition
	name endp

ENDM ; END_FUNCTION_DEFINITION

ELSE

; Macro to start a function definition
BEGIN_FUNCTION_DEFINITION MACRO name
	.code
	name proc
	push rbp
	mov rbp, rsp
ENDM ; BEGIN_FUNCTION_DEFINITION

; Macro to end a function definition
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

; #################################################################
; ### Tracy Specific Macros
; #################################################################

ENDIF ; __CORE_MACROS
