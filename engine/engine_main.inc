IFNDEF __ENGINE_MAIN

__ENGINE_MAIN EQU 1

;
; Global API
;

engine_initialize proto
engine_loop proto

;
; Entry Point
;

main proto argc:dword, argv:qword, envp:qword

ENDIF ; __ENGINE_MAIN
