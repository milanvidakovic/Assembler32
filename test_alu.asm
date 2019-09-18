	mov r1, 1
	out [67], r1

	mov r1, 2
	mov r2, 3
	sub r1, r2
	js neg
	
	out [67], r1

	halt

neg:
	mov r3, 0xcc
	out [67], r3
	halt