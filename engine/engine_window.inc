IFNDEF __ENGINE_WINDOW

__ENGINE_WINDOW EQU 1

window_proc proto ; long long unsigned(*)(void)
window_alloc proto ; void*(*)(char const* title, long long unsigned width, long long unsigned height)
window_free proto ; void(*)(void* window)

ENDIF ; __ENGINE_WINDOW
