; this is the boot loader compatible with the raspbootin loader
VIDEO = 1024 ; beginning of the text frame buffer
UART_HANDLER_ADDR	= 16	; uart IRQ#1 handler (uart receive byte handler)
PROGRAM_START = 0xB000		; loaded program start address

; ########################################################
; RESET CODE (4 bytes max)
; ########################################################
#addr 0x0000
	j start

; ########################################################
; THE REAL START OF THE PROGRAM
; ########################################################
#addr 0x100
start:	
	mov.w sp, 0x3000  ; set stack

	mov.w r0, 0
	st.w [state], r0
	st.w [size], r0
	st.w [loaded], r0
	st.w [current_size], r0
	st.w [sum_all], r0
	mov.w r0, PROGRAM_START			; address to load code
	st.w [current_addr], r0

	call wipe			 ; wipe video memory for messages

	call waiting_message

	mov.s r0, 1									; JUMP instruction opcode
	mov.s r1, UART_HANDLER_ADDR	; IRQ#1 vector address (UART interrupt handler address)
	st.s [r1], r0
	mov.w r0, irq_triggered
	mov.w r1, UART_HANDLER_ADDR + 2	  
	st.w [r1], r0	; the UART IRQ handler has been set
	
	; send raspbootin boot char sequence
	mov.w r0, 77								; "M" character
	call uart_send
	mov.w r0, 13								; \n character
	call uart_send
	mov.w r0, 10								; \r character
	call uart_send
	mov.w r0, 3
	call uart_send
	mov.w r0, 3
	call uart_send
	mov.w r0, 3
	call uart_send

not_loaded:
	ld.w r0, [loaded]
	cmp.w r0, 1
	jz PROGRAM_START
	nop
	j not_loaded

; ########################################################
; Subroutine for sending a character to the UART
; r0 - holds the character to be sent
; ########################################################
uart_send:
	push r1
	
uagain:	
	in r1, [65]   ; tx busy in r1
	cmp.w r1, 0     
	jz not_busy   ; if not busy, send the given character
	nop						; waste a little bit of time
	j uagain		  ; otherwise, go again
not_busy:
	out [66], r0  ; send the received character to the UART
	
	pop r1
	ret	

; ########################################################
; Subroutine for printing "WAITING..." to the screen
; ########################################################
waiting_message:	
	mov.w r2, VIDEO      ; r2 is at the beginning of the video memory
	mov.w r1, hello  ; r1 holds the address of the "WAITING..." string
again:	
	ld.b r0, [r1]          ; load r0 with the content of the memory location to which r1 points (current character)
	cmp.b r0, 0              ; if the current character is 0 (string terminator),
	jz end                 ; go out of this loop 
	st.s [r2], r0            ; store the character at the VIDEO_0 + r2 
	inc.w r1                 ; move to the next character
	add.w r2, 2              ; move to the next location in the video memory
	j again                ; continue with the loop
end:	
	ret
hello:
	#str "WAITING...\0"

; ########################################################
; Subroutine for wiping first three rows of the video memory
; ########################################################
wipe:
	mov.w r0, 0
	mov.w r1, VIDEO
	mov.w r2, 240
loop1:
	st.s [r1], r0
	add.w r1, 2
	dec.w r2
	jp loop1
	ret

; ##################################################################
; Subroutine which is called whenever some byte arrives at the UART
; ##################################################################
irq_triggered:	
	push r0
	push r1   
	push r2
	push r3

	ld.w r0, [state]				; current state in r0
	cmp.w r0, 0
	jz first_byte
	cmp.w r0, 1
	jz second_byte
	cmp.w r0, 2
	jz third_byte
	cmp.w r0, 3
	jz fourth_byte

	; ###########################################################
	; if the state is 4, then the code started to arrive via UART	
	; ###########################################################
	
	in r1, [64]						; get the byte from the uart into r1

	ld.w r0, [sum_all]
	add.w r0, r1
	st.w [sum_all], r0			; primitive checksum - sum of all bytes
	
	; at this moment, r1 holds the received byte
	ld.w r2, [current_addr]	; r2 holds the current pointer in memory to store the received byte
	st.b [r2], r1						; store the received byte into the memory
	
	inc.w r2								; move to the next location in memory
	st.w [current_addr], r2 ; save the incremented value of the current address
	
	ld.w r2, [current_size] ; increment the byte counter
	inc.w r2	
	st.w [current_size], r2
	
	ld.w r3, [size]	
	cmp.w r2, r3				; did we receive all?
	jz all_arrived
	
	j skip

all_arrived:
	; send the sum of all bytes
	ld.w r0, [sum_all]
	and.w r0, 255
	call uart_send
	ld.w r0, [sum_all]
	shr.w r0, 8
	call uart_send

	mov.w r0, 1							; signal to the main program that the loader has received all bytes
	st.w [loaded], r0
	
	j skip

first_byte:
	in r1, [64]						; get the char from the uart
	st.w [size], r1				; store the lowest byte to the size variable
	ld.w r1, [state]
	inc.w r1
	st.w [state], r1				; next state -> 1 (second byte)	
	j skip								; return from interrupt
second_byte:
	in r1, [64]						; get the char from the uart (8 upper bits)
	ld.w r2, [size]					; get the lower 8 bits (received earlier)
	shl.w r1, 8							; shift the received byte 8 bits to the left to become upper byte
	or.w r1, r2							; put together lower and upper 8 bits
	st.w [size], r1					; store the calcluated size of the code into the size variable
	ld.w r1, [state]
	inc.w r1
	st.w [state], r1				; next state -> 2 (third byte)	
	j skip								; return from interrupt
third_byte:
	; this is 16-bit cpu, so we don't load code bigger than 65535 bytes
	ld.w r1, [state]
	inc.w r1
	st.w [state], r1				; next state -> 3 (fourth byte)	
	
	j skip
fourth_byte:
	; we don't load code larger than 65535 bytes
	; send confirmation that the code has been loaded
	; a confirmation is the repeated size of the payload to be received
	ld.w r0, [size]
	and.w r0, 255
	call uart_send
	ld.w r0, [size]
	shr.w r0, 8
	call uart_send	
	
	ld.w r1, [state]
	inc.w r1
	st.w [state], r1				; next state -> 4 (code arrives)	

skip:
	pop r3
	pop r2
	pop r1
	pop r0
	iret								  ; return from the IRQ

state:
	#d32 0
size:
	#d32 0
current_size:
	#d32 0
current_addr:
	#d32 PROGRAM_START
loaded:
	#d32 0
sum_all:
	#d32 0		
	