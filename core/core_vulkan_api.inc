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

VkApplicationInfo struct
	sType              dword 0
	pNext              qword 0
	pApplicationName   qword 0
	applicationVersion dword 0
	pEngineName        qword 0
	engineVersion      dword 0
	apiVersion         dword 0
VkApplicationInfo ends

VkInstanceCreateInfo struct
	sType                   dword 0
	pNext                   qword 0
	flags                   dword 0
	pApplicationInfo        qword 0
	enabledLayerCount       dword 0
	ppEnabledLayerNames     qword 0
	enabledExtensionCount   dword 0
	ppEnabledExtensionNames qword 0
VkInstanceCreateInfo ends

VkDebugUtilsMessengerCreateInfoEXT struct
	sType           dword 0
	pNext           qword 0
	flags           dword 0
	messageSeverity dword 0
	messageType     dword 0
	pfnUserCallback qword 0
	pUserData       qword 0
VkDebugUtilsMessengerCreateInfoEXT ends

VkDebugUtilsMessengerCallbackDataEXT struct
	sType            dword 0
	pNext            qword 0
	flags            dword 0
	pMessageIdName   qword 0
	messageIdNumber  dword 0
	pMessage         qword 0
	queueLabelCount  dword 0
	pQueueLabels     qword 0
	cmdBufLabelCount dword 0
	pCmdBufLabels    qword 0
	objectCount      dword 0
	pObjects         qword 0
VkDebugUtilsMessengerCallbackDataEXT ends

VkWin32SurfaceCreateInfoKHR struct
	sType     dword 0
	pNext     qword 0
	flags     dword 0
	hinstance qword 0
	hwnd      qword 0
VkWin32SurfaceCreateInfoKHR ends

extern vkCreateInstance        : proc
extern vkGetInstanceProcAddr   : proc
extern vkCreateWin32SurfaceKHR : proc
extern vkDestroySurfaceKHR     : proc
extern vkDestroyInstance       : proc

ENDIF ; __CORE_VULKAN_API
