IFNDEF __CORE_CONSOLE

__CORE_CONSOLE EQU 1

;
; Global API
;

console_initialize proto
console_log proto format:qword, num_args:qword
console_restore proto

ENDIF ; __CORE_CONSOLE
