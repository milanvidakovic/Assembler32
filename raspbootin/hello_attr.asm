#include "consts.asm"
#addr PROGRAM_START

; this program will print HELLO WORLD
VIDEO_A = VIDEO + 15*160
VIDEO_C = VIDEO_A + 1
	mov.s sp, 0x3000
	
	call wipe
	
	mov.w r0, 1
	out [VGA_TEXT_INVERSE], r0; make black letters on white background
		
	mov.w r1, hello  				; r1 holds the address of the "HELLO WORLD" string
	mov.w r2, VIDEO_C      	; r2 points to the character part of the video memory
	mov.w r4, VIDEO_A				; r4 points to the attribute part of the video memory
	mov.w r3, 0      				; r3 has the attribute (initial value is 0, which means white letter on a black background)
again:	
	ld.b r0, [r1]          	; load r0 with the content of the memory location to which r1 points (current character)
	cmp.b r0, 0            	; if the current character is 0 (string terminator),
	jz end                 	; go out of this loop 
	st.b [r4], r3					 	; store the attribute
	st.b [r2], r0					 	; store the character 
	inc.w r1							 	; move to the next character in the string
	inc.w r3               	; change the attribute of the current character
	add.w r2, 2							; move to the next character position in the video memory
	add.w r4, 2							; move to the next attribute position in the video memory
	j again                	; continue with the loop
end:	
	halt

; ########################################################
; Subroutine for wiping first three rows of the video memory
; ########################################################
wipe:

	mov.w r0, 0
	mov.w r2, 160 * 60
	mov.w r3, VIDEO
loop1:
	st.s [r3], r0
	add.w r3, 2
	sub.w r2, 2
	jp loop1
	ret
	
hello:
	#str "Hello World! This is a test of attributes.\0"
