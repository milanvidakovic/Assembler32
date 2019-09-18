; this program will demonstrate UART ECHO
VIDEO_0 = 1024 ; beginning of the text frame buffer

; ########################################################
; RESET CODE (4 bytes max)
; ########################################################
#addr 0x0000
	j start

; ########################################################
; IRQ 1 CODE (4 bytes max) - KEY1
; ########################################################
#addr 0x0008
	j irq_triggered

; ########################################################
; IRQ 2 CODE (4 bytes max) - UART
; ########################################################
#addr 0x0010
	j irq_triggered
	
#addr 24
	j my_irq_triggered

; ########################################################
; REAL START OF THE PROGRAM
; ########################################################
#addr 0x100
start:	
	mov sp, 0x3000  ; set stack
		
	call wipe
	
	mov r1, hello  ; r0 holds the address of the "HELLO WORLD" string
	mov r2, 0      ; r2 is the index
again:	
	ld r0, [r1]            ; load r0 with the content of the memory location to which r1 points (current character)
	cmp r0, 0              ; if the current character is 0 (string terminator),
	jz end                 ; go out of this loop 
	st [r2 + VIDEO_0], r0  ; store the character at the VIDEO_0 + r2 
	inc r1                 ; move to the next character
	inc r2                 ; move to the next location in the video memory
	j again                ; continue with the loop
end:	
	halt
hello:
	#str16 "HELLO WORLD\0"

; ########################################################
; Subroutine for wiping first two rows of the video memory
; ########################################################
wipe:
	mov r0, 0
	mov r2, 160
loop1:
	st [r2 + VIDEO_0], r0
	dec r2
	jp loop1
	ret


; ############################################################################
; Subroutine which is called whenever some byte arrives from the PS/2 keyboard
; ############################################################################
my_irq_triggered:	
	push r0
	push r1
	push r2   
	push r5
	push r6

	in r0, [68] 	; r0 holds the keyboard scancode
	
	ld r6, [cursor]
	st [r6 + VIDEO_0], r0    ; store the UART character at the VIDEO_0 + r2 
	add r6, 2                ; move to the next location in the video memory
	st [cursor], r6
	
loop3:
	in r5, [65]   ; tx busy in r5
	cmp r5, 0     
	jz not_busy3   ; if not busy, send back the received character 
	j loop3
	
not_busy3:
	out [66], r0  ; send the received character to the UART
	
	call send_sp
	
	pop r6
	pop r5
	pop r2
	pop r1                 
	pop r0
	iret									 

; #################################################################
; Subroutine which is called whenever some byte arrives at the UART
; #################################################################
irq_triggered:	
	push r1   
	push r5
	push r6

	in r1, [64] 		   	 	   ; r1 holds now received byte from the UART (address 64 decimal)
	ld r6, [cursor]
	st [r6 + VIDEO_0], r1    ; store the UART character at the VIDEO_0 + r2 
	add r6, 2                ; move to the next location in the video memory
	st [cursor], r6

loop2:
	in r5, [65]   ; tx busy in r5
	cmp r5, 0     
	jz not_busy   ; if not busy, send back the received character 
	j loop2
	
not_busy:
	out [66], r1  ; send the received character to the UART
	
	call send_sp
	
	pop r6
	pop r5
	pop r1                 
	iret									 
; #######################################
; Dumps current sp over UART
; #######################################
send_sp:
	
loop_sp1:
	in r5, [65]   ; tx busy in r5
	cmp r5, 0     
	jz not_busy_sp1   ; if not busy, send back the received character 
	j loop_sp1
	
not_busy_sp1:
	out [66], sp  ; send the lowr byte of the sp

loop_sp2:
	in r5, [65]   ; tx busy in r5
	cmp r5, 0     
	jz not_busy_sp2   ; if not busy, send back the received character 
	j loop_sp2
	
not_busy_sp2:
	mov r0, sp
	shr r0, 8
	out [66], r0  ; send the lower byte of the sp
ret

cursor:
	#d16 14
