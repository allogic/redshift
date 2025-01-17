IFNDEF __ENGINE_WINDOW

__ENGINE_WINDOW EQU 1

IFNDEF __ENGINE_WINDOW_IMPL

	extern g_window_should_close : qword

ENDIF ; __ENGINE_WINDOW_IMPL

;
; Global API
;

window_initialize proto
window_create proto
window_poll_events proto
window_destroy proto

;
; Internal API
;

window_procedure proto hWin:qword, uMsg:dword, wParam:qword, lParam:qword

ENDIF ; __ENGINE_WINDOW
