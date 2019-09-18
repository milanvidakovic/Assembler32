; #######################################################################################
; print_str function which prints a string on the screen
; the string is 8-bit
; to call it, you must:
; 	push <cursor_offset>
; 	push <address_of_the_string>
;		call print_str16  	; call print_str
;		add.w sp, 8        	; return the stack pointer to the state before calling the print_num
; #######################################################################################
print_str:

	; prepare the stack frame
	push r7          			; save the current frame pointer
	mov.w r7, sp       			; load the stack frame pointer from the sp
	sub.w sp, 4        			; move sp to go out of the current stack frame, so we could call another function from this one
                   			; this is how much we should add: add sp, <size_of_local_variables_space> + 4
	push r0
	push r1
	push r2
	push r3
	
	ld.w r0, [r7 + 8]				; 		[r7 - 12] holds the pointer to the string to be printed
  mov.w r1, VIDEO      	; write digits into the VIDEO memory
  add.w r1, [r7 + 12]		 	; [r7 - 16] holds the offset from the beginning of the video memory (position on the screen)
print_str_again:  
	ld.b r2, [r0]  					; fetch the current character
  cmp.w r2, 0							; terminating zero
  jz print_str_end
  st.s [r1], r2						; store current character in the current video address
  inc.w r0
  add.s r1,2
	j print_str_again	             

print_str_end:
	pop r3
	pop r2
	pop r1
	pop r0
	; clean up before returning
	mov.w sp, r7	       		; restore the old stack pointer
	pop r7						 		; restore the old frame pointer
	ret

; #######################################################################################
; print_str function which prints a string on the screen
; the string is 16-bit
; to call it, you must:
; 	push <cursor_offset>
; 	push <address_of_the_string>
;		call print_str16  	; call print_str
;		add.w sp, 8        	; return the stack pointer to the state before calling the print_num
; #######################################################################################
print_str16:

	; prepare the stack frame
	push r7          			; save the current frame pointer
	mov.w r7, sp       			; load the stack frame pointer from the sp
	sub.w sp, 4        			; move sp to go out of the current stack frame, so we could call another function from this one
                   			; this is how much we should add: add sp, <size_of_local_variables_space> + 4
	push r0
	push r1
	push r2
	push r3
	
	ld.w r0, [r7 + 8]				; 		[r7 - 12] holds the pointer to the string to be printed
  mov.w r1, VIDEO      	; write digits into the VIDEO memory
  add.w r1, [r7 + 12]		 	; [r7 - 16] holds the offset from the beginning of the video memory (position on the screen)
print_str_again16:  
	ld.s r2, [r0]  					; fetch the current character
  cmp.w r2, 0							; terminating zero
  jz print_str_end16
  st.s [r1], r2						; store current character in the current video address
  add.w r0,2
  add.w r1,2
	j print_str_again16

print_str_end16:
	pop r3
	pop r2
	pop r1
	pop r0
	; clean up before returning
	mov.w sp, r7	       		; restore the old stack pointer
	pop r7						 		; restore the old frame pointer
	ret


; ###########################################################
; print_num function which prints a number on a screen
; to call it, you must:
; 	push <cursor_offset>
; 	push <number_to_be_printed_or_register_to_be_printed>
;		call print_num   	; call print_num 
;		sub.w sp, 8        	; return the stack pointer to the state before calling the print_num
; ###########################################################
print_num:
	; arguments:
	; [r7 - 16] - cursor offset (row*80 + col)
	; [r7 - 12] - number to be printed
	; local variables:
	; [r7 + 4] <-> [r7 + 24] - one local variable, holding an array of characters (10 words == 20 bytes) to be printed

	; prepare the stack frame
	push r7          		; save the current frame pointer
	mov.w r7, sp       		; load the stack frame pointer from the sp
	sub.s sp, 24       		; move sp to go out of the current stack frame, so we could call another function from this one
                   		; this is how much we should add: add sp, <size_of_local_variables_space> + 4
                   		; here we have array of the five words, so it is 20 + 4
	push r0
	push r1
	push r2
	push r3
	push r6
	
	mov.w r0, 0          	; fill the array of characters with zeroes
	mov.w r1, 10
	mov.w r6, r7
	
again1:
	st.s [r6 - 4], r0					; st [r6 + 4], r0

	sub.w r6, 2
	dec.w r1
	jnz again1

	ld.w r0, [r7 + 8]  				; ld r0, [r7 - 12]   load r0 with the number to be printed (the first and the only argument of this function)
	cmp.w r0, 0
	js print_num_negative
print_num_1:
	mov.w r1, 0						; counter of digits
	mov.w r6, r7
again2:	
	inc.w r1            	; increment the digit counter
	sub.w r6, 2						; move to the next position in memory
	div.w r0, 10       		; divide by 10; the result is in r0, while the remainder (digit) is in the h register
	st.s [r6], h   				; write the digit into the character array
	cmp.w r0, 0
	jnz again2        	; if the result is 0, we finish
	
  ; at this moment, the r7 + 4 points to the last digit in the character array (digits are stored in the reverse order)
  ; at this moment, the r1 holds the number of digits
  
  mov.w r2, VIDEO     ; write digits into the VIDEO memory
  add.w r2, [r7 + 12]  				; add r2, [r7 - 16]    add cursor offset to the beginning of the video memory
  dec.w r1
again3:  
  ld.s r0, [r6]      		; load the current digit
  add.w r0, 48          ; make it an ascii character
  st.s [r2], r0       
  add.w r2, 2						; move to the next character in video memory
  add.w r6, 2						; move to the next digit in memory
  dec.w r1
  jp again3

	pop r6
	pop r3
	pop r2
	pop r1
	pop r0
  
	; clean up before returning
	mov.w sp, r7	       	; restore the old stack pointer
	pop r7						 	; restore the old frame pointer
	ret
print_num_negative:
	neg.w r0
	mov.w r2, VIDEO     ; write minus sign into the VIDEO memory
	
	ld.w r3, [r7 + 12]				; ld r3, [r7 - 16]
  add.w r2, r3       		; add cursor offset to the beginning of the video memory
  mov.w r1, 45					; minus sign
  st.s [r2], r1 
  add.w r3, 2
  
  st.w [r7 + 12], r3  		; st [r7 - 16], r3  		move cursor to the right
	j print_num_1


; ###########################################################
; print_hex function which prints a number on a screen
; to call it, you must:
; 	push <cursor_offset>
; 	push <number_to_be_printed_or_register_to_be_printed>
;		call print_hex   	; call print_num 
;		sub.w sp, 8        	; return the stack pointer to the state before calling the print_num
; ###########################################################
print_hex:
	; arguments:
	; [r7 - 16] - cursor offset (row*80 + col)
	; [r7 - 12] - number to be printed
	; local variables:
	; [r7 + 4] <-> [r7 + 20] - one local variable, holding an array of characters (8 words == 16 bytes) to be printed

	; prepare the stack frame
	push r7          		; save the current frame pointer
	mov.w r7, sp       		; load the stack frame pointer from the sp
	sub.w sp, 20       		; move sp to go out of the current stack frame, so we could call another function from this one
                   		; this is how much we should add: add sp, <size_of_local_variables_space> + 4
                   		; here we have array of the five words, so it is 16 + 4
	push r0
	push r1
	push r2
	push r3
	push r6
	
	mov.w r0, 0          	; fill the array of characters with zeroes
	mov.w r1, 8
	mov.w r6, r7
	
again_hex1:
	st.s [r6 - 4], r0					; st [r6 + 4], r0

	sub.w r6, 2
	dec.w r1
	jnz again_hex1

	ld.w r0, [r7 + 8]  				; ld r0, [r7 - 12]   load r0 with the number to be printed (the first and the only argument of this function)
	mov.w r1, 0						; counter of digits
	mov.w r6, r7
again_hex2:	
	inc.w r1            	; increment the digit counter
	sub.w r6, 2						; move to the next position in memory
	mov.w r2, r0
	and.w r2, 15
	shr.w r0, 4       		; divide by 10; the result is in r0, while the remainder (digit) is in the h register
	st.s [r6], r2   				; write the digit into the character array
	cmp.w r0, 0
	jnz again_hex2        	; if the result is 0, we finish
	
  ; at this moment, the r7 + 4 points to the last digit in the character array (digits are stored in the reverse order)
  ; at this moment, the r1 holds the number of digits
  
  mov.w r2, VIDEO     ; write digits into the VIDEO memory
  
  add.w r2, [r7 + 12]  				; add r2, [r7 - 16]    add cursor offset to the beginning of the video memory
  dec.w r1
again_hex3:  
  ld.s r0, [r6]      		; load the current digit
  cmp.w r0, 10
  jge hex_letter
  add.w r0, 48          ; make it an ascii character
back_hex:  
  st.s [r2], r0       
  add.w r2, 2						; move to the next character in video memory
  add.w r6, 2						; move to the next digit in memory
  dec.w r1
  jp again_hex3

	pop r6
	pop r3
	pop r2
	pop r1
	pop r0
  
	; clean up before returning
	mov.w sp, r7	       	; restore the old stack pointer
	pop r7						 	; restore the old frame pointer
	ret
hex_letter:
	sub.w r0, 10
	add.w r0, 65
	j back_hex
