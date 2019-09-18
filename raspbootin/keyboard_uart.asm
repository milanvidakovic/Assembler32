; this program will demonstrate UART ECHO
#include "consts.asm"
#addr PROGRAM_START
; ########################################################
; REAL START OF THE PROGRAM
; ########################################################

	mov.s sp, 0x3000


	; set the IRQ handler for keyboard to our own IRQ handler
	mov.s r0, 1						; JUMP instruction opcode
	mov.s r1, PS2_HANDLER_ADDR		; IRQ#2 vector address (raw keyboard interrupt)
	st.s [r1], r0
	mov.w r0, my_irq_triggered
	mov.s r1, PS2_HANDLER_ADDR + 2	  
	st.w [r1], r0	; the keyboard IRQ handler has been set
	
	call wipe

	halt

; ########################################################
; Subroutine for wiping first two rows of the video memory
; ########################################################
wipe:
	mov.s r0, 0
	mov.s r1, VIDEO
	mov.s r2, 160
loop1:
	st.s [r1], r0
	add.s r1, 2
	dec.w r2
	jp loop1
	ret

; ##################################################################
; Subroutine which is called whenever some byte arrives at the UART
; ##################################################################
my_irq_triggered:	
	push r0
	push r1


	in r0, [PORT_KEYBOARD] 	; r0 holds the keyboard scancode
	
	mov.s r1, VIDEO + 5*160
	st.s [r1], r0
	
loop2:
	in r1, [PORT_UART_TX_BUSY]   ; tx busy in r5
	cmp.s r1, 0     
	jz not_busy   ; if not busy, send back the received character 
	j loop2
	
not_busy:

	out [PORT_UART_TX_SEND_BYTE], r0  ; send the received character to the UART
	
	pop r1                 
	pop r0
	iret									 

counter:
	#d6 0

