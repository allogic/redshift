IFNDEF __ENGINE_CONTEXT

__ENGINE_CONTEXT EQU 1

IFNDEF __ENGINE_CONTEXT_IMPL

	EXTERN g_window_should_close : QWORD

ENDIF ; __ENGINE_CONTEXT_IMPL

; #################################################################
; ### Global API
; #################################################################

context_create PROTO
context_poll_events PROTO
context_destroy PROTO

; #################################################################
; ### Internal API
; #################################################################

context_create_win32_window PROTO
context_create_vulkan_instance PROTO
context_create_vulkan_surface PROTO

context_destroy_win32_window PROTO
context_destroy_vulkan_instance PROTO
context_destroy_vulkan_surface PROTO

context_win32_message_procedure PROTO
context_vulkan_debug_procedure PROTO

ENDIF ; __ENGINE_CONTEXT
