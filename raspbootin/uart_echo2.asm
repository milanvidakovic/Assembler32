; this program will demonstrate UART ECHO
; via MEMORY MAPPED IO
; The difference is is that you need to add 0x80000000 to the PORT number 
; in order to read/write to the peripheral using memory (instead of IN/OUT instructions)
; see uart_echo.asm
#include "consts.asm"
#addr PROGRAM_START
; ########################################################
; REAL START OF THE PROGRAM
; ########################################################

	mov.w sp, 0x3000

	call wipe

	mov.w r0, 14
	st.w [cursor], r0


	; set the IRQ handler for UART to our own IRQ handler
	mov.s r0, 1			; JUMP opcode
	mov.s r1, UART_HANDLER_ADDR
	st.s [r1], r0
	mov.w r0, irq_triggered
	mov.s r1, UART_HANDLER_ADDR + 2
	st.w [r1], r0

	halt

; ########################################################
; Subroutine for wiping first two rows of the video memory
; ########################################################
wipe:
	mov.w r0, 0
	mov.w r1, VIDEO
	mov.w r2, 160
loop1:
	st.w [r1], r0
	add.w r1, 4
	sub.w r2, 2
	jp loop1
	ret

; ##################################################################
; Subroutine which is called whenever some byte arrives at the UART
; ##################################################################
irq_triggered:	
	push r0
	push r1
	push r2   
	push r5
	push r6

	ld.s r1, [0x80000000 + PORT_UART_RX_BYTE] 	; r1 holds now received byte from the UART (address 64 decimal)

	ld.w r6, [cursor]
	mov.w r2, VIDEO
	add.w r2, r6
	st.s [r2], r1    		; store the UART character at the VIDEO_0 + r2 
	add.w r6, 2                		; move to the next location in the video memory
	st.w [cursor], r6

loop2:
	ld.s r5, [0x80000000 + PORT_UART_TX_BUSY]   ; tx busy in r5
	cmp.w r5, 0     
	jz not_busy   ; if not busy, send back the received character 
	j loop2
	
not_busy:

	st.s [0x80000000 + PORT_UART_TX_SEND_BYTE], r1  ; send the received character to the UART
	
skip:
	pop r6
	pop r5
	pop r2
	pop r1                 
	pop r0
	iret									 
	
	
cursor:
	#d32 14

