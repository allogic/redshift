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
	lea reg, QWORD PTR [reg + alignment - 1]
	and reg, NOT (alignment - 1)
ENDM ; ALIGN_UR

; #################################################################
; ### Function Specific Macros
; #################################################################

IFDEF __DEBUG

; Macro to start a function definition
BEGIN_FUNCTION_DEFINITION MACRO name, name_as_string

	.DATA

	ALIGN 4h
	g_&name&_proc_name BYTE name_as_string, 0

	ALIGN 4h
	g_&name&_tracy_zone_ctx ___tracy_c_zone_context {}

	ALIGN 4h
	g_&name&_tracy_src_loc_data ___tracy_source_location_data {}

	.CODE

	; Begin function definition
	name PROC

	; Function prologue
	push      rbp
	mov       rbp, rsp

	; Store registers
	push      rax
	push      rcx
	push      rdx
	push      r12

	lea       r12, g_&name&_proc_name ; Store proc name into temporary

	; Fill tracy src location data
	mov       g_&name&_tracy_src_loc_data.loc_name, r12
	mov       g_&name&_tracy_src_loc_data.func_name, 0
	mov       g_&name&_tracy_src_loc_data.file_name, 0
	mov       g_&name&_tracy_src_loc_data.line_number, @Line
	mov       g_&name&_tracy_src_loc_data.color, 0FF0000h

	; Clear tracy zone context
	mov       g_&name&_tracy_zone_ctx.id, 0
	mov       g_&name&_tracy_zone_ctx.active, 0

	; Emit tracy zone begin
	mov       rdx, 1                              ; [ARG1] active
	lea       rcx, g_&name&_tracy_src_loc_data    ; [ARG0] srcloc
	sub       rsp, 28h                            ; Allocate shadow space and align stack
	call      ___tracy_emit_zone_begin            ; Emit tracy zone start
	add       rsp, 28h                            ; Restore stack
	mov       g_&name&_tracy_zone_ctx.id, eax     ; Store context id
	shr       rax, 20h                            ; Shift right to access the lower half
	mov       g_&name&_tracy_zone_ctx.active, eax ; Store context active

	; Emit tracy frame mark start
	lea       rcx, g_&name&_proc_name        ; [ARG0] name
	sub       rsp, 28h                       ; Allocate shadow space and align stack
	call      ___tracy_emit_frame_mark_start ; Emit tracy frame mark start
	add       rsp, 28h                       ; Restore stack

	; Restore registers
	pop       r12
	pop       rdx
	pop       rcx
	pop       rax

ENDM ; BEGIN_FUNCTION_DEFINITION

; Macro to end a function definition
END_FUNCTION_DEFINITION MACRO name

	; Store registers
	push      rax
	push      rcx
	push      rdx

	; Emit tracy frame mark end
	lea       rcx, g_&name&_proc_name      ; [ARG0] name
	sub       rsp, 28h                     ; Allocate shadow space and align stack
	call      ___tracy_emit_frame_mark_end ; Emit tracy frame mark end
	add       rsp, 28h                     ; Restore stack

	; Emit tracy zone end
	mov       edx, g_&name&_tracy_zone_ctx.id     ; Store context id into temporary
	mov       ecx, g_&name&_tracy_zone_ctx.active ; Store context active
	shl       rcx, 20h                            ; Shift context active into upper half
	or        rcx, rdx                            ; Store context id
	sub       rsp, 28h                            ; Allocate shadow space and align stack
	call      ___tracy_emit_zone_end              ; Emit tracy zone end
	add       rsp, 28h                            ; Restore stack

	; Restore registers
	pop       rdx
	pop       rcx
	pop       rax

	; Function epilogue
	mov       rsp, rbp
	pop       rbp

	; Return
	ret

	; End function definition
	name ENDP

ENDM ; END_FUNCTION_DEFINITION

ELSE

; Macro to start a function definition
BEGIN_FUNCTION_DEFINITION MACRO name, name_as_string

	.CODE

	; Begin function definition
	name PROC

	; Function prologue
	push      rbp
	mov       rbp, rsp

ENDM ; BEGIN_FUNCTION_DEFINITION

; Macro to end a function definition
END_FUNCTION_DEFINITION MACRO name

	; Function epilogue
	mov       rsp, rbp
	pop       rbp

	; Return
	ret

	; End function definition
	name ENDP

ENDM ; END_FUNCTION_DEFINITION

ENDIF ; __DEBUG

; Macro to store the stack pointer into the base pointer
FUNCTION_PROLOGUE MACRO

	; Function prologue
	push      rbp
	mov       rbp, rsp

ENDM ; FUNCTION_PROLOGUE

; Macro to restore the stack pointer from the base pointer
FUNCTION_EPILOGUE MACRO

	; Function epilogue
	mov       rsp, rbp
	pop       rbp

ENDM ; FUNCTION_EPILOGUE

; #################################################################
; ### Tracy Specific Macros
; #################################################################

IFDEF __DEBUG

; Macro to define a tracy zone name
TRACY_ZONE_NAME MACRO name

	.DATA

	ALIGN 4h
	g_&name&_tracy_zone_ctx ___tracy_c_zone_context {}

	ALIGN 4h
	g_&name&_tracy_src_loc_data ___tracy_source_location_data {}

ENDM ; TRACY_ZONE_NAME

; Macro to start a tracy zone
BEGIN_TRACY_ZONE MACRO name

	; Store registers
	push      rax
	push      rcx
	push      rdx
	push      r12

	lea       r12, g_&name&_proc_name ; Store proc name into temporary

	; Fill tracy src location data
	mov       g_&name&_tracy_src_loc_data.loc_name, r12
	mov       g_&name&_tracy_src_loc_data.func_name, 0
	mov       g_&name&_tracy_src_loc_data.file_name, 0
	mov       g_&name&_tracy_src_loc_data.line_number, @Line
	mov       g_&name&_tracy_src_loc_data.color, 0FF0000h

	; Clear tracy zone context
	mov       g_&name&_tracy_zone_ctx.id, 0
	mov       g_&name&_tracy_zone_ctx.active, 0

	; Emit tracy zone begin
	mov       rdx, 1                              ; [ARG1] active
	lea       rcx, g_&name&_tracy_src_loc_data    ; [ARG0] srcloc
	sub       rsp, 28h                            ; Allocate shadow space and align stack
	call      ___tracy_emit_zone_begin            ; Emit tracy zone start
	add       rsp, 28h                            ; Restore stack
	mov       g_&name&_tracy_zone_ctx.id, eax     ; Store context id
	shr       rax, 20h                            ; Shift right to access the lower half
	mov       g_&name&_tracy_zone_ctx.active, eax ; Store context active

	; Restore registers
	pop       r12
	pop       rdx
	pop       rcx
	pop       rax

ENDM ; BEGIN_TRACY_ZONE

; Macro to end a tracy zone
END_TRACY_ZONE MACRO name

	; Store registers
	push      rax
	push      rcx
	push      rdx

	; Emit tracy zone end
	mov       edx, g_&name&_tracy_zone_ctx.id     ; Store context id into temporary
	mov       ecx, g_&name&_tracy_zone_ctx.active ; Store context active
	shl       rcx, 20h                            ; Shift context active into upper half
	or        rcx, rdx                            ; Store context id
	sub       rsp, 28h                            ; Allocate shadow space and align stack
	call      ___tracy_emit_zone_end              ; Emit tracy zone end
	add       rsp, 28h                            ; Restore stack

	; Restore registers
	pop       rdx
	pop       rcx
	pop       rax

ENDM ; END_TRACY_ZONE

; Macro to define a tracy frame name
TRACY_FRAME_NAME MACRO name, name_as_string

	.DATA

	ALIGN 4h
	g_&name&_proc_name BYTE name_as_string, 0

ENDM ; TRACY_FRAME_NAME

; Macro to start a tracy frame
BEGIN_TRACY_FRAME MACRO name

	; Store registers
	push      rax
	push      rcx

	; Emit tracy frame mark start
	lea       rcx, g_&name&_proc_name        ; [ARG0] name
	sub       rsp, 20h                       ; Allocate shadow space and align stack
	call      ___tracy_emit_frame_mark_start ; Emit tracy frame mark start
	add       rsp, 20h                       ; Restore stack

	; Store registers
	pop       rcx
	pop       rax

ENDM ; BEGIN_TRACY_FRAME

; Macro to end a tracy frame
END_TRACY_FRAME MACRO name

	; Store registers
	push      rax
	push      rcx

	; Emit tracy frame mark end
	lea       rcx, g_&name&_proc_name      ; [ARG0] name
	sub       rsp, 28h                     ; Allocate shadow space and align stack
	call      ___tracy_emit_frame_mark_end ; Emit tracy frame mark end
	add       rsp, 28h                     ; Restore stack

	; Store registers
	pop       rcx
	pop       rax

ENDM ; END_TRACY_FRAME

ENDIF ; __DEBUG

ENDIF ; __CORE_MACROS
