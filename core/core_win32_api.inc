IFNDEF __CORE_WIN32_API

__CORE_WIN32_API EQU 1

PAGE_SIZE EQU 1000h

MEM_COMMIT  EQU 1000h
MEM_RESERVE EQU 2000h
MEM_RELEASE EQU 8000h

PAGE_READWRITE EQU 4h

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

extern VirtualAlloc     : proc
extern VirtualFree      : proc
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

ENDIF ; __CORE_WIN32_API
