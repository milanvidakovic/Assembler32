#include "consts.asm"
#addr PROGRAM_START

	mov.s r0, 255
	st.s [0x80000000 + PORT_LED], r0
	halt
	