	mov r0, 65
	out [67], r0
	st [1024 + 10*160], r0
	mov r0, 2
	out [67], r0
	halt