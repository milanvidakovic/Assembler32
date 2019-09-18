#include "consts.asm"
#addr PROGRAM_START
	mov.s sp, 0xF000

	call wipe
	
	mov.w r0, 1
	sub.w r0, 1
	callz print
	halt
print:
	mov.w r2, 1		  ; r2 will be added to the VIDEO
	mov.w r1, 0  					; r1 will be added to the the address of the "HELLO WORLD" string
again:	
	ld.b r0, [r1 + text]  ; load r0 with the content of the memory location to which r1 points (current character)
	cmp.b r0, 0           ; if the current character is 0 (string terminator),
	jz end                ; go out of this loop 
	st.b [r2 + VIDEO], r0  	 			; store the character at the VIDEO_0 + r2 
	inc.w r1            	; move to the next character
	add.w r2, 2           ; move to the next location in the video memory
	j again               ; continue with the loop
end:	

	mov.w r0, 66
	mov.w r1, VIDEO
	st.b [r1 + 321], r0

	mov.w r0, 65
	st.b [VIDEO + 161], r0

	ret
	
	

; ########################################################
; Subroutine for wiping video memory
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

text:
	#str "Hello World!\0"