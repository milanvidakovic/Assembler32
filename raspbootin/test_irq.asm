#include "consts.asm"
#addr PROGRAM_START
	mov.s sp, 0xF000

	mov.w r0, 0
	out [PORT_VIDEO_MODE], r0  ; set the video mode to text

	call wipe
	
	mov.s r0, 0x0001			; JUMP opcode + upper word of the address
	mov.s r1, PS2_HANDLER_ADDR		; IRQ#2 vector address (raw keyboard interrupt)
	st.s [r1], r0
	mov.w r0, ps2_triggered
	mov.s r1, PS2_HANDLER_ADDR + 2
	st.w [r1], r0	; the keyboard IRQ handler has been set

	mov.s r0, 0x0001			; JUMP opcode + upper word of the address
	mov.s r1, UART_HANDLER_ADDR		; IRQ#1 vector address (UART interrupt)
	st.s [r1], r0
	mov.w r0, uart_triggered
	mov.s r1, UART_HANDLER_ADDR + 2
	st.w [r1], r0	; the keyboard IRQ handler has been set

	mov.s r0, 0x0001			; JUMP opcode + upper word of the address
	mov.s r1, TIMER_HANDLER_ADDR		; timer vector address (timer interrupt)
	st.s [r1], r0
	mov.w r0, timer_triggered
	mov.s r1, TIMER_HANDLER_ADDR + 2
	st.w [r1], r0	; the timer IRQ handler has been set

	mov.w r0, 500
	out [PORT_TIMER], r0	; each 500 milliseconds the timer interrupt will occur	

again:
	mov.w r1, 10
	mov.w r2, 70
	call random					; r0 holds the random number between 10 and 70

	push 6*160					; cursor offset: 5'th row, the first character
	push r0							; number to print
	call print_num
	add.w sp, 8      	  ; return the stack pointer to the state before calling the print_str

	mov.w r2, VIDEO + 10*160
	mov.w r1, 65
	add.w r2, r0
	st.s [r2], r1

	mov.w r0, 500
	call delay
	
	j again

	
; ##################################################################
; function ps2_triggered()
; called whenever someone presses a key on the PS/2 keyboard
; ##################################################################
ps2_triggered:
	push r0
	push r1
	push r2

;	mov r0, 2
;	out [67], r0
	
	mov.w r0, 65
	ld.s r1, [counter]
	mov.s r2, VIDEO + 11*160
	add.w r2, r1
	st.s [r2], r0
	add.w r1, 2
	st.s [counter], r1
	
	pop r2
	pop r1
	pop r0
	iret

counter:
	#d16 0

; ##################################################################
; function uart_triggered()
; called whenever a byte arrives from the UART
; ##################################################################
uart_triggered:
	push r0
	push r1
	push r2

	in r0, [PORT_UART_RX_BYTE]
	ld.s r1, [counter2]
	mov.w r2, VIDEO + 20*160
	add.w r2, r1
	st.s [r2], r0
	add.w r1, 2
	st.s [counter2], r1
	
	pop r2
	pop r1
	pop r0
	iret

counter2:
	#d16 0

; ##################################################################
; function timer_triggered()
; called whenever a timer interrupt is triggered
; ##################################################################
timer_triggered:
	push r0
	push r1
	push r2

	mov.w r0, 66
	ld.s r1, [counter3]
	mov.w r2, VIDEO + 30*160
	add.w r2, r1
	st.s [r2], r0
	add.w r1, 2
	st.s [counter3], r1
	
	pop r2
	pop r1
	pop r0
	iret

counter3:
	#d16 0

	
; ##################################################################
; function r0 = random(r1, r2)
; returns pseudo-random number in range from r1 to r2
; ##################################################################

random:
	push r1
	push r2
	push r3
	
	in r0, [PORT_MILLIS]		; get current number of milliseconds
	st.w [a], r0
	ld.w r0, [seed]
	ld.w r3, [a]
	mul.w r0, r3
	ld.w r3, [c]
	add.w r0, r3
	ld.w r3, [m]
	div.w r0, r3
  mov.w r0, h
  st.w [seed], r0

	sub.w r2, r1
  div.w r0, r2
	mov.w r0, h
	cmp.w r0, 0
	js neg_random

random1:	
	add.w r0, r1

	pop r3
	pop r2
	pop r1	
	ret
neg_random:
	neg.w r0
	j random1
	
seed:
	#d32 19987
a:
	#d32 11035
c:
	#d32 12345
m:
	#d32 32767

; ##################################################################
; function delay(r0)
; waits for the r0 milliseconds
; ##################################################################
delay:
	push r1
	push r2
delay_loop2:
	in r1, [PORT_MILLIS]
delay_loop1:
	nop
	in r2, [PORT_MILLIS]
	sub.w r2, r1
	jz delay_loop1			; one millisecond elapsed here
	dec.w r0
	jnz delay_loop2
	
	pop r2
	pop r1
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
#include "stdio.asm"
