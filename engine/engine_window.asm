INCLUDE core_macros.inc

__ENGINE_WINDOW_IMPL EQU 1
INCLUDE engine_window.inc

CS_VREDRAW EQU 1h
CS_HREDRAW EQU 2h
CS_OWNDC   EQU 20h

CW_USEDEFAULT EQU 80000000h

COLOR_WINDOW EQU 5h

WS_OVERLAPPED   EQU 0h
WS_MAXIMIZEBOX  EQU 10000h
WS_MINIMIZEBOX  EQU 20000h
WS_THICKFRAME   EQU 40000h
WS_SYSMENU      EQU 80000h
WS_CAPTION      EQU 0C00000h
WS_CLIPCHILDREN EQU 2000000h
WS_CLIPSIBLINGS EQU 4000000h

WS_DEFAULT EQU WS_OVERLAPPED OR WS_MAXIMIZEBOX OR WS_MINIMIZEBOX OR WS_THICKFRAME OR WS_SYSMENU OR WS_CAPTION OR WS_CLIPCHILDREN OR WS_CLIPSIBLINGS

SW_SHOW EQU 5h

PM_REMOVE EQU 1h

IDI_APPLICATION EQU 7F00h

IDC_ARROW EQU 7F00h

WM_CREATE  EQU 1h
WM_DESTROY EQU 2h
WM_SIZE    EQU 5h

extern GetModuleHandleA : proc
extern RegisterClassExA : proc
extern UnregisterClassA : proc
extern DefWindowProcA   : proc
extern CreateWindowExA  : proc
extern PeekMessageA     : proc
extern LoadCursorA      : proc
extern LoadIconA        : proc
extern TranslateMessage : proc
extern DispatchMessageA : proc
extern ShowWindow       : proc
extern UpdateWindow     : proc
extern DestroyWindow    : proc

WNDCLASSEX struct
	cbSize        dword 0
	style         dword 0
	lpfnWndProc   qword 0
	cbClsExtra    dword 0
	cbWndExtra    dword 0
	hInstance     qword 0
	hIcon         qword 0
	hCursor       qword 0
	hbrBackground qword 0
	lpszMenuName  qword 0
	lpszClassName qword 0
	hIconSm       qword 0
WNDCLASSEX ends

POINT struct
	x qword 0
	y qword 0
POINT ends

MSG struct
	hwnd     qword 0
	message  dword 0
	wParam   qword 0
	lParam   qword 0
	time     dword 0
	pt       POINT <>
	lPrivate dword 0
MSG ends

.data

align 4h
g_window_name byte "Redshift", 0

align 4h
g_window_class_name byte "RedshiftClass", 0

align 4h
g_window_class WNDCLASSEX <>

align 4h
g_window_message MSG <>

align 4h
g_window_handle qword 0

align 4h
g_window_should_close qword 0

public g_window_should_close

.code

;
; Window Inititalize
;
window_initialize proc

	FUNCTION_PROLOGUE

	lea       r12, g_window_class_name ; Store window class name into temporary
	lea       r13, window_procedure    ; Store window proc into temporary

	; Get first module instance
	xor       rcx, rcx                      ; [ARG0] lpModuleName
	sub       rsp, 20h                      ; Allocate shadow space and align stack
	call      GetModuleHandleA              ; Get module handle
	add       rsp, 20h                      ; Restore stack
	mov       g_window_class.hInstance, rax ; Store module instance

	; Load cursor
	mov       rdx, IDC_ARROW              ; [ARG1] lpCursorName
	xor       rcx, rcx                    ; [ARG0] hInstance
	sub       rsp, 20h                    ; Allocate shadow space and align stack
	call      LoadCursorA                 ; Load cursor
	add       rsp, 20h                    ; Restore stack
	mov       g_window_class.hCursor, rax ; Store cursor

	; Load icon
	mov       rdx, IDI_APPLICATION        ; [ARG1] lpIconName
	xor       rcx, rcx                    ; [ARG0] hInstance
	sub       rsp, 20h                    ; Allocate shadow space and align stack
	call      LoadIconA                   ; Load icon
	add       rsp, 20h                    ; Restore stack
	mov       g_window_class.hIconSm, rax ; Store icon
	mov       g_window_class.hIcon, rax   ; Store icon

	; Fill rest of window class structure
	mov       g_window_class.cbSize, SIZEOF WNDCLASSEX
	mov       g_window_class.style, CS_VREDRAW OR CS_HREDRAW OR CS_OWNDC
	mov       g_window_class.lpfnWndProc, r13
	mov       g_window_class.cbClsExtra, 0
	mov       g_window_class.cbWndExtra, 0
	mov       g_window_class.hbrBackground, COLOR_WINDOW
	mov       g_window_class.lpszMenuName, 0
	mov       g_window_class.lpszClassName, r12

	; Register window class
	lea       rcx, g_window_class ; [ARG0] unnamedParam1
	sub       rsp, 20h            ; Allocate shadow space and align stack
	call      RegisterClassExA    ; Register class
	add       rsp, 20h            ; Restore stack

	FUNCTION_EPILOGUE

	ret

window_initialize endp

;
; Window Create
;
window_create proc

	FUNCTION_PROLOGUE

	; Create window
	push      0                        ; [ARG11] lpParam
	push      g_window_class.hInstance ; [ARG10] hInstance
	push      0                        ; [ARG9] hMenu
	push      0                        ; [ARG8] hWndParent
	push      1080                     ; [ARG7] nHeight
	push      1920                     ; [ARG6] nWidth
	push      CW_USEDEFAULT            ; [ARG5] Y
	push      CW_USEDEFAULT            ; [ARG4] X
	mov       r9, WS_DEFAULT           ; [ARG3] dwStyle
	lea       r8, g_window_name        ; [ARG2] lpWindowName
	lea       rdx, g_window_class_name ; [ARG1] lpClassName
	xor       rcx, rcx                 ; [ARG0] dwExStyle
	sub       rsp, 20h                 ; Allocate shadow space and align stack
	call      CreateWindowExA          ; Create window
	add       rsp, 60h                 ; Restore stack
	mov       g_window_handle, rax     ; Store window handle

	; Show window
	mov       rdx, SW_SHOW         ; [ARG1] nCmdShow
	mov       rcx, g_window_handle ; [ARG0] hWnd
	sub       rsp, 20h             ; Allocate shadow space and align stack
	call      ShowWindow           ; Show window
	add       rsp, 20h             ; Restore stack

	; Update window
	mov       rcx, g_window_handle ; [ARG0] hWnd
	sub       rsp, 20h             ; Allocate shadow space and align stack
	call      UpdateWindow         ; Update window
	add       rsp, 20h             ; Restore stack

	FUNCTION_EPILOGUE

	ret

window_create endp

;
; Window Poll Events
;
window_poll_events proc

	FUNCTION_PROLOGUE

	; Peek next message
	push      PM_REMOVE             ; [ARG4] wRemoveMsg
	xor       r9, r9                ; [ARG3] wMsgFilterMax
	xor       r8, r8                ; [ARG2] wMsgFilterMin
	xor       rdx, rdx              ; [ARG1] hWnd
	lea       rcx, g_window_message ; [ARG0] lpMsg
	sub       rsp, 20h              ; Allocate shadow space and align stack
	call      PeekMessageA          ; Peak message
	add       rsp, 20h              ; Restore stack
	cmp       rax, 0                ; Check if message is available
	je        no_message_available  ; Skip if no message is available

	; Translate current message
	lea       rcx, g_window_message ; [ARG0] lpMsg
	sub       rsp, 20h              ; Allocate shadow space and align stack
	call      TranslateMessage      ; Translate current message
	add       rsp, 20h              ; Restore stack

	; Dispatch current message
	lea       rcx, g_window_message ; [ARG0] lpMsg
	sub       rsp, 20h              ; Allocate shadow space and align stack
	call      DispatchMessageA      ; Dispatch current message
	add       rsp, 20h              ; Restore stack

no_message_available:

	FUNCTION_EPILOGUE

	ret

window_poll_events endp

;
; Window Destroy
;
window_destroy proc

	FUNCTION_PROLOGUE

	; Destroy window
	mov       rcx, g_window_handle ; [ARG0] hWnd
	sub       rsp, 20h             ; Allocate shadow space and align stack
	call      DestroyWindow        ; Destroy window
	add       rsp, 20h             ; Restore stack

	; Unregister window class
	mov       rdx, g_window_handle     ; [ARG1] hInstance
	lea       rcx, g_window_class_name ; [ARG0] lpClassName
	sub       rsp, 20h                 ; Allocate shadow space and align stack
	call      UnregisterClassA         ; Unregister class
	add       rsp, 20h                 ; Restore stack

	FUNCTION_EPILOGUE

	ret

window_destroy endp

;
; Window Procedure
;
window_procedure proc hWin:qword, uMsg:dword, wParam:qword, lParam:qword

	mov       r12, rcx ; Store window handle into temporary
	mov       r13, rdx ; Store message into temporary
	mov       r14, r8  ; Store wParam into temporary
	mov       r15, r9  ; Store lParam into temporary

	; Switch message type
	cmp       edx, WM_DESTROY
	je        handle_destroy_msg
	cmp       edx, WM_SIZE
	je        handle_resize_msg

	; Handle default window procedure
	mov       r9, r15        ; [ARG3] lParam
	mov       r8, r14        ; [ARG2] wParam
	mov       rdx, r13       ; [ARG1] Msg
	mov       rcx, r12       ; [ARG0] hWnd
	sub       rsp, 20h       ; Allocate shadow space and align stack
	call      DefWindowProcA ; Default window procedure
	add       rsp, 20h       ; Restore stack
	ret

handle_destroy_msg:

	; Handle window destroy
	mov       g_window_should_close, 1 ; Set window should close
	xor       rax, rax                 ; Return 0
	ret

handle_resize_msg:

	; Handle window resize
	xor       rax, rax ; Return 0
	ret

window_procedure endp

end
