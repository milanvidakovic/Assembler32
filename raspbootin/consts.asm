VIDEO = 1024 ; beginning of the text frame buffer
PROGRAM_START = 0xB000			; start address of the loaded program

TIMER_HANDLER_ADDR				= 8		; key handler address (KEY1 on DE0-NANO)
UART_HANDLER_ADDR					= 16	; uart IRQ#1 handler (uart receive byte handler)

PS2_HANDLER_ADDR	 				= 24	; address of the IRQ#2 handler address (raw PS/2 keyboard handler)
KEY_PRESSED_HANDLER_ADDR	= 32	; address of the key pressed handler address (invoked from the IRQ2_ADDR handler)
KEY_RELEASED_HANDLER_ADDR	= 40	; address of the key released handler address (invoked from the IRQ2_ADDR handler)
VIRTUAL_KEY_ADDR					= 48	; address where the virtual key is placed

SPRITE_DEFINITION_ADDRESS = 64  ; beginning of the sprite definition structure 
; (64==sprite address, 66==x, 68==y, 70==transparent color) each element is 2 bytes
; each sprite definition is 8 bytes long
; this means that the next sprite is at the address of 64

PORT_UART_RX_BYTE					= 640	; port which contains received byte via UART
PORT_UART_TX_BUSY					= 650	; port which has 1 when UART TX is busy
PORT_UART_TX_SEND_BYTE		= 660	; port for sending character via UART
PORT_LED									= 670	; port for setting eight LEDs (write)
PORT_KEYBOARD 						= 680	; raw keyboard character read port 
PORT_MILLIS 							= 690	; current number of milliseconds counted so far

PORT_VIDEO_MODE						= 1280	; video mode type (0-text; 1-graphics), (write)
PORT_TIMER     						= 1290	; timer irq port (number of milliseconds before the irq is triggered)
VGA_TEXT_INVERSE					= 1300	; if 1, then the screen is inversed (black letters on white background)

VK_0								= 48
VK_1								= 49
VK_2								= 50
VK_3								= 51
VK_4								= 52
VK_5								= 53
VK_6								= 54
VK_7								= 55
VK_8								= 56
VK_9								= 57

VK_SPACE						= 32
VK_A								= 65
VK_B								= 66
VK_C								= 67
VK_D								= 68
VK_E								= 69
VK_F								= 70
VK_G								= 71
VK_H								= 72
VK_I								= 73
VK_J								= 74
VK_K								= 75
VK_L								= 76
VK_M								= 77
VK_N								= 78
VK_O								= 79
VK_P								= 80
VK_Q								= 81
VK_R								= 82
VK_S								= 83
VK_T								= 84
VK_U								= 85
VK_V								= 86
VK_W								= 87
VK_X								= 88
VK_Y								= 89
VK_Z								= 90


VK_BACK_QUOTE				= 96
VK_SLASH						= 47
VK_BACK_SLASH				= 92
VK_BRACE_LEFT				= 91
VK_BRACE_RIGHT			= 93
VK_EQUALS						= 61
VK_QUOTE						= 39
VK_MINUS						= 45
VK_SEMICOLON				= 59
VK_FULL_STOP				= 46
VK_COMMA						= 44
VK_LESS_THAN				= 60

VK_F1								= 301
VK_F2								= 302
VK_F3								= 303
VK_F4								= 304
VK_F5								= 305
VK_F6								= 306
VK_F7								= 307
VK_F8								= 308
VK_F9								= 309
VK_F10							= 310
VK_F11							= 311
VK_F12							= 312

VK_CAPS_LOCK				= 800
VK_NUM_LOCK					= 801
VK_SCROLL_LOCK			= 802

VK_LEFT_SHIFT				= 501
VK_RIGHT_SHIFT			= 502
VK_LEFT_ALT					= 401
VK_RIGHT_ALT				= 402
VK_LEFT_CONTROL			= 601
VK_RIGHT_CONTROL		= 602
VK_LEFT_WINDOWS			= 1001
VK_RIGHT_WINDOWS		= 1002
VK_MENU							= 2000

VK_TAB 							= 9
VK_ENTER 						= 13
VK_ESC							= 701
VK_BACKSPACE				= 700

VK_RIGHT_ARROW 			= 4003
VK_LEFT_ARROW 			= 4001
VK_UP_ARROW 				= 4000
VK_DOWN_ARROW 			= 4002

VK_PAGE_UP 					= 3002
VK_PAGE_DOWN				= 3005
VK_HOME 						= 3001
VK_END							= 3004
VK_INSERT 					= 3000
VK_DELETE 					= 3003

VK_NUMPAD0					= 5048
VK_NUMPAD1					= 5049
VK_NUMPAD2					= 5050
VK_NUMPAD3					= 5051
VK_NUMPAD4					= 5052
VK_NUMPAD5					= 5053
VK_NUMPAD6					= 5054
VK_NUMPAD7					= 5055
VK_NUMPAD8					= 5056
VK_NUMPAD9					= 5057
VK_NUMPAD_PLUS			= 5043
VK_NUMPAD_SUBTRACT	= 5045
VK_NUMPAD_DIVIDE 		= 5047
VK_NUMPAD_MULTIPLY	= 5042
VK_NUMPAD_DECIMAL		= 5046
VK_NUMPAD_ENTER 		= 5013

VK_PRINT_SCREEN			= 10000
