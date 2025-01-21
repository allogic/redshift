IFNDEF __CORE_VULKAN_API

__CORE_VULKAN_API EQU 1

VK_STRUCTURE_TYPE_APPLICATION_INFO                      EQU 0h
VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO                  EQU 1h
VK_STRUCTURE_TYPE_WIN32_SURFACE_CREATE_INFO_KHR         EQU 3B9AED28h
VK_STRUCTURE_TYPE_DEBUG_UTILS_MESSENGER_CREATE_INFO_EXT EQU 3B9CBE04h

VK_DEBUG_UTILS_MESSAGE_SEVERITY_WARNING_BIT_EXT EQU 100h
VK_DEBUG_UTILS_MESSAGE_SEVERITY_ERROR_BIT_EXT   EQU 1000h

VK_DEBUG_UTILS_MESSAGE_TYPE_GENERAL_BIT_EXT     EQU 1h
VK_DEBUG_UTILS_MESSAGE_TYPE_VALIDATION_BIT_EXT  EQU 2h
VK_DEBUG_UTILS_MESSAGE_TYPE_PERFORMANCE_BIT_EXT EQU 4h

VkApplicationInfo STRUCT
	sType              DWORD 0
	pNext              QWORD 0
	pApplicationName   QWORD 0
	applicationVersion DWORD 0
	pEngineName        QWORD 0
	engineVersion      DWORD 0
	apiVersion         DWORD 0
VkApplicationInfo ENDS

VkInstanceCreateInfo STRUCT
	sType                   DWORD 0
	pNext                   QWORD 0
	flags                   DWORD 0
	pApplicationInfo        QWORD 0
	enabledLayerCount       DWORD 0
	ppEnabledLayerNames     QWORD 0
	enabledExtensionCount   DWORD 0
	ppEnabledExtensionNames QWORD 0
VkInstanceCreateInfo ENDS

VkDebugUtilsMessengerCreateInfoEXT STRUCT
	sType           DWORD 0
	pNext           QWORD 0
	flags           DWORD 0
	messageSeverity DWORD 0
	messageType     DWORD 0
	pfnUserCallback QWORD 0
	pUserData       QWORD 0
VkDebugUtilsMessengerCreateInfoEXT ENDS

VkDebugUtilsMessengerCallbackDataEXT STRUCT
	sType            DWORD 0
	pNext            QWORD 0
	flags            DWORD 0
	pMessageIdName   QWORD 0
	messageIdNumber  DWORD 0
	pMessage         QWORD 0
	queueLabelCount  DWORD 0
	pQueueLabels     QWORD 0
	cmdBufLabelCount DWORD 0
	pCmdBufLabels    QWORD 0
	objectCount      DWORD 0
	pObjects         QWORD 0
VkDebugUtilsMessengerCallbackDataEXT ENDS

VkWin32SurfaceCreateInfoKHR STRUCT
	sType     DWORD 0
	pNext     QWORD 0
	flags     DWORD 0
	hinstance QWORD 0
	hwnd      QWORD 0
VkWin32SurfaceCreateInfoKHR ENDS

EXTERN vkCreateInstance        : PROC
EXTERN vkGetInstanceProcAddr   : PROC
EXTERN vkCreateWin32SurfaceKHR : PROC
EXTERN vkDestroySurfaceKHR     : PROC
EXTERN vkDestroyInstance       : PROC

ENDIF ; __CORE_VULKAN_API
