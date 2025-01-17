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

g_window_name         byte       "Redshift", 0
g_window_class_name   byte       "RedshiftClass", 0
g_window_class        WNDCLASSEX <>
g_window_message      MSG        <>
g_window_handle       qword      0
g_window_should_close qword      0

public g_window_should_close

.code

;
; Window Inititalize
;
window_initialize proc

	FUNCTION_PROLOGUE

	; Temporary variables
	lea       r12, g_window_class_name ; Temporary to hold window class name
	lea       r13, window_procedure    ; Temporary to hold window proc

	; Get first module instance
	sub       rsp, 28h                      ; Allocate shadow space and align stack
	xor       rcx, rcx                      ; [ARG0] lpModuleName
	call      GetModuleHandleA              ; Get module handle
	add       rsp, 28h                      ; Restore stack
	mov       g_window_class.hInstance, rax ; Store module instance

	; Load cursor
	sub       rsp, 28h                    ; Allocate shadow space and align stack
	mov       rdx, IDC_ARROW              ; [ARG1] lpCursorName
	xor       rcx, rcx                    ; [ARG0] hInstance
	call      LoadCursorA                 ; Load cursor
	add       rsp, 28h                    ; Restore stack
	mov       g_window_class.hCursor, rax ; Store cursor

	; Load icon
	sub       rsp, 28h                    ; Allocate shadow space and align stack
	mov       rdx, IDI_APPLICATION        ; [ARG1] lpIconName
	xor       rcx, rcx                    ; [ARG0] hInstance
	call      LoadIconA                   ; Load icon
	add       rsp, 28h                    ; Restore stack
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
	sub       rsp, 28h            ; Allocate shadow space and align stack
	lea       rcx, g_window_class ; [ARG0] unnamedParam1
	call      RegisterClassExA    ; Register class
	add       rsp, 28h            ; Restore stack

	FUNCTION_EPILOGUE

	ret

window_initialize endp

;
; Window Create
;
window_create proc

	FUNCTION_PROLOGUE

	; Create window
	sub       rsp, 8h                  ; Align stack
	push      0                        ; [ARG11] lpParam
	push      g_window_class.hInstance ; [ARG10] hInstance
	push      0                        ; [ARG9] hMenu
	push      0                        ; [ARG8] hWndParent
	push      1080                     ; [ARG7] nHeight
	push      1920                     ; [ARG6] nWidth
	push      CW_USEDEFAULT            ; [ARG5] Y
	push      CW_USEDEFAULT            ; [ARG4] X
	sub       rsp, 20h                 ; Allocate shadow space
	mov       r9, WS_DEFAULT           ; [ARG3] dwStyle
	lea       r8, g_window_name        ; [ARG2] lpWindowName
	lea       rdx, g_window_class_name ; [ARG1] lpClassName
	xor       rcx, rcx                 ; [ARG0] dwExStyle
	call      CreateWindowExA          ; Create window
	add       rsp, 68h                 ; Restore stack
	mov       g_window_handle, rax     ; Store window handle

	; Show window
	sub       rsp, 28h             ; Allocate shadow space and align stack
	mov       rdx, SW_SHOW         ; [ARG1] nCmdShow
	mov       rcx, g_window_handle ; [ARG0] hWnd
	call      ShowWindow           ; Show window
	add       rsp, 28h             ; Restore stack

	; Update window
	sub       rsp, 28h             ; Allocate shadow space and align stack
	mov       rcx, g_window_handle ; [ARG0] hWnd
	call      UpdateWindow         ; Update window
	add       rsp, 28h             ; Restore stack

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
	sub       rsp, 20h              ; Allocate shadow space
	xor       r9, r9                ; [ARG3] wMsgFilterMax
	xor       r8, r8                ; [ARG2] wMsgFilterMin
	xor       rdx, rdx              ; [ARG1] hWnd
	lea       rcx, g_window_message ; [ARG0] lpMsg
	call      PeekMessageA          ; Peak message
	add       rsp, 28h              ; Restore stack
	cmp       rax, 0                ; Check if message is available
	je        no_message_available  ; Skip if no message is available

	; Translate current message
	sub       rsp, 28h              ; Allocate shadow space and align stack
	lea       rcx, g_window_message ; [ARG0] lpMsg
	call      TranslateMessage      ; Translate current message
	add       rsp, 28h              ; Restore stack

	; Dispatch current message
	sub       rsp, 28h              ; Allocate shadow space and align stack
	lea       rcx, g_window_message ; [ARG0] lpMsg
	call      DispatchMessageA      ; Dispatch current message
	add       rsp, 28h              ; Restore stack

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
	; sub       rsp, 28h             ; Allocate shadow space and align stack
	; mov       rcx, g_window_handle ; [ARG0] hWnd
	; call      DestroyWindow        ; Destroy window
	; add       rsp, 28h             ; Restore stack

	; Unregister window class
	; sub       rsp, 28h                      ; Allocate shadow space and align stack
	; lea       rdx, g_window_class.hInstance ; [ARG1] hInstance
	; lea       rcx, g_window_class_name      ; [ARG0] lpClassName
	; call      UnregisterClassA              ; Unregister class
	; add       rsp, 28h                      ; Restore stack

	FUNCTION_EPILOGUE

	ret

window_destroy endp

;
; Window Procedure
;
window_procedure proc hWin:qword, uMsg:dword, wParam:qword, lParam:qword

	FUNCTION_PROLOGUE

	; Temporary variables
	mov       r12, rcx ; Temporary to hold window handle
	mov       r13, rdx ; Temporary to hold message
	mov       r14, r8  ; Temporary to hold wParam
	mov       r15, r9  ; Temporary to hold lParam

	; Switch message type
	cmp       edx, WM_DESTROY
	je        handle_destroy_msg
	cmp       edx, WM_SIZE
	je        handle_resize_msg

	; Default window procedure
	sub       rsp, 28h       ; Allocate shadow space and align stack
	mov       r9, r15        ; [ARG3] lParam
	mov       r8, r14        ; [ARG2] wParam
	mov       rdx, r13       ; [ARG1] Msg
	mov       rcx, r12       ; [ARG0] hWnd
	call      DefWindowProcA ; Default window procedure
	add       rsp, 28h       ; Restore stack

	FUNCTION_EPILOGUE

	ret

handle_destroy_msg:

	mov       g_window_should_close, 1 ; Set window should close
	xor       rax, rax                 ; Return 0

	FUNCTION_EPILOGUE

	ret

handle_resize_msg:

	xor       rax, rax ; Return 0

	FUNCTION_EPILOGUE

	ret

window_procedure endp

end
