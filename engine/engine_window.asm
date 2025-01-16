INCLUDE core_macros.inc

__ENGINE_WINDOW_IMPL EQU 1
INCLUDE engine_window.inc

CS_VREDRAW EQU 1h
CS_HREDRAW EQU 2h
CS_OWNDC EQU 20h

COLOR_WINDOW EQU 5h

WS_OVERLAPPED EQU 0h
WS_MAXIMIZEBOX EQU 10000h
WS_MINIMIZEBOX EQU 20000h
WS_THICKFRAME EQU 40000h
WS_SYSMENU EQU 80000h
WS_CAPTION EQU 0C00000h
WS_CLIPCHILDREN EQU 2000000h
WS_CLIPSIBLINGS EQU 4000000h

SW_SHOW EQU 5h

extern GetModuleHandleA : proc
extern RegisterClassExA : proc
extern UnregisterClassA : proc
extern CreateWindowExA : proc
extern ShowWindow : proc
extern UpdateWindow : proc
extern DestroyWindow : proc

WNDCLASSEX struct
	cbSize dword 0
	style dword 0
	lpfnWndProc qword 0
	cbClsExtra dword 0
	cbWndExtra dword 0
	hInstance qword 0
	hIcon qword 0
	hCursor qword 0
	hbrBackground qword 0
	lpszMenuName qword 0
	lpszClassName qword 0
	hIconSm qword 0
WNDCLASSEX ends

.data

g_window_name byte "Redshift", 0
g_window_class_name byte "RedshiftClass", 0
g_window_class_ex WNDCLASSEX <>
g_window_handle qword 0
g_window_should_close qword 0

public g_window_should_close

.code

;
; Window Alloc
;
window_alloc proc

	FUNCTION_PROLOGUE

	lea r12, g_window_name ; Temporary to hold window name
	lea r13, g_window_class_name ; Temporary to hold window class name
	lea r14, window_proc ; Temporary to hold window proc

	; Get first module handle
	CALL_PROLOGUE_IMM 0h
	xor rcx, rcx ; [ARG0] lpModuleName
	call GetModuleHandleA
	mov qword ptr [g_window_class_ex.hInstance], rax ; Store module instance
	CALL_EPILOGUE_IMM 0h

	; Fill out rest of window class structure
	mov dword ptr [g_window_class_ex.cbSize], SIZEOF WNDCLASSEX
	mov dword ptr [g_window_class_ex.style], CS_VREDRAW OR CS_HREDRAW OR CS_OWNDC
	mov qword ptr [g_window_class_ex.lpfnWndProc], r14
	mov dword ptr [g_window_class_ex.cbClsExtra], 0
	mov dword ptr [g_window_class_ex.cbWndExtra], 0
	mov qword ptr [g_window_class_ex.hIcon], 0
	mov qword ptr [g_window_class_ex.hCursor], 0
	mov qword ptr [g_window_class_ex.hbrBackground], COLOR_WINDOW
	mov qword ptr [g_window_class_ex.lpszMenuName], 0
	mov qword ptr [g_window_class_ex.lpszClassName], r13
	mov qword ptr [g_window_class_ex.hIconSm], 0

	; Register window class
	CALL_PROLOGUE_IMM 0h
	lea rcx, g_window_class_ex ; [ARG0] unnamedParam1
	call RegisterClassExA
	CALL_EPILOGUE_IMM 0h

	; Create window
	CALL_PROLOGUE_IMM 40h
	xor rcx, rcx ; [ARG0] dwExStyle
	mov rdx, r13; [ARG1] lpClassName
	mov r8, r12; [ARG2] lpWindowName
	mov r9, WS_OVERLAPPED OR WS_MAXIMIZEBOX OR WS_MINIMIZEBOX OR WS_THICKFRAME OR WS_SYSMENU OR WS_CAPTION OR WS_CLIPCHILDREN OR WS_CLIPSIBLINGS ; [ARG3] dwStyle
	mov dword ptr [rsp], 100 ; [ARG4] X
	mov dword ptr [rsp + 8h], 100 ; [ARG5] Y
	mov dword ptr [rsp + 10h], 1920 ; [ARG6] nWidth
	mov dword ptr [rsp + 18h], 1080 ; [ARG7] nHeight
	mov qword ptr [rsp + 20h], 0 ; [ARG8] hWndParent
	mov qword ptr [rsp + 28h], 0 ; [ARG9] hMenu
	mov rax, g_window_class_ex.hInstance
	mov qword ptr [rsp + 30h], rax ; [ARG10] hInstance
	mov qword ptr [rsp + 38h], 0 ; [ARG11] lpParam
	call CreateWindowExA
	mov g_window_handle, rax ; Store window handle
	CALL_EPILOGUE_IMM 40h

	; Show window
	CALL_PROLOGUE_IMM 0h
	lea rcx, g_window_class_ex ; [ARG0] hWnd
	xor rdx, rdx ; [ARG1] nCmdShow
	call ShowWindow
	CALL_EPILOGUE_IMM 0h

	; Update window
	CALL_PROLOGUE_IMM 0h
	lea rcx, g_window_class_ex ; [ARG0] hWnd
	call UpdateWindow
	CALL_EPILOGUE_IMM 0h

	FUNCTION_EPILOGUE

	ret

window_alloc endp

;
; Window Free
;
window_free proc

	FUNCTION_PROLOGUE

	; Destroy window
	CALL_PROLOGUE_IMM 0h
	lea rcx, g_window_class_ex ; [ARG0] hWnd
	call UpdateWindow
	CALL_EPILOGUE_IMM 0h

	; Unregister window class
	CALL_PROLOGUE_IMM 0h
	lea rcx, g_window_class_name ; [ARG0] lpClassName
	mov rax, g_window_class_ex.hInstance
	mov rdx, rax ; [ARG1] hInstance
	call UnregisterClassA
	CALL_EPILOGUE_IMM 0h

	FUNCTION_EPILOGUE

	ret

window_free endp

;
; Window Proc
;
window_proc proc

	FUNCTION_PROLOGUE

	; TODO

	FUNCTION_EPILOGUE

	xor rax, rax ; Discard return

	ret

window_proc endp

end
