IFNDEF __ENGINE_CONTEXT

__ENGINE_CONTEXT EQU 1

IFNDEF __ENGINE_CONTEXT_IMPL

extern g_window_should_close : qword

ENDIF ; __ENGINE_CONTEXT_IMPL

;
; Global API
;

context_create proto
context_poll_events proto
context_destroy proto

;
; Internal API
;

context_create_win32_window proto
context_create_vulkan_instance proto
context_create_vulkan_surface proto

context_destroy_win32_window proto
context_destroy_vulkan_instance proto
context_destroy_vulkan_surface proto

context_win32_message_procedure proto hWin:qword, uMsg:dword, wParam:qword, lParam:qword
context_vulkan_debug_procedure proto messageSeverity:dword, messageTypes:dword, pCallbackData:qword, pUserData:qword

ENDIF ; __ENGINE_CONTEXT
