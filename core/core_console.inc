IFNDEF __CORE_CONSOLE

__CORE_CONSOLE EQU 1

;
; Global API
;

console_initialize proto ; void(*)(void)
console_log proto ; void(*)(char const* format, long long unsigned num_args, ...)
console_restore proto ; void(*)(void)

;
; Internal API
;

console_write proto ; void(*)(void)

ENDIF ; __CORE_CONSOLE
