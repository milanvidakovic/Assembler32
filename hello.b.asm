; this program will print HELLO WORLD
VIDEO_0 = 1024

	;out [67], 1

	mov r1, 65
	mov r2, VIDEO_0 + 10*160
	st [r2], r1
	inc r1
	add r2, 2
	st [r2], r1
	
	add r2, 2
	mov r3, hello
again:	
	ld.b r1, [r3]
	cmp r1, 0
	jz end
	st [r2], r1
	inc r3
	add r2, 2
	j again

	
end:	
	mov r0, 255
	out [67], r0

	halt	
																																																				;	0020: FFF0
hello:
	#str "HELL\0O\0"																																																	;	0022: 4845 4C4C 4F00
