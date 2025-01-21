IFNDEF __CORE_TRACY_API

__CORE_TRACY_API EQU 1

___tracy_c_zone_context STRUCT
	id     DWORD 0
	active DWORD 0
___tracy_c_zone_context ENDS

___tracy_source_location_data STRUCT
	loc_name    QWORD 0
	func_name   QWORD 0
	file_name   QWORD 0
	line_number DWORD 0
	color       DWORD 0
___tracy_source_location_data ENDS

EXTERN ___tracy_startup_profiler      : PROC
EXTERN ___tracy_shutdown_profiler     : PROC
EXTERN ___tracy_set_thread_name       : PROC
EXTERN ___tracy_emit_zone_begin       : PROC
EXTERN ___tracy_emit_zone_end         : PROC
EXTERN ___tracy_emit_frame_mark_start : PROC
EXTERN ___tracy_emit_frame_mark_end   : PROC

ENDIF ; __CORE_TRACY_API
