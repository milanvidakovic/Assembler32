; this program will print HELLO WORLD
#include "consts.asm"
#addr PROGRAM_START
	mov.w sp, 0xF000

	mov.w r0, 0
	out [PORT_VIDEO_MODE], r0  ; set the video mode to text

	push 9*160				; cursor offset: 9'th row
	push hello_str
	call print_str
	add.w sp, 8       	; return the stack pointer to the state before calling the print_str
	
	mov.w r2, 256
	inc.w r2					; 257
	inc.w r2					; 258
	neg.w r2					; -258
	div.w r2, 2				; -129
;	add.w r2, 4				; -254
	push 10*160				; cursor offset: 10'th row, the first character
	push r2						; number to print
	call print_num
	add.w sp, 8      	  ; return the stack pointer to the state before calling the print_str

	mov.w r0, 16
	mov.w r1, 16
	mul.w r0, r1			; 256
	push 11*160				; cursor offset: eleventh row, the first character
	push r0						; number to print
	call print_num
	add.w sp, 8      	  ; return the stack pointer to the state before calling the print_str

	mov.w r0, 256
	neg.w r0					; -256
	push 12*160				; cursor offset: 12'th row, the first character
	push r0						; number to print
	call print_num
	add.w sp, 8      	  ; return the stack pointer to the state before calling the print_str

	mov.w r0, 0x12345678
	push 13*160				; cursor offset: 13'th row, the first character
	push r0						; number to print
	call print_hex
	add.w sp, 8      	  ; return the stack pointer to the state before calling the print_str


	mov.w r0, 0x40600000
	; r0 holds 3.5 decimal number in floating point
	mov.w r2, 0x40200000 ; r2 <= 2.5
	; r2 holds 2.5 decimal number in floating point
	
	;xor r0, 0x80000000  ; this makes r0 <= -3.5
	;xor r2, 0x80000000  ; this makes r2 <= -2.5
	fdiv r0, r2      ; r0 holds now r0 / r2 == 3.5 / 2.5 == 1.4 = 0x3fb33333

	push 14*160				; cursor offset: 14'th row, the first character
	push r0						; number to print
	call print_hex
	add.w sp, 8      	  ; return the stack pointer to the state before calling the print_str

	mov.w r0, 0x40600000
	; r0 holds 3.5 decimal number in floating point
	mov.w r2, 0x40200000 ; r2 <= 2.5
	; r2 holds 2.5 decimal number in floating point

	;xor r0, 0x80000000  ; this makes r0 <= -3.5
	;xor r2, 0x80000000  ; this makes r2 <= -2.5
	fmul r0, r2      ; r0 holds now r0*r2 == 3.5 * 2.5 == 8.75 == 0x410c0000

	push 15*160				; cursor offset: 15'th row, the first character
	push r0
	call print_hex
	add.w sp, 8      	  ; return the stack pointer to the state before calling the print_str

	mov.w r0, 0x40600000
	; r0 holds 3.5 decimal number in floating point
	mov.w r2, 0x40200000 ; r2 <= 2.5
	; r2 holds 2.5 decimal number in floating point
	fadd r0, r2     ; r0 hods the sum of r0 + r2 == 3.5 + 2.5 == 6  == 0x40c00000 	 

	push 16*160				; cursor offset: 16'th row, the first character
	push r0
	call print_hex
	add.w sp, 8      	  ; return the stack pointer to the state before calling the print_str

	mov.w r0, 0x40600000
	; r0 holds 3.5 decimal number in floating point
	mov.w r2, 0x40200000 ; r2 <= 2.5
	; r2 holds 2.5 decimal number in floating point
	fsub r0, r2     ; r0 hods the difference of r0 - r2 == 3.5 - 2.5 == 1 == 0x3f800000

	push 17*160				; cursor offset: 17'th row, the first character
	push r0
	call print_hex
	add.w sp, 8      	  ; return the stack pointer to the state before calling the print_str

	halt
#include "stdio.asm"

hello_str:
	#str "Hello World!\0"
