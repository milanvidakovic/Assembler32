#addr
0
	j start_code
#addr 100
start_code:
VIDEO = 1024 ; beginning of the text frame buffer

TIMER_HANDLER_ADDR				= 8		; timer handler address

UART_HANDLER_ADDR					= 16	; uart IRQ#1 handler (uart receive byte handler)

PS2_HANDLER_ADDR	 				= 24	; address of the IRQ#2 handler address (raw PS/2 keyboard handler)
KEY_PRESSED_HANDLER_ADDR	= 32	; address of the key pressed handler address (invoked from the IRQ2_ADDR handler)
KEY_RELEASED_HANDLER_ADDR	= 40	; address of the key released handler address (invoked from the IRQ2_ADDR handler)
VIRTUAL_KEY_ADDR					= 48	; address where the virtual key is placed

PORT_UART_RX_BYTE					= 64	; port which contains received byte via UART
PORT_UART_TX_BUSY					= 65	; port which has 1 when UART TX is busy
PORT_UART_TX_SEND_BYTE		= 66	; port for sending character via UART
PORT_LED									= 67	; port for setting eight LEDs (write)
PORT_KEYBOARD 						= 68	; raw keyboard character read port 
PORT_MILLIS 							= 69	; current number of milliseconds counted so far
PORT_TIMER								= 129	; timer settings (number milliseconds until interrupt - must be greater than zero)

	mov sp, 0x3000

	
	mov r0, 0x0001			; JUMP opcode + upper word of the address
	mov r1, PS2_HANDLER_ADDR		; IRQ#2 vector address (raw keyboard interrupt)
	st [r1], r0
	mov r0, ps2_triggered
	mov r1, PS2_HANDLER_ADDR + 2
	st [r1], r0	; the keyboard IRQ handler has been set

	mov r0, 0x0001			; JUMP opcode + upper word of the address
	mov r1, UART_HANDLER_ADDR		; IRQ#1 vector address (UART interrupt)
	st [r1], r0
	mov r0, uart_triggered
	mov r1, UART_HANDLER_ADDR + 2
	st [r1], r0	; the keyboard IRQ handler has been set

	mov r0, 0x0001			; JUMP opcode + upper word of the address
	mov r1, TIMER_HANDLER_ADDR		; timer vector address (timer interrupt)
	st [r1], r0
	mov r0, timer_triggered
	mov r1, TIMER_HANDLER_ADDR + 2
	st [r1], r0	; the timer IRQ handler has been set

	mov r0, 500
	out [PORT_TIMER], r0	; each 500 milliseconds the timer interrupt will occur	

	mov r1, 65
	st [VIDEO + 5*160], r1


again:
	mov r1, 10
	mov r2, 70

	call random
	
	mov r1, 65
	st [r0 + VIDEO + 10*160], r1
	mov r0, 500
	call delay
	j again

	
; ##################################################################
; function ps2_triggered()
; called whenever someone presses a key on the PS/2 keyboard
; ##################################################################
ps2_triggered:
	push r0
	push r1

	mov r0, 2
	out [67], r0
	
	mov r0, 65
	ld r1, [counter]
	st [r1 + VIDEO + 11*160], r0
	add r1, 2
	st [counter], r1
	
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

	mov r0, 1
	out [67], r0
	
	in r0, [PORT_UART_RX_BYTE]
	ld r1, [counter2]
	st [r1 + VIDEO + 20*160], r0
	add r1, 2
	st [counter2], r1
	
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

	mov r0, 3
	out [67], r0
	
	mov r0, 66
	ld r1, [counter3]
	st [r1 + VIDEO + 30*160], r0
	add r1, 2
	st [counter3], r1
	
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
	
	in r0, [PORT_MILLIS]		; get current number of milliseconds
	st [a], r0
	ld r0, [seed]
	mul r0, [a]
	add r0, [c]
	div r0, [m]
  mov r0, h
  st [seed], r0

	sub r2, r1
  div r0, r2
	mov r0, h
	cmp r0, 0
	js neg_random

random1:	
	add r0, r1
	pop r2
	pop r1	
	ret
neg_random:
	neg r0
	j random1

seed:
	#d16 19987
a:
	#d16 11035
c:
	#d16 12345
m:
	#d16 32768	

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
	sub r2, r1
	jz delay_loop1			; one millisecond elapsed here
	dec r0
	jnz delay_loop2
	
	pop r2
	pop r1
	ret
