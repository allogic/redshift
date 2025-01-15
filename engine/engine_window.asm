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

extern GetModuleHandleA : proc
extern RegisterClassExA : proc
extern CreateWindowExA : proc

WNDCLASSEX struct
	cbSize dword ?
	style dword ?
	lpfnWndProc qword ?
	cbClsExtra dword ?
	cbWndExtra dword ?
	hInstance qword ?
	hIcon qword ?
	hCursor qword ?
	hbrBackground qword ?
	lpszMenuName qword ?
	lpszClassName qword ?
	hIconSm qword ?
WNDCLASSEX ends

.data

g_window_class_ex WNDCLASSEX {}

.code

window_proc proc
	xor rax, rax ; Return 0
	ret
window_proc endp

window_alloc proc
	sub rsp, 28h ; Align stack to 16-byte boundary

	mov rbx, rcx ; Temporary to hold window title
	lea rdi, window_proc ; Temporary to hold window proc

	xor rcx, rcx ; lpModuleName
	call GetModuleHandleA

	mov dword ptr [g_window_class_ex.cbSize], SIZEOF WNDCLASSEX
	mov dword ptr [g_window_class_ex.style], CS_VREDRAW OR CS_HREDRAW OR CS_OWNDC
	mov qword ptr [g_window_class_ex.lpfnWndProc], rdi
	mov dword ptr [g_window_class_ex.cbClsExtra], 0
	mov dword ptr [g_window_class_ex.cbWndExtra], 0
	mov qword ptr [g_window_class_ex.hInstance], rax
	mov qword ptr [g_window_class_ex.hIcon], 0
	mov qword ptr [g_window_class_ex.hCursor], 0
	mov qword ptr [g_window_class_ex.hbrBackground], COLOR_WINDOW
	mov qword ptr [g_window_class_ex.lpszMenuName], 0
	mov qword ptr [g_window_class_ex.lpszClassName], rbx
	mov qword ptr [g_window_class_ex.hIconSm], 0

	lea rcx, g_window_class_ex ; unnamedParam1
	call RegisterClassExA

	xor rcx, rcx ; dwExStyle
	mov rdx, rbx; lpClassName
	mov r8, rbx; lpWindowName
	mov r9, WS_OVERLAPPED OR WS_MAXIMIZEBOX OR WS_MINIMIZEBOX OR WS_THICKFRAME OR WS_SYSMENU OR WS_CAPTION OR WS_CLIPCHILDREN OR WS_CLIPSIBLINGS ; dwStyle
	sub rsp, 64
	mov dword ptr [rsp], 100 ; X
	mov dword ptr [rsp + 8], 100 ; Y
	mov dword ptr [rsp + 16], 1920 ; nWidth
	mov dword ptr [rsp + 24], 1080 ; nHeight
	mov qword ptr [rsp + 32], 0 ; hWndParent
	mov qword ptr [rsp + 40], 0 ; hMenu
	mov rax, g_window_class_ex.hInstance
	mov qword ptr [rsp + 48], rax ; hInstance
	mov qword ptr [rsp + 56], 0 ; lpParam
	call CreateWindowExA
	add rsp, 64

	add rsp, 28h ; Restore stack alignment
	ret
window_alloc endp

window_free proc
	ret
window_free endp

end
