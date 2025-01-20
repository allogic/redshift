IFNDEF __CORE_TRACY_API

__CORE_TRACY_API EQU 1

extern ___tracy_set_thread_name       : proc
extern ___tracy_emit_frame_mark       : proc
extern ___tracy_emit_frame_mark_start : proc
extern ___tracy_emit_frame_mark_end   : proc

ENDIF ; __CORE_TRACY_API
