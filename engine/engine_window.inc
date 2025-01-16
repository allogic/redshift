IFNDEF __ENGINE_WINDOW

__ENGINE_WINDOW EQU 1

IFNDEF __ENGINE_WINDOW_IMPL

	extern g_window_should_close : qword

ENDIF ; __ENGINE_WINDOW_IMPL

;
; Global API
;

window_alloc proto ; void*(*)(char const* title, long long unsigned width, long long unsigned height)
window_free proto ; void(*)(void* window)

;
; Internal API
;

window_proc proto ; long long unsigned(*)(void)

ENDIF ; __ENGINE_WINDOW
