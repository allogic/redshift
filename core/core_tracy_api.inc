IFNDEF __CORE_TRACY_API

__CORE_TRACY_API EQU 1

___tracy_c_zone_context struct
	id     dword 0
	active dword 0
___tracy_c_zone_context ends

___tracy_source_location_data struct
	loc_name    qword 0
	func_name   qword 0
	file_name   qword 0
	line_number dword 0
	color       dword 0
___tracy_source_location_data ends

extern ___tracy_set_thread_name       : proc
extern ___tracy_emit_zone_begin       : proc
extern ___tracy_emit_zone_end         : proc
extern ___tracy_emit_frame_mark       : proc
extern ___tracy_emit_frame_mark_start : proc
extern ___tracy_emit_frame_mark_end   : proc

ENDIF ; __CORE_TRACY_API
