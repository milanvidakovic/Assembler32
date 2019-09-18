; this program will draw two thick lines in graphics mode
; video memory starts at 26880
; each line is 160 bytes long
; each byte contains two pixels, four bits each: xrgbxrgb
#include "consts.asm"
#addr PROGRAM_START
; ########################################################
; REAL START OF THE PROGRAM
; ########################################################

	mov.w sp, 0xF000

	mov.w r0, 1
	out [PORT_VIDEO_MODE], r0  ; set the video mode to graphics
	
	; set 1 to LEDs
	out [PORT_LED], r0  ; totally unrelated to this demo - just to set LEDs
	
	call wipe

	; now we continue with the demo
	; first line (one pixel thick) at the top of the screen
	mov.w r0, 0x7777 ; four white pixels
	mov.w r1, VIDEO
	mov.w r2, 0
loop1:
	st.s [r1], r0
	add.w r1, 2
	inc.w r2
	cmp.w r2, 80
	jz next1
	j loop1
	
next1:	
	; second line (two pixels thick) at the fourth row from the top of the screen
	mov.w r0, 0x1111 ; four blue pixels
	mov.w r1, VIDEO + 3*160
	mov.w r2, 0
loop2:
	st.s [r1], r0
	add.w r1, 2
	inc.w r2
	cmp.w r2, 160
	jz next2
	j loop2
	
next2:	
	; third line (two pixels thick) at the bottom the screen
	mov.w r0, 0x4444 ; four red pixels
	mov.w r1, VIDEO + 238*160
	mov.w r2, 0
loop3:
	st.s [r1], r0
	add.w r1, 2
	inc.w r2
	cmp.w r2, 160
	jz end
	j loop3
		
end:	
	halt

wipe:
	mov.w r0, 0
	mov.w r1, VIDEO
	mov.w r2, 320*240/4
w1:
	st.s [r1], r0
	add.w r1, 2
	dec.w r2
	jp w1
	ret
	