; this program will print HELLO WORLD
#include "consts.asm"
#addr PROGRAM_START

	mov.w r0, 1
	out [VGA_TEXT_INVERSE], r0; make black letters on white background

	mov.w r2, VIDEO		     ; r2 points to the beginning of the video memory
	mov.w r1, hello  			 ; r1 holds the address of the "HELLO WORLD" string
again:	
	ld.s r0, [r1]          ; load r0 with the content of the memory location to which r1 points (current character)
	cmp.s r0, 0            ; if the current character is 0 (string terminator),
	jz end                 ; go out of this loop 
	st.s [r2], r0  	 			 ; store the character at the VIDEO_0 + r2 
	add.s r1, 2            ; move to the next character
	add.s r2, 2            ; move to the next location in the video memory
	j again                ; continue with the loop
end:	
	halt
hello:
	#str16 "HELLO WORLD!ASDF ASDF ASDF\0"
