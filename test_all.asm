	#addr 0
	VIDEO_0 = 1024

	mov r0, 64
	mov r1, 1
	add r0, r1
	;mov r2, VIDEO_0 + 5*160
	mov r3, r0
	ld r3, [slovo]
	st [VIDEO_0 + 5*160], r3


	mov r1, tekst1
	mov r2, VIDEO_0 + 10*160
again1:	
	ld.b r0, [r1]
	cmp r0, 0
	jz next1
	st [r2], r0
	inc r1
	add r2, 2
	j again1

next1:

	mov r1, tekst2
	mov r2, VIDEO_0 + 11*160
again2:	
	ld r0, [r1]
	cmp r0, 0
	jz next2
	st [r2], r0
	add r1, 2
	add r2, 2
	j again2

next2:
	; test SDRAM copying data from SRAM to SDRAM and back into VRAM
	; first we copy some data from SRAM to SDRAM
	mov r1, tekst3
	mov r2, 30000
	mov r3, 4
again3:	
	ld.b r0, [r1]
	st.b [r2], r0
	inc r1
	inc r2
	dec r3
	jp again3

out [67], 1
	
next3:
	; then we copy data from SDRAM to VRAM
	mov r1, 30000
	mov r2, VIDEO_0 + 12*160
	mov r3, 4
again4:	
	ld.b r0, [r1]
out [67], 2
	st [r2], r0
out [67], 3
	inc r1
	add r2, 2
	inc [counter]
out [67], 4
	cmp r3, [counter]
out [67], 5
	jp again4

out [67], 6


	halt
	
counter:
	#d16 0
tekst1:
	#str "TEKST1\0"
tekst2:
	#str16 "TEKST2\0"
tekst3:
	#str "ABCD\0"
slovo:
	#d16 65
