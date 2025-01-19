INCLUDE core_common_macros.inc
INCLUDE core_crt.inc
INCLUDE core_vulkan_api.inc
INCLUDE core_win32_api.inc

__ENGINE_CONTEXT_IMPL EQU 1
INCLUDE engine_context.inc

WINDOW_WIDTH  EQU 1920
WINDOW_HEIGHT EQU 1080

.data

ALIGN 4h
g_window_name byte "Redshift", 0

ALIGN 4h
g_window_class_name byte "RedshiftClass", 0

ALIGN 4h
g_window_class WNDCLASSEX <>

ALIGN 4h
g_window_message MSG <>

ALIGN 4h
g_window_hwnd qword 0

ALIGN 4h
g_window_should_close qword 0

ALIGN 4h
g_vulkan_application_name byte "RedshiftApplication", 0

ALIGN 4h
g_vulkan_engine_name byte "RedshiftEngine", 0

ALIGN 4h
g_vulkan_application_info VkApplicationInfo <>

ALIGN 4h
g_vulkan_instance_create_info VkInstanceCreateInfo <>

ALIGN 4h
g_vulkan_extension_layer_khr_surface byte "VK_KHR_surface", 0

ALIGN 4h
g_vulkan_extension_layer_khr_win32_surface byte "VK_KHR_win32_surface", 0

IFDEF __DEBUG

	ALIGN 4h
	g_vulkan_extension_layer_ext_debug_utils byte "VK_EXT_debug_utils", 0

	ALIGN 4h
	g_vulkan_extension_layer_count qword 3h

	ALIGN 4h
	g_vulkan_extension_layers qword \
		g_vulkan_extension_layer_khr_surface,
		g_vulkan_extension_layer_khr_win32_surface,
		g_vulkan_extension_layer_ext_debug_utils,
		0

ELSE

	ALIGN 4h
	g_vulkan_extension_layer_count qword 2h

	ALIGN 4h
	g_vulkan_extension_layers qword \
		g_vulkan_extension_layer_khr_surface,
		g_vulkan_extension_layer_khr_win32_surface,
		0

ENDIF ; __DEBUG

ALIGN 4h
g_vulkan_debug_utils_messenger_create_info VkDebugUtilsMessengerCreateInfoEXT <>

IFDEF __DEBUG

	ALIGN 4h
	g_vulkan_validation_layer_khronos_validation byte "VK_LAYER_KHRONOS_validation", 0

	ALIGN 4h
	g_vulkan_validation_layer_count qword 1h

	ALIGN 4h
	g_vulkan_validation_layers qword \
		g_vulkan_validation_layer_khronos_validation,
		0

ENDIF ; __DEBUG

IFDEF __DEBUG

	ALIGN 4h
	g_vulkan_create_debug_utils_messenger_proc_name byte "vkCreateDebugUtilsMessengerEXT", 0

	ALIGN 4h
	g_vulkan_destroy_debug_utils_messenger_proc_name byte "vkDestroyDebugUtilsMessengerEXT", 0

	ALIGN 4h
	g_vulkan_create_debug_utils_messenger_proc qword 0

	ALIGN 4h
	g_vulkan_destroy_debug_utils_messenger_proc qword 0

	ALIGN 4h
	g_vulkan_debug_utils_messenger qword 0

ENDIF ; __DEBUG

ALIGN 4h
g_vulkan_instance qword 0

ALIGN 4h
g_vulkan_win32_surface_create_info_khr VkWin32SurfaceCreateInfoKHR <>

ALIGN 4h
g_vulkan_surface qword 0

;
; Public Variables
;

public g_window_should_close

.code

;
; Context Create
;
context_create proc

	FUNCTION_PROLOGUE

	; Create win32 window
	sub       rsp, 20h                    ; Allocate shadow space and align stack
	call      context_create_win32_window ; Create win32 window
	add       rsp, 20h                    ; Restore stack

	; Create vulkan instance
	sub       rsp, 20h                       ; Allocate shadow space and align stack
	call      context_create_vulkan_instance ; Create vulkan instance
	add       rsp, 20h                       ; Restore stack

	; Create vulkan surface
	sub       rsp, 20h                      ; Allocate shadow space and align stack
	call      context_create_vulkan_surface ; Create vulkan surface
	add       rsp, 20h                      ; Restore stack

	FUNCTION_EPILOGUE

	ret

context_create endp

;
; Context Poll Events
;
context_poll_events proc

	FUNCTION_PROLOGUE

	; Peek next message
	push      PM_REMOVE             ; [ARG4] wRemoveMsg
	xor       r9, r9                ; [ARG3] wMsgFilterMax
	xor       r8, r8                ; [ARG2] wMsgFilterMin
	xor       rdx, rdx              ; [ARG1] hWnd
	lea       rcx, g_window_message ; [ARG0] lpMsg
	sub       rsp, 20h              ; Allocate shadow space and align stack
	call      PeekMessageA          ; Peak message
	add       rsp, 20h              ; Restore stack
	cmp       rax, 0                ; Check if message is available
	je        no_message_available  ; Skip if no message is available

	; Translate current message
	lea       rcx, g_window_message ; [ARG0] lpMsg
	sub       rsp, 20h              ; Allocate shadow space and align stack
	call      TranslateMessage      ; Translate current message
	add       rsp, 20h              ; Restore stack

	; Dispatch current message
	lea       rcx, g_window_message ; [ARG0] lpMsg
	sub       rsp, 20h              ; Allocate shadow space and align stack
	call      DispatchMessageA      ; Dispatch current message
	add       rsp, 20h              ; Restore stack

no_message_available:

	FUNCTION_EPILOGUE

	ret

context_poll_events endp

;
; Context Destroy
;
context_destroy proc

	FUNCTION_PROLOGUE

	; Destroy vulkan surface
	sub       rsp, 20h                       ; Allocate shadow space and align stack
	call      context_destroy_vulkan_surface ; Destroy vulkan surface
	add       rsp, 20h                       ; Restore stack

	; Destroy vulkan instance
	sub       rsp, 20h                        ; Allocate shadow space and align stack
	call      context_destroy_vulkan_instance ; Destroy vulkan instance
	add       rsp, 20h                        ; Restore stack

	; Destroy win32 window
	sub       rsp, 20h                     ; Allocate shadow space and align stack
	call      context_destroy_win32_window ; Destroy win32 window
	add       rsp, 20h                     ; Restore stack

	FUNCTION_EPILOGUE

	ret

context_destroy endp

;
; Context Create Win32 Window
;

context_create_win32_window proc

	FUNCTION_PROLOGUE

	lea       r12, g_window_class_name             ; Store window class name into temporary
	lea       r13, context_win32_message_procedure ; Store window message proc into temporary

	; Get first module instance
	xor       rcx, rcx                      ; [ARG0] lpModuleName
	sub       rsp, 20h                      ; Allocate shadow space and align stack
	call      GetModuleHandleA              ; Get module handle
	add       rsp, 20h                      ; Restore stack
	mov       g_window_class.hInstance, rax ; Store module instance

	; Load cursor
	mov       rdx, IDC_ARROW              ; [ARG1] lpCursorName
	xor       rcx, rcx                    ; [ARG0] hInstance
	sub       rsp, 20h                    ; Allocate shadow space and align stack
	call      LoadCursorA                 ; Load cursor
	add       rsp, 20h                    ; Restore stack
	mov       g_window_class.hCursor, rax ; Store cursor

	; Load icon
	mov       rdx, IDI_APPLICATION        ; [ARG1] lpIconName
	xor       rcx, rcx                    ; [ARG0] hInstance
	sub       rsp, 20h                    ; Allocate shadow space and align stack
	call      LoadIconA                   ; Load icon
	add       rsp, 20h                    ; Restore stack
	mov       g_window_class.hIconSm, rax ; Store icon
	mov       g_window_class.hIcon, rax   ; Store icon

	; Fill rest of window class structure
	mov       g_window_class.cbSize, SIZEOF WNDCLASSEX
	mov       g_window_class.style, CS_VREDRAW OR CS_HREDRAW OR CS_OWNDC
	mov       g_window_class.lpfnWndProc, r13
	mov       g_window_class.cbClsExtra, 0
	mov       g_window_class.cbWndExtra, 0
	mov       g_window_class.hbrBackground, COLOR_WINDOW
	mov       g_window_class.lpszMenuName, 0
	mov       g_window_class.lpszClassName, r12

	; Register window class
	lea       rcx, g_window_class ; [ARG0] unnamedParam1
	sub       rsp, 20h            ; Allocate shadow space and align stack
	call      RegisterClassExA    ; Register class
	add       rsp, 20h            ; Restore stack

	; Create window
	push      0                        ; [ARG11] lpParam
	push      g_window_class.hInstance ; [ARG10] hInstance
	push      0                        ; [ARG9] hMenu
	push      0                        ; [ARG8] hWndParent
	push      WINDOW_HEIGHT            ; [ARG7] nHeight
	push      WINDOW_WIDTH             ; [ARG6] nWidth
	push      CW_USEDEFAULT            ; [ARG5] Y
	push      CW_USEDEFAULT            ; [ARG4] X
	mov       r9, WS_DEFAULT           ; [ARG3] dwStyle
	lea       r8, g_window_name        ; [ARG2] lpWindowName
	lea       rdx, g_window_class_name ; [ARG1] lpClassName
	xor       rcx, rcx                 ; [ARG0] dwExStyle
	sub       rsp, 20h                 ; Allocate shadow space and align stack
	call      CreateWindowExA          ; Create window
	add       rsp, 60h                 ; Restore stack
	mov       g_window_hwnd, rax       ; Store window handle

	; Show window
	mov       rdx, SW_SHOW       ; [ARG1] nCmdShow
	mov       rcx, g_window_hwnd ; [ARG0] hWnd
	sub       rsp, 20h           ; Allocate shadow space and align stack
	call      ShowWindow         ; Show window
	add       rsp, 20h           ; Restore stack

	; Update window
	mov       rcx, g_window_hwnd ; [ARG0] hWnd
	sub       rsp, 20h           ; Allocate shadow space and align stack
	call      UpdateWindow       ; Update window
	add       rsp, 20h           ; Restore stack

	FUNCTION_EPILOGUE

	ret

context_create_win32_window endp

;
; Context Create Vulkan Instance
;

context_create_vulkan_instance proc

	FUNCTION_PROLOGUE

	lea       r12, g_vulkan_application_name ; Store application name into temporary
	lea       r13, g_vulkan_engine_name      ; Store engine name into temporary

	; Fill application info
	mov       g_vulkan_application_info.sType, VK_STRUCTURE_TYPE_APPLICATION_INFO
	mov       g_vulkan_application_info.pApplicationName, r12
	mov       g_vulkan_application_info.applicationVersion, ((0 SHL 29) OR (1 SHL 22) OR (0 SHL 12) OR (0))
	mov       g_vulkan_application_info.pEngineName, r13
	mov       g_vulkan_application_info.engineVersion, ((0 SHL 29) OR (1 SHL 22) OR (0 SHL 12) OR (0))
	mov       g_vulkan_application_info.apiVersion, ((0 SHL 29) OR (1 SHL 22) OR (0 SHL 12) OR (0))

	lea       r12, g_vulkan_application_info      ; Store application info into temporary
	mov       r13, g_vulkan_extension_layer_count ; Store extension layer count into temporary
	lea       r14, g_vulkan_extension_layers      ; Store extension layers into temporary

	; Fill instance create info
	mov       g_vulkan_instance_create_info.sType, VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO
	mov       g_vulkan_instance_create_info.pApplicationInfo, r12
	mov       g_vulkan_instance_create_info.enabledExtensionCount, r13d
	mov       g_vulkan_instance_create_info.ppEnabledExtensionNames, r14

IFDEF __DEBUG

	lea       r12, g_vulkan_debug_utils_messenger_create_info ; Store debug utils messenger create info into temporary
	lea       r13, context_vulkan_debug_procedure             ; Store window message proc into temporary
	mov       r14, g_vulkan_validation_layer_count            ; Store validation layer count into temporary
	lea       r15, g_vulkan_validation_layers                 ; Store validation layers into temporary

	; Fill debug utils messenger create info
	mov       g_vulkan_debug_utils_messenger_create_info.sType, VK_STRUCTURE_TYPE_DEBUG_UTILS_MESSENGER_CREATE_INFO_EXT
	mov       g_vulkan_debug_utils_messenger_create_info.messageSeverity, VK_DEBUG_UTILS_MESSAGE_SEVERITY_WARNING_BIT_EXT OR VK_DEBUG_UTILS_MESSAGE_SEVERITY_ERROR_BIT_EXT
	mov       g_vulkan_debug_utils_messenger_create_info.messageType, VK_DEBUG_UTILS_MESSAGE_TYPE_GENERAL_BIT_EXT OR VK_DEBUG_UTILS_MESSAGE_TYPE_VALIDATION_BIT_EXT OR VK_DEBUG_UTILS_MESSAGE_TYPE_PERFORMANCE_BIT_EXT
	mov       g_vulkan_debug_utils_messenger_create_info.pfnUserCallback, r13

	; Extend instance create info
	mov       g_vulkan_instance_create_info.pNext, r12
	mov       g_vulkan_instance_create_info.enabledLayerCount, r14d
	mov       g_vulkan_instance_create_info.ppEnabledLayerNames, r15

ENDIF ; __DEBUG

	; Create vulkan instance
	lea       r8, g_vulkan_instance              ; [ARG2] pInstance
	xor       rdx, rdx                           ; [ARG1] pAllocator
	lea       rcx, g_vulkan_instance_create_info ; [ARG0] pCreateInfo
	sub       rsp, 20h                           ; Allocate shadow space and align stack
	call      vkCreateInstance                   ; Create instance
	add       rsp, 20h                           ; Restore stack

IFDEF __DEBUG

	; Get create debug utils messenger extension proc address
	lea       rdx, g_vulkan_create_debug_utils_messenger_proc_name ; [ARG0] pName
	mov       rcx, g_vulkan_instance                               ; [ARG0] instance
	sub       rsp, 20h                                             ; Allocate shadow space and align stack
	call      vkGetInstanceProcAddr                                ; Get proc address
	add       rsp, 20h                                             ; Restore stack
	mov       g_vulkan_create_debug_utils_messenger_proc, rax      ; Store create debug utils messenger proc

	; Get destroy debug utils messenger extension proc address
	lea       rdx, g_vulkan_destroy_debug_utils_messenger_proc_name ; [ARG0] pName
	mov       rcx, g_vulkan_instance                                ; [ARG0] instance
	sub       rsp, 20h                                              ; Allocate shadow space and align stack
	call      vkGetInstanceProcAddr                                 ; Get proc address
	add       rsp, 20h                                              ; Restore stack
	mov       g_vulkan_destroy_debug_utils_messenger_proc, rax      ; Store destroy debug utils messenger proc

	; Create debug utils messenger
	lea       r9, g_vulkan_debug_utils_messenger              ; [ARG3] pMessenger
	xor       r8, r8                                          ; [ARG2] pAllocator
	lea       rdx, g_vulkan_debug_utils_messenger_create_info ; [ARG1] pCreateInfo
	mov       rcx, g_vulkan_instance                          ; [ARG0] instance
	sub       rsp, 20h                                        ; Allocate shadow space and align stack
	call      g_vulkan_create_debug_utils_messenger_proc      ; Create debug utils messenger
	add       rsp, 20h                                        ; Restore stack

ENDIF ; __DEBUG

	FUNCTION_EPILOGUE

	ret

context_create_vulkan_instance endp

;
; Context Create Vulkan Surface
;
context_create_vulkan_surface proc

	FUNCTION_PROLOGUE

	mov       r12, g_window_hwnd ; Store window hwnd into temporary
	mov       r13, g_window_class.hInstance ; Store module instance into temporary

	; Fill win32 surface create info
	mov       g_vulkan_win32_surface_create_info_khr.sType, VK_STRUCTURE_TYPE_WIN32_SURFACE_CREATE_INFO_KHR
	mov       g_vulkan_win32_surface_create_info_khr.hinstance, r13
	mov       g_vulkan_win32_surface_create_info_khr.hwnd, r12

	; Create win32 surface
	lea       r9, g_vulkan_surface                        ; [ARG3] pSurface
	xor       r8, r8                                      ; [ARG2] pAllocator
	lea       rdx, g_vulkan_win32_surface_create_info_khr ; [ARG1] pCreateInfo
	mov       rcx, g_vulkan_instance                      ; [ARG0] instance
	sub       rsp, 20h                                    ; Allocate shadow space and align stack
	call      vkCreateWin32SurfaceKHR                     ; Create win32 surface
	add       rsp, 20h                                    ; Restore stack

	FUNCTION_EPILOGUE

	ret

context_create_vulkan_surface endp

;
; Context Destroy Win32 Window
;
context_destroy_win32_window proc

	FUNCTION_PROLOGUE

	; Destroy window
	mov       rcx, g_window_hwnd ; [ARG0] hWnd
	sub       rsp, 20h           ; Allocate shadow space and align stack
	call      DestroyWindow      ; Destroy window
	add       rsp, 20h           ; Restore stack

	; Unregister window class
	mov       rdx, g_window_hwnd       ; [ARG1] hInstance
	lea       rcx, g_window_class_name ; [ARG0] lpClassName
	sub       rsp, 20h                 ; Allocate shadow space and align stack
	call      UnregisterClassA         ; Unregister class
	add       rsp, 20h                 ; Restore stack

	FUNCTION_EPILOGUE

	ret

context_destroy_win32_window endp

;
; Context Destroy Vulkan Instance
;
context_destroy_vulkan_instance proc

	FUNCTION_PROLOGUE

IFDEF __DEBUG

	; Destroy debug utils messenger
	xor       r8, r8                                      ; [ARG2] pAllocator
	mov       rdx, g_vulkan_debug_utils_messenger         ; [ARG1] messenger
	mov       rcx, g_vulkan_instance                      ; [ARG0] instance
	sub       rsp, 20h                                    ; Allocate shadow space and align stack
	call      g_vulkan_destroy_debug_utils_messenger_proc ; Destroy debug utils messenger
	add       rsp, 20h                                    ; Restore stack

ENDIF ; __DEBUG

	; Destroy instance
	xor       rdx, rdx               ; [ARG1] pAllocator
	mov       rcx, g_vulkan_instance ; [ARG0] instance
	sub       rsp, 20h               ; Allocate shadow space and align stack
	call      vkDestroyInstance      ; Destroy instance
	add       rsp, 20h               ; Restore stack

	FUNCTION_EPILOGUE

	ret

context_destroy_vulkan_instance endp

;
; Context Destroy Vulkan Surface
;
context_destroy_vulkan_surface proc

	FUNCTION_PROLOGUE

	; Destroy win32 surface
	xor       r8, r8                 ; [ARG2] pAllocator
	mov       rdx, g_vulkan_surface  ; [ARG1] surface
	mov       rcx, g_vulkan_instance ; [ARG0] instance
	sub       rsp, 20h               ; Allocate shadow space and align stack
	call      vkDestroySurfaceKHR    ; Destroy win32 surface
	add       rsp, 20h               ; Restore stack

	FUNCTION_EPILOGUE

	ret

context_destroy_vulkan_surface endp

;
; Context Win32 Message Procedure
;
context_win32_message_procedure proc hWin:qword, uMsg:dword, wParam:qword, lParam:qword

	mov       r12, rcx ; Store window handle into temporary
	mov       r13, rdx ; Store message into temporary
	mov       r14, r8  ; Store wParam into temporary
	mov       r15, r9  ; Store lParam into temporary

	; Switch message type
	cmp       edx, WM_DESTROY
	je        handle_destroy_msg
	cmp       edx, WM_SIZE
	je        handle_resize_msg

	; Handle default window procedure
	mov       r9, r15        ; [ARG3] lParam
	mov       r8, r14        ; [ARG2] wParam
	mov       rdx, r13       ; [ARG1] Msg
	mov       rcx, r12       ; [ARG0] hWnd
	sub       rsp, 20h       ; Allocate shadow space and align stack
	call      DefWindowProcA ; Default window procedure
	add       rsp, 20h       ; Restore stack
	ret

handle_destroy_msg:

	; Handle window destroy
	mov       g_window_should_close, 1 ; Set window should close
	xor       rax, rax                 ; Return 0
	ret

handle_resize_msg:

	; Handle window resize
	xor       rax, rax ; Return 0
	ret

context_win32_message_procedure endp

;
; Context Vulkan Debug Procedure
;
context_vulkan_debug_procedure proc messageSeverity:dword, messageTypes:dword, pCallbackData:qword, pUserData:qword

	mov       r12, qword ptr [r8 + 28h] ; Store debug utils messenger callback message member into temporary

	; Print vulkan debug message
	mov       rcx, r12 ; [ARG0] format
	sub       rsp, 20h ; Allocate shadow space and align stack
	call      printf   ; Print formatted
	add       rsp, 20h ; Restore stack

	ret

context_vulkan_debug_procedure endp

end
