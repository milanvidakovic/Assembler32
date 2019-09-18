#include "consts.asm"
#addr PROGRAM_START

	mov.s r0, 255
	out [PORT_LED], r0
	halt
	