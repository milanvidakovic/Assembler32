#include "consts.asm"
; this is a snakes game 
UP    = 0
DOWN  = 2
LEFT  = 3
RIGHT = 1
STARTY = 15
HEIGHT = 40

#addr PROGRAM_START
; ########################################################
; REAL START OF THE PROGRAM
; ########################################################

	mov.s sp, 0x3000

	mov.w r0, 0
	out [PORT_VIDEO_MODE], r0  ; set the video mode to text

	mov.w r0, 1
	out [VGA_TEXT_INVERSE], r0; make black letters on white background

	mov.w r0, 0
	mov.w r1, n
	mov.w r2, 5000
w1:
	st.s [r1], r0
	add.w r1, 2
	dec.w r2
	jnz w1
	
	st.s [state], r0
	st.s [substate], r0
	st.s [is_key_pressed], r0
	st.s [VIRTUAL_KEY_ADDR], r0	; reset the virtual key code
	
	call clrscr
	
	; set the IRQ handler for keyboard to our own IRQ handler
	mov.s r0, 1							; JUMP instruction opcode
	mov.s r1, PS2_HANDLER_ADDR			; IRQ#2 vector address
	st.s [r1], r0
	mov.w r0, irq_triggered
	mov.s r1, PS2_HANDLER_ADDR + 2	  
	st.w [r1], r0						; the keyboard IRQ handler has been set

	mov.s r0, 0
	st.s [VIRTUAL_KEY_ADDR], r0	; reset the virtual key code

	mov.s r0, 1							; JUMP instruction opcode
	mov.s r1, KEY_PRESSED_HANDLER_ADDR
	st.s [r1], r0
	mov.w r0, pressed				; key pressed routine address
	mov.s r1, KEY_PRESSED_HANDLER_ADDR + 2
	st.w [r1], r0

	mov.s r0, 1							; JUMP instruction opcode
	mov.s r1, KEY_RELEASED_HANDLER_ADDR
	st.s [r1], r0
	mov.w r0, released			; key released routine address
	mov.s r1, KEY_RELEASED_HANDLER_ADDR + 2
	st.w [r1], r0

	in r0, [PORT_MILLIS]		; get current number of milliseconds
	st.s [seed], r0

snakes_again:
	mov.s r0, 0
	st.s [VIRTUAL_KEY_ADDR], r0	; reset the virtual key code
	st.s [n], r0
	st.s [end], r0
	st.s [points], r0

	call draw_frame

	call print_status

	call init_snake
	call draw_snake		
	call calculate_star
	
	ld.s r0, [sx]
	st.s [x], r0
	ld.s r0, [sy]
	st.s [y], r0				; GotoXY(sx, sy); 
	mov.s r0, 42				; '*'
	call putc					; write('*');

; $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
main_snake_loop:	
	ld.s r0, [end]
	cmp.s r0, 1
	jz game_over
	
	ld.s r0, [is_key_pressed]
	cmp.s r0, 1
	jz key_is_pressed
	
main1:
	call move_snake
	mov.s r0, 100
	call delay	
	
	j main_snake_loop
; $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

; #############################################################################
; #############################################################################
; Subroutine which is called whenever some byte arrives from the PS/2 keyboard
; #############################################################################
; #############################################################################
irq_triggered:	
	
	push r0
	push r1
	push r2

	in r0, [PORT_KEYBOARD] 	; r0 holds the keyboard scancode

	mov.s r1, 0
	ld.s r2, [state]
	cmp.w r1, r2	
	jz make_code	; state 0 - try to parse received scancode into the virtual key make code (key pressed)

	inc.w r1
	cmp.w r1, r2
	jz break_code	; state 1 - try to parse received scancode into the virtual key break code (key released)
	
skip:
	pop r2
	pop r1                 
	pop r0
	iret									 

game_over:	
	ld.s r0, [is_key_pressed]
	cmp.s r0, 1
	jz go_key
	j game_over
go_key:
	mov.s r0, 0
	st.s [is_key_pressed], r0
	ld.s r0, [VIRTUAL_KEY_ADDR]
	cmp.s r0, VK_ENTER
	jz snakes_again
	j game_over
	halt

key_is_pressed:
	mov.s r0, 0
	st.s [is_key_pressed], r0
	
	ld.s r0, [VIRTUAL_KEY_ADDR]
	cmp.s r0, VK_UP_ARROW
	jz go_up
	cmp.s r0, VK_DOWN_ARROW
	jz go_down
	cmp.s r0, VK_LEFT_ARROW
	jz go_left
	cmp.s r0, VK_RIGHT_ARROW
	jz go_right
	
go_up:
	ld.s r0, [direction]
	cmp.s r0, DOWN
	jz main1
	mov.s r0, UP
	st.s [direction], r0		; if (c = up) and (smer <> 2) then smer := 0
	j main1
go_down:
	ld.s r0, [direction]
	cmp.s r0, UP
	jz main1
	mov.s r0, DOWN
	st.s [direction], r0		; else if (c = down) and (smer <> 0) then smer := 2
	j main1
go_left:
	ld.s r0, [direction]
	cmp.s r0, RIGHT
	jz main1
	mov.s r0, LEFT
	st.s [direction], r0		; else if (c = left) and (smer <> 1) then smer := 3
	j main1
go_right:
	ld.s r0, [direction]
	cmp.s r0, LEFT
	jz main1
	mov.s r0, RIGHT
	st.s [direction], r0		; else if (c = right) and (smer <> 3) then smer := 1
	j main1
			
; ##################################################################
; function pressed()
; called when a key is pressed
; ##################################################################
pressed:	
;	ld r0, [VIRTUAL_KEY_ADDR]			; get the VK of the key pressed
	push r0
	
	mov.s r0, 1
	st.s [is_key_pressed], r0

	pop r0	
	iret
	
; ##################################################################
; function released()
; called when a key is released
; ##################################################################
released:	
;	ld r0, [VIRTUAL_KEY_ADDR]

	iret

seed:
	#d16 19987
a:
	#d16 11035
c:
	#d16 12345
m:
	#d16 32768	

; ##################################################################
; function r0 = random(r1, r2)
; returns pseudo-random number in range from r1 to r2
; ##################################################################

random:
	push r1
	push r2
	push r3
	
	in r0, [PORT_MILLIS]		; get current number of milliseconds
	st.s [a], r0
	ld.s r0, [seed]
	ld.s r3, [a]
	mul.w r0, r3
	ld.s r3, [c]
	add.w r0, r3
	ld.s r3, [m]
	div.w r0, r3
  mov.w r0, h
  st.s [seed], r0

	sub.w r2, r1
  div.w r0, r2
	mov.w r0, h
	cmp.s r0, 0
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

; ##################################################################
; function calculate_star
; calculates a new position of the star
; ##################################################################
calculate_star:
	push r0
	push r1
	push r2
	push r3

cs4:							; repeat	
	mov.s r1, 2
	mov.s r2, 78
	call random
	st.s [sx], r0			; sx := SlucajanBroj(2, 78);
	ld.s r1, [n]
	inc.w r1
	shl.s r1, 1
	add.s r1, zx
	st.s [r1], r0	; zx[N + 1] := sx;
	
	mov.s r1, STARTY + 2
	mov.s r2, STARTY + HEIGHT-2
	call random
	st.s [sy], r0			; sy := SlucajanBroj(3, HEIGHT-2);
	ld.s r1, [n]
	inc.w r1
	shl.s r1, 1
	add.s r1, zy
	st.s [r1], r0	; zy[N + 1] := sy;
	
	mov.s r1, 0					; i := 0;
cs3:
	mov.w r2, r1
	shl.s r2, 1
	add.s r2, zx
	ld.s r0, [r2]	; while (zx[i] <> sx) or (zy[i] <> sy) do
	ld.s r3, [sx]
	cmp.w r0, r3			; (zx[i] <> sx)
	jnz cs1
	mov.w r2, r1
	shl.s r2, 1
	add.s r2, zy
	ld.s r0, [r2]
	ld.s r3, [sy]
	cmp.w r0, r3			; (zy[i] <> sy)
	jz cs2
cs1:	
	inc.w r1					; i := i + 1
	j cs3	

cs2:	
	ld.s r0, [n]
	inc.w r0
	cmp.w r1, r0
	jnz cs4				; until i = N + 1
	
  pop r3
  pop r2
  pop r1
  pop r0
	ret

; ##################################################################
; function draw_frame
; draws a frame around the screen
; ##################################################################
draw_frame:
	push r0
	push r1
	push r2
	
	call clrscr

	mov.s r0, 30
	st.s [x], r0
	mov.s r0, STARTY
	st.s [y], r0		; GotoXY(30, 0)
	mov.w r0, points_str
	call write		; write("POINTS: ");
	
	mov.s r0, 0
	st.s [x], r0
	mov.s r0, STARTY + 1
	st.s [y], r0		; GotoXY(0, 1)
	mov.s r0, 43		; '+'
	call putc			; write('+');
	mov.s r0, 45		; '-'
	mov.s r1, 0
df1:	
	call putc			;for i := 0 to 78 do write('-');
	inc.w r1
	cmp.w r1, 78
	js df1
	
	mov.s r0, 43		; '+'
	call putc			; write('+');
	
	mov.s r1, STARTY + 2
df3:						; for i := 2 to HEIGHT-2 do begin
	mov.s r0, 0
	st.s [x], r0
	st.s [y], r1		; GotoXY(0, i);
	mov.s r0, 124		; '|'
	call putc			; write('|');
	mov.s r0, 79
	st.s [x], r0
	st.s [y], r1		; GotoXY(79, i);
	mov.s r0, 124		; '|'
	call putc			; write('|')
	inc.w r1
	cmp.s r1, STARTY + HEIGHT-2
	jse df3				; end
	
	mov.s r0, 0
	st.s [x], r0
	mov.s r0, STARTY + HEIGHT-1
	st.s [y], r0		; GotoXY(0, HEIGHT-1);
	mov.s r0, 43		; '+'
	call putc			; write('+');

	mov.s r0, 45		; '-'
	mov.s r1, 0
df4:	
	call putc			;for i := 0 to 78 do write('-');
	inc.w r1
	cmp.w r1, 78
	js df4

	mov.s r0, 43		; '+'
	call putc			; write('+');

	pop r2
	pop r1
	pop r0
	ret

; ##################################################################
; function putc(r0)
; prints a single character
; reads x and y variables and updates them
; ##################################################################
putc:
	push r1
	push r2
	
	ld.s r1, [x]
	shl.s r1, 1
	ld.s r2, [y]
	mul.s r2, 160
	add.w r1, r2
	add.s r1, VIDEO
	st.s [r1], r0
	ld.s r1, [x]
	ld.s r2, [y]
	inc.w r1
	cmp.s r1, 80
	jz putc1

putc2:	
	st.s [x], r1
	st.s [y], r2
	
	pop r2
	pop r1
	ret
	
putc1:
	mov.s r1, 0
	inc.w r2
	cmp.s r2, HEIGHT
	jz putc3
	j putc2
putc3:
	mov.s r2, 0
	j putc2		

; ##################################################################
; function write(r0)
; prints the string
; ##################################################################
write:
	push r1
	mov.w r1, r0
wr2:	
	ld.b r0, [r1]
	cmp.s r0, 0
	jz wr1
	call putc
	inc.w r1
	j wr2
	
wr1:	
	pop r1
	ret
		
; ##################################################################
; function clrscr
; clears the screen
; ##################################################################
clrscr:
	push r0
	push r1
	push r2
	mov.s r0, 0
	mov.s r1, VIDEO
	mov.s r2, 80*60
clrscr1:	
	st.s [r1], r0
	add.w r1, 2
	dec.w r2
	jnz clrscr1
	
	pop r2
	pop r1
	pop r0	
	ret


; ##################################################################
; function print_status()
; prints the status
; ##################################################################
print_status:
	push r0
	push r1

	mov.s r1, 37
	st.s [x], r1
	mov.s r1, STARTY
	st.s [y], r1			; GotoXY(7, 0);
	ld.s r0, [points]
	mov.w r1, buffer
	call int2str
	mov.w r0, buffer
	call write	
	
	pop r1
	pop r0
	ret

; ##################################################################
; function int2str(r0, r1)
; converts integer to string
; r0 holds the number to be converted
; r1 holds the address of the buffer to receive string
; ##################################################################
int2str:
	push r2
	push r3
	
	mov.s r3, 0						; counter of digits
	mov.w r2, buffer_d
i2s1:	
	div.s r0, 10       		; divide by 10; the result is in r0, while the remainder (digit) is in the h register
	
	st.s [r2], h   				; write the digit into the character array
	inc.w r3            	; increment the digit counter
	add.s r2, 2						; move to the next position in buffer
	cmp.s r0, 0
	jnz i2s1	        	; if the result is 0, we finish

  sub.s r2, 2
i2s2:  
  ld.s r0, [r2]      		; load the current digit
  add.s r0, 48          ; make it an ascii character
  st.b [r1], r0       
  
  sub.s r2, 2
  inc.w r1
  dec.w r3
  jp i2s2
	
	mov.s r0, 0
	dec.w r1
	st.b [r1], r0
		
	pop r3
	pop r2
	ret

; ##################################################################
; function init_snake()
; initializes the snake
; ##################################################################
init_snake:
	push r0
	push r1
	push r2
	
	mov.s r0, 2
	st.s [n], r0				; N := 2;
	
	mov.s r1, 10
	mov.s r2, 72
	call random
	st.s [zx], r0				; zx[0] := SlucajanBroj(10, 72);

	mov.s r1, STARTY + 10
	mov.s r2, STARTY + 17
	call random
	st.s [zy], r0				; zy[0] := SlucajanBroj(10, 17);

	mov.s r1, 0
	mov.s r2, 3
	call random				
	st.s [direction], r0	; smer  := SlucajanBroj(0, 3);
	
	cmp.s r0, UP
	jz init_snakeUP
	cmp.s r0, RIGHT
	jz init_snakeRIGHT
	cmp.s r0, DOWN
	jz init_snakeDOWN
	cmp.s r0, LEFT
	jz init_snakeLEFT

init_snake_end:
	pop r2
	pop r1
	pop r0
	ret
init_snakeUP:
	mov.w r1, zx
	ld.s r0, [r1]				
	add.s r1, 2
	st.s [r1], r0		; zx[1] := zx[0];

	mov.w r2, zy
	ld.s r0, [r2]
	inc.w r0
	add.s r2, 2
	st.w [r2], r0		; zy[1] := zy[0] + 1;

	mov.w r1, zx
	ld.s r0, [r1]				
	add.s r1, 4
	st.s [r1], r0		; zx[2] := zx[0];
	
	mov.w r2, zy
	ld.s r0, [r2]
	add.s r0, 2
	add.s r2, 4
	st.w [r2], r0		; zy[2] := zy[0] + 2	

	j init_snake_end

init_snakeRIGHT:
	mov.w r1, zx
	mov.w r2, zy

	ld.s r0, [r2]				
	add.s r2, 2
	st.s [r2], r0		; zy[1] := zy[0];

	ld.s r0, [r1]
	dec.w r0
	add.s r1, 2
	st.s [r1], r0		; zx[1] := zx[0] - 1;

	mov.w r1, zx
	mov.w r2, zy
	
	ld.s r0, [r2]				
	add.s r2, 4
	st.s [r2], r0		; zy[2] := zy[0]; 
	ld.s r0, [r1]
	sub.s r0, 2
	add.s r1, 4
	st.s [r1], r0		; zx[2] := zx[0] - 2

	j init_snake_end

init_snakeDOWN:
	mov.w r1, zx
	mov.w r2, zy

	ld.s r0, [r1]				
	add.s r1, 2
	st.s [r1], r0		; zx[1] := zx[0];

	ld.s r0, [r2]
	dec.w r0
	add.s r2, 2
	st.s [r2], r0		; zy[1] := zy[0] - 1;

	mov.w r1, zx
	mov.w r2, zy

	ld.s r0, [r1]				
	add.s r1, 4
	st.s [r1], r0		; zx[2] := zx[0];
	ld.s r0, [r2]
	sub.s r0, 2
	add.s r2, 4
	st.s [r2], r0		; zy[2] := zy[0] - 2

	j init_snake_end

init_snakeLEFT:
	mov.w r1, zx
	mov.w r2, zy

	ld.s r0, [r2]				
	add.s r2, 2
	st.s [r2], r0		; zy[1] := zy[0];
	
	ld.s r0, [r1]
	inc.w r0
	add.s r1, 2
	st.s [r1], r0		; zx[1] := zx[0] + 1;

	mov.w r1, zx
	mov.w r2, zy

	ld.s r0, [r2]				
	add.s r2, 4
	st.s [r2], r0		; zy[2] := zy[0];
	
	ld.s r0, [r1]
	add.s r0, 2
	add.s r1, 4
	st.s [r1], r0		; zx[2] := zx[0] + 2

	j init_snake_end

; ##################################################################
; function draw_snake()
; draws a snake
; ##################################################################
draw_snake:
	push r0
	push r1
	push r2
	
	ld.s r0, [zx]
	st.s [x], r0
	
	ld.s r0, [zy]
	st.s [y], r0				; GotoXY(zx[0], zy[0]);
	
	mov.s r0, 64				; '@'
	call putc					; write('@');
	
	mov.s r1, 1					;   for i := 1 to N do begin
ds1:	
	mov.w r2, r1
	shl.s r2, 1
	add.s r2, zx
	ld.s r0, [r2]				
	st.s [x], r0

	mov.w r2, r1
	shl.s r2, 1
	add.s r2, zy
	ld.s r0, [r2]
	st.s [y], r0				; GotoXY(zx[i], zy[i]);

	mov.s r0, 79				; 'O'
	call putc					; write('O');
	inc.w r1
	ld.s r0, [n]
	cmp.w r1, r0
	jse ds1
	
	pop r2
	pop r1
	pop r0
	ret

; ##################################################################
; function calculate_position()
; calculate snake head position
; places new x and y coordinates, depending on the direction
; ##################################################################
calculate_position:
	push r0
	
	;   { 0 - up, 1 - right, 2 - down, 3 - left }
	ld.s r0, [direction]	; case smer of
	cmp.s r0, UP
	jz cpUP
	cmp.s r0, RIGHT
	jz cpRIGHT
	cmp.s r0, DOWN
	jz cpDOWN
	cmp.s r0, LEFT
	jz cpLEFT
	
cp_end:	
	pop r0
	ret
cpUP:
	ld.s r0, [zx]
	st.s [xx], r0				; x := zx[0];
	ld.s r0, [zy]
	dec.w r0
	st.s [yy], r0				; y := zy[0] - 1;
	j cp_end
cpRIGHT:
	ld.s r0, [zx]
	inc.w r0
	st.s [xx], r0				; x := zx[0] + 1;
	ld.s r0, [zy]
	st.s [yy], r0				; y := zy[0]
	j cp_end
cpDOWN:
	ld.s r0, [zx]
	st.s [xx], r0				; x := zx[0];
	ld.s r0, [zy]
	inc.w r0
	st.s [yy], r0				; y := zy[0] + 1
	j cp_end
cpLEFT:
	ld.s r0, [zx]
	dec.w r0
	st.s [xx], r0				; x := zx[0] - 1;
	ld.s r0, [zy]
	st.s [yy], r0				; y := zy[0]
	j cp_end
	
; ##################################################################
; function r0 = hit_wall()
; returns 1 if the snake has hit the wall
; ##################################################################
hit_wall:
	ld.s r0, [xx]
	cmp.s r0, 0				; x == 0
	jz hit1
	cmp.s r0, 79			; x == 79
	jz hit1
	ld.s r0, [yy]
	cmp.s r0, STARTY + 1				; y == 1
	jz hit1
	cmp.s r0, STARTY + HEIGHT-1			; y == HEIGHT-1
	jz hit1
	mov.s r0, 0
	j hit_end
hit1:
	mov.s r0, 1
hit_end:	
	ret		

; ##################################################################
; function r0 = hit_tail()
; returns 1 if the snake has hit its own tail
; ##################################################################
hit_tail:
	push r1
	push r2
	push r3
	push r4
	push r5
	
	ld.s r0, [n]
	inc.w r0							; N + 1
	shl.s r0, 1
	ld.s r1, [xx]
	add.s r0, zx
	st.s [r0], r1		; zx[N + 1] := x;
	
	ld.s r0, [n]
	inc.w r0							; N + 1
	shl.s r0, 1
	ld.s r2, [yy]
	add.s r0, zy
	st.s [r0], r2		; zy[N + 1] := y;
	
	mov.w r3, zx
	mov.w r4, zy
	mov.s r5, 0					
ht1:	
	add.s r3, 2
	add.s r4, 2
	inc.w r5						; i := 1;
	ld.s r0, [r3]
	cmp.w r0, r1				; x <> zx[i]
	jnz ht1
	ld.s r0, [r4]
	cmp.w r0, r2				; y <> zy[i]
	jnz ht1						; while (x <> zx[i]) or (y <> zy[i]) do i := i + 1;

ht2:
	ld.s r0, [n]				; r0 <- N
	cmp.w r5, r0				; r5 <- i
	jse ht_true
	mov.s r0, 0
ht_end:	
	pop r5
	pop r4
	pop r3
	pop r2
	pop r1
	ret
ht_true:
	mov.s r0, 1
	j ht_end
	
; ##################################################################
; function move_snake()
; moves snake
; ##################################################################
move_snake:
	push r1
	push r2
	push r3

	call calculate_position
	call hit_wall						
	cmp.s r0, 1
	jz game_end
	call hit_tail
	cmp.s r0, 1
	jz game_end				; if hit_wall or hit_tail then goto end

	ld.s r0, [xx]
	ld.s r3, [sx]
	cmp.w r0, r3			; x == sx
	jnz move_on
	ld.s r0, [yy]
	ld.s r3, [sy]
	cmp.w r0, r3			; y == sy
	jnz move_on
	; we have reached the star
	ld.s r0, [zx]
	st.s [x], r0
	ld.s r0, [zy]
	st.s [y], r0			; GotoXY(zx[0], zy[0]);
	mov.s r0, 79			; 'O'
	call putc				; write('O');	

	ld.s r0, [xx]
	st.s [x], r0
	ld.s r0, [yy]
	st.s [y], r0			; GotoXY(x, y);
	mov.s r0, 64			; '@'
	call putc				; write('@');	
	
	ld.s r3, [n]
	inc.w r3
	st.s [n], r3					; N := N + 1;
	
	ld.s r0, [n]
ms1:							; for i := N downto 1 do begin	
	mov.w r3, r0
	shl.s r3, 1
	mov.w r1, zx
	add.w r1, r3
	sub.w r1, 2
	ld.s r2, [r1]
	add.s r1, 2
	st.s [r1], r2			; zx[i] := zx[i-1];

	mov.w r3, r0
	shl.w r3, 1
	mov.w r1, zy
	add.w r1, r3
	sub.s r1, 2
	ld.s r2, [r1]
	add.s r1, 2
	st.s [r1], r2			; zy[i] := zy[i-1];
	
	dec.w r0
	cmp.s r0, 0
	jnz ms1					; end
	
	ld.s r0, [xx]
	st.s [zx], r0			; zx[0] := x;
	ld.s r0, [yy]
	st.s [zy], r0			; zy[0] := y;
	
	ld.s r0, [points]
	add.s r0, 10
	st.s [points], r0	; Poeni := Poeni + 10;
	
	call print_status
	call calculate_star
	ld.s r0, [sx]
	st.s [x], r0
	ld.s r0, [sy]
	st.s [y], r0		; GotoXY(sx, sy);
	mov.s r0, 42		; '*'
	call putc			; write('*');
	j ms_end
	
move_on:					; else begin
	mov.w r1, zx
	ld.s r0, [n]
	shl.s r0, 1
	add.w r1, r0
	ld.s r0, [r1]
	st.s [x], r0		; GotoXY(zx[N], zy[N]);
	
	mov.w r1, zy
	ld.s r0, [n]
	shl.s r0, 1
	add.w r1, r0
	ld.s r0, [r1]
	st.s [y], r0		; GotoXY(zx[N], zy[N]);
	mov.s r0, 32		; ' '
	call putc			; write(' ');

	ld.s r0, [zx]
	st.s [x], r0		; GotoXY(zx[0], zy[0]);
	
	ld.s r0, [zy]
	st.s [y], r0		; GotoXY(zx[0], zy[0]);
	mov.s r0, 79		; 'O'
	call putc			; write('O');

	ld.s r0, [xx]
	st.s [x], r0		; GotoXY(x, y);
	
	ld.s r0, [yy]
	st.s [y], r0		; GotoXY(x, y);
	mov.s r0, 64		; '@'
	call putc			; write('@');
	
	ld.s r0, [n]
ms2:							; for i := N downto 1 do begin	
	mov.w r3, r0
	shl.w r3, 1
	mov.w r1, zx
	add.w r1, r3
	sub.w r1, 2
	ld.s r2, [r1]
	add.s r1, 2
	st.s [r1], r2			; zx[i] := zx[i-1];

	mov.w r3, r0
	shl.w r3, 1
	mov.w r1, zy
	add.w r1, r3
	sub.w r1, 2
	ld.s r2, [r1]
	add.s r1, 2
	st.s [r1], r2			; zy[i] := zy[i-1];
	
	dec.w r0
	cmp.s r0, 0
	jnz ms2					; end
	
	ld.s r0, [xx]
	st.s [zx], r0			; zx[0] := x;
	ld.s r0, [yy]
	st.s [zy], r0			; zy[0] := y;

ms_end:	
	pop r3
	pop r2
	pop r1
	ret
game_end:
	mov.s r0, 1
	st.s [end], r0		; kraj := true;
	ld.s r0, [xx]
	st.s [x], r0
	ld.s r0, [yy]
	st.s [y], r0
	mov.s r0, 88			; 'X'
	call putc				; GotoXY(x, y); write('X')
	j ms_end		

; #######################################################################################
; function wipe_screen(ro)
; deletes a screen with a given number of characters to be deleted, starting from the first character (0, 0)
; #######################################################################################
wipe_screen:
	push r1
	push r2
	
	mov.s r1, VIDEO
	mov.w r2, r0				; r2 holds the number_of_characters_to_be_deleted
	mov.s r0, 0
ws_loop1:
	st.s [r1], r0
	add.s r1, 2
	dec.w r2
	jp ws_loop1
	pop r2	
	pop r1	
ret

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
	in r2, [PORT_MILLIS]
	sub.w r2, r1
	jz delay_loop1			; one millisecond elapsed here
	dec.w r0
	jnz delay_loop2
	
	pop r2
	pop r1
	ret

send_serial:	
	push r5
ss1:
	in r5, [PORT_UART_TX_BUSY]   ; tx busy in r5
	cmp.s r5, 0     
	jz ss2   ; if not busy, send back the received character 
	j ss1
	
ss2:
	out [PORT_UART_TX_SEND_BYTE], r0  ; send the character to the UART
	
	pop r5
	ret


; ##################################################################
; function make_code(r0)
; parses the virtual key code of the pressed key
; ##################################################################
make_code:
	in r0, [PORT_KEYBOARD]
	
	ld.s r1, [substate]
	cmp.s r1, 0
	jz make0				; state 0 - the first byte of the make code; if not extended, this will be the only byte of the make code
	cmp.s r1, 1
	jz make1				; state 1 - the second and other bytes of the make code - the extended make codes have multiple bytes

	j skip

make0:
	cmp.s r0, 0xF0
	jz	break_code	; two keys pressed fast, so instead of make code, here cames the other break code
	cmp.s r0, 0xE0
	jz extended0		; check if the received make code is the extended0 (E0)
	cmp.s r0, 0xE1
	jz extended1		; check if the received make code is the extended 1 (E1)

	; not	extended code - it is a normal key, with just one make code byte
	shl.s r0, 1
	add.w r0, vk_table1
	ld.s r1, [r0]			; fetch the virtual key code based on the make code
	st.s [VIRTUAL_KEY_ADDR], r1		; save the parsed virtual key code

	mov.s r0, 1
	st.s [state], r0 	; set the next state (1) - ready to receive break code
	mov.s r0, 0
	st.s [substate], r0
	
	pop r2
	pop r1
	pop r0
	j KEY_PRESSED_HANDLER_ADDR
	
	;j exec						; try to either print the character, or move the cursor

extended0:
	; Extended0 keys heve two make/break bytes; the first is E0, and the second determines the key
	mov.s r0, 1
	st.s [substate], r0	; prepare for the second byte
	j skip

extended1:
	j skip

make1:
	; the second byte has just arrived
	; it is in the r0 register
	in r0, [PORT_KEYBOARD]
	
	; first check for the Print Screen key
	cmp.s r0, 12
	jz mk_print_screen
	
	mov.w r2, vk_table2
make2_1:	
	ld.s r1, [r2]
	cmp.s r1, 0xFFFF
	jz make2_end	; end of the table; should not happen
	cmp.w r0, r1
	jz found_e0
	add.w r2, 4
	j make2_1
found_e0:

	; found the received second byte in the table
	add.w r2, 2
	ld.s r1, [r2] 	; get the VK
	st.s [VIRTUAL_KEY_ADDR], r1	; save it for the exec
	
	mov.s r0, 1
	st.s [state], r0
	mov.s r0, 0
	st.s [substate], r0 ; prepare for the break code waiting

	pop r2
	pop r1
	pop r0
	j KEY_PRESSED_HANDLER_ADDR
	
	;j exec	

make2_end:
	; second make code not found in the vk_table2; then it should be break code
	mov.s r1, 0
	st.s [state], r1
	st.s [substate], r1 ; prepare for the make code waiting

	j skip

mk_print_screen:
	mov.s r0, 0
	st.s [substate], r0
	j skip	
	

; ##################################################################	
; function break_code(r0)
;
; ##################################################################	
break_code:
	mov.s r1, 1
	st.s [state], r1
	
	ld.s r1, [substate]
	cmp.s r1, 0
	jz break0		; we have received the first break byte
	cmp.s r1, 1
	jz break1		; we have received the second break byte (extended key or special case of long press or fast click)
	cmp.s r1, 2
	jz break2		; we have received the second break byte (normal key handler)
	cmp.s r1, 3
	jz break3		; we have received the third break byte (extended key handler)
	
	j skip

break0:
	cmp.s r0, 0xF0
	jz break_f0
	cmp.s r0, 0xE0
	jz break_e0
	cmp.s r0, 0xE1
	jz break_e1		; print screen pressed very fast, and this is actually the make code
	
	j make_code		; two keys pressed fast, so two make codes came one after another

break_f0:
	mov.s r0, 2
	st.s [substate], r0		; set the substate to wait for the second break byte
	j skip

break_e0:
	mov.s r0, 1
	st.s [substate], r0		; set the substate to wait for the second break byte, which is maybe a make code (long press)
	j skip

break_e1:
	; this is a special case when after E0 key comes the Print Screen very fast
	mov.s r0, 1
	st.s [substate], r0		; set the substate to wait for the second make byte
	mov.s r0, 0
	st.s [state], r0			; set the state to be wait for the make code
	
	j skip

break1:
	; we have just received the second break byte
	cmp.s r0, 0xF0
	jz more_breaks
	
	; we will try to parse this second byte as a make code
	; it happens when you long press non-printable character
	; then, multiple make codes arrive, instead of a break code
	j make1

more_breaks:
	; this part of code handles break code of extended E0 keys
	mov.s r0, 3
	st.s [substate], r0
	
	j skip

break2:
	cmp.s r0, 0x7C
	jz br_print_screen
	
	; not	extended code - it is a normal key
	shl.s r0, 1
	add.w r0, vk_table1
	ld.s r1, [r0]	; fetch the virtual key code based on the make code
	st.s [VIRTUAL_KEY_ADDR], r1		; save the parsed virtual key code
	
	mov.s r0, 0
	st.s [substate], r0
	st.s [state], r0

	pop r2
	pop r1
	pop r0
	j KEY_RELEASED_HANDLER_ADDR

;	j skip

break3:
	; extended key break code
	mov.w r2, vk_table2
break3_1:	
	ld.s r1, [r2]
	cmp.s r1, 0xFFFF
	jz break3_end	; end of the table; should not happen
	cmp.w r0, r1
	jz found_break_e0
	add.s r2, 4
	j break3_1

found_break_e0:

	; found the received third byte in the table
	add.s r2, 2
	ld.s r1, [r2] 	; get the VK
	st.s [VIRTUAL_KEY_ADDR], r1	; save it for the exec

	mov.s r0, 0
	st.s [substate], r0
	st.s [state], r0
	
	pop r2
	pop r1
	pop r0
	j KEY_RELEASED_HANDLER_ADDR	

break3_end:
	; third break code not found in the vk_table2; 
	mov.s r1, 0
	st.s [state], r1
	st.s [substate], r1 ; prepare for the make code waiting

	j skip

br_print_screen:
	mov.s r0, 0
	st.s [substate], r0
	j skip		
	

vk_table1:
	; Basic key table
	#d16 256												;00 -
	#d16 VK_F9											;01 - F9		
	#d16 256												;02 - 		
	#d16 VK_F5											;03 - F5		
	#d16 VK_F3											;04 - F3		
	#d16 VK_F1											;05 - F1		
	#d16 VK_F2											;06 - F2		
	#d16 VK_F12											;07 - F12		
	#d16 256												;08 - 	
	#d16 VK_F10											;09 - F10		
	#d16 VK_F8											;10 - F8		
	#d16 VK_F6											;11 - F6		
	#d16 VK_F4											;12 - F4		
	#d16 VK_TAB											;13 - TAB	
	#d16 VK_BACK_QUOTE							;14 - `	(TO THE LEFT OF THE 1 KEY)
	#d16 256												;15 - 		
	#d16 256												;16 - 		
	#d16 VK_LEFT_ALT								;17 - Left Alt		
	#d16 VK_LEFT_SHIFT							;18 - Left Shift		
	#d16 256												;19 - 		
	#d16 VK_LEFT_CONTROL						;20 - Left Ctrl		
	#d16 VK_Q												;21 - Q		
	#d16 VK_1												;22 - 1		
	#d16 256												;23 - 		
	#d16 256												;24 - 		
	#d16 256												;25 - 		
	#d16 VK_Z												;26 - Z		
	#d16 VK_S												;27 - S
	#d16 VK_A												;28 - A
	#d16 VK_W												;29 - W
	#d16 VK_2												;30 - 2
	#d16 256												;31 - 
	#d16 256												;32 - 		
	#d16 VK_C												;33 - C		
	#d16 VK_X												;34 - X
	#d16 VK_D												;35 - D
	#d16 VK_E												;36 - E	
	#d16 VK_4												;37 - 4
	#d16 VK_3												;38 - 3
	#d16 256												;39 - 
	#d16 256												;40 - 		
	#d16 VK_SPACE										;41 - SPACE		
	#d16 VK_V												;42 - V
	#d16 VK_F												;43 - F
	#d16 VK_T												;44 - T
	#d16 VK_R												;45 - R
	#d16 VK_5												;46 - 5
	#d16 256												;47 - 
	#d16 256												;48 - 		
	#d16 VK_N												;49 - N		
	#d16 VK_B												;50 - B
	#d16 VK_H												;51 - H
	#d16 VK_G												;52 - G
	#d16 VK_Y												;53 - Y
	#d16 VK_6												;54 - 6
	#d16 256												;55 - 
	#d16 256												;56 - 		
	#d16 256												;57 - 		
	#d16 VK_M												;58 - M		
	#d16 VK_J												;59 - J
	#d16 VK_U												;60 - U
	#d16 VK_7												;61 - 7
	#d16 VK_8												;62 - 8
	#d16 256												;63 - 
	#d16 256												;64 - 		
	#d16 VK_COMMA										;65 - ,		
	#d16 VK_K												;66 - K
	#d16 VK_I												;67 - I
	#d16 VK_O												;68 - O
	#d16 VK_0												;69 - 0 (ZERO)
	#d16 VK_9												;70 - 9
	#d16 256												;71 - 
	#d16 256												;72 - 		
	#d16 VK_FULL_STOP								;73 - .
	#d16 VK_SLASH										;74 - / (LEFT TO THE RIGHT SHIFT KEY)	
	#d16 VK_L												;75 - L
	#d16 VK_SEMICOLON								;76 - ; (TO THE RIGHT OF THE L KEY)		
	#d16 VK_P												;77 - P
	#d16 VK_MINUS										;78 - - (TO THE RIGHT OF THE ZERO KEY)
	#d16 256												;79 - 
	#d16 256												;80 - 		
	#d16 256												;81 - 		
	#d16 VK_QUOTE										;82 - ' (SECOND TO THE RIGHT OF THE L KEY)		
	#d16 256												;83 - 
	#d16 VK_BRACE_LEFT							;84 - [ (TO THE RIGHT OF THE P KEY)		
	#d16 VK_EQUALS									;85 - = (TO THE LEFT OF THE BACKSPACE KEY)
	#d16 256												;86 - 
	#d16 256												;87 - 		
	#d16 VK_CAPS_LOCK								;88 - CAPS LOCK		
	#d16 VK_RIGHT_SHIFT							;89 - RIGHT SHIFT
	#d16 VK_ENTER										;90 - ENTER
	#d16 VK_BRACE_RIGHT							;91 - ] (SECOND RIGHT TO THE P KEY)
	#d16 256												;92 - 
	#d16 VK_BACK_SLASH							;93 - \ (BELOW BACKSPACE)
	#d16 256												;94 - 
	#d16 256												;95 - 
	#d16 256 												;96 - 
	#d16 VK_LESS_THAN								;97 - < (TO THE LEFT OF THE Z KEY)
	#d16 256 												;98 - 
	#d16 256 												;99 - 
	#d16 256												;100- 
	#d16 256												;101 - 
	#d16 VK_BACKSPACE								;102 - BACKSPACE
	#d16 256												;103 - 
	#d16 256												;104 - 
	#d16 VK_NUMPAD1									;105 - NUMPAD 1
	#d16 256												;106 - 
	#d16 VK_NUMPAD4									;107 - NUMPAD 4
	#d16 VK_NUMPAD7									;108 - NUMPAD 7
	#d16 256												;109 - 
	#d16 256												;110 - 
	#d16 256												;111 - 
	#d16 VK_NUMPAD0									;112 - NUMPAD 0
	#d16 VK_NUMPAD_DECIMAL					;113 - NUMPAD .
	#d16 VK_NUMPAD2									;114 - NUMPAD 2
	#d16 VK_NUMPAD5									;115 - NUMPAD 5
	#d16 VK_NUMPAD6									;116 - NUMPAD 6
	#d16 VK_NUMPAD8									;117 - NUMPAD 8
	#d16 VK_ESC											;118 - ESC
	#d16 VK_NUM_LOCK								;119 - NUM LOCK
	#d16 VK_F11											;120 - F11
	#d16 VK_NUMPAD_PLUS							;121 - NUMPAD + 
	#d16 VK_NUMPAD3									;122 - NUMPAD 3
	#d16 VK_NUMPAD_SUBTRACT					;123 - NUMPAD -
	#d16 VK_NUMPAD_MULTIPLY					;124 - NUMPAD *
	#d16 VK_NUMPAD9									;125 - NUMPAD 9
	#d16 VK_SCROLL_LOCK							;126 - SCROLL LOCK
	#d16 256												;127 - 
	#d16 256												;128 - 
	#d16 256												;129 - 
	#d16 VK_F7											;130 - F7

vk_table2:
	; Extended key table
	#d16 0x1F, VK_LEFT_WINDOWS			; Left Windows
	#d16 0x11, VK_RIGHT_ALT					; Right Alt
	#d16 0x27, VK_RIGHT_WINDOWS			; Right Windows
	#d16 0x2F, VK_MENU							; Menu key
	#d16 0x14, VK_RIGHT_CONTROL			; Right Control
	#d16 0x70, VK_INSERT						; Insert
	#d16 0x6C, VK_HOME							; Home
	#d16 0x7D, VK_PAGE_UP						; Page Up
	#d16 0x71, VK_DELETE						; Delete
	#d16 0x69, VK_END								; End
	#d16 0x7A, VK_PAGE_DOWN					; Page Down
	#d16 0x75, VK_UP_ARROW					; Up Arrow
	#d16 0x6B, VK_LEFT_ARROW				; Left Arrow
	#d16 0x72, VK_DOWN_ARROW				; Down Arrow
	#d16 0x74, VK_RIGHT_ARROW				; Right Arrow
	#d16 0x4A, VK_NUMPAD_DIVIDE			; NUMPAD /
	#d16 0x5A, VK_NUMPAD_ENTER			; NUMPAD ENTER
	#d16 0x7C, VK_PRINT_SCREEN			; PRINT SCREEN
	#d16 0xFFFF, 0xFFFF	; end marker

vk_char_table:
	#d16 VK_0, 48, 41	; 0, )!
	#d16 VK_1, 49, 33	; 1, !
	#d16 VK_2, 50, 64	; 2, @
	#d16 VK_3, 51, 35	; 3, #
	#d16 VK_4, 52, 36	; 4, $
	#d16 VK_5, 53, 37	; 5, %
	#d16 VK_6, 54, 94	; 6, ^
	#d16 VK_7, 55, 38	; 7, &
	#d16 VK_8, 56, 42	; 8, *
	#d16 VK_9, 57, 40	; 9, (
	
	#d16 VK_BACK_QUOTE, 96, 126	; `, ~
	#d16 VK_MINUS, 45, 95	; -, _
	#d16 VK_EQUALS, 61, 43	; =, +

	#d16 VK_BRACE_LEFT, 91, 123	; [, {
	#d16 VK_BRACE_RIGHT, 93, 125	; ], }
	#d16 VK_SEMICOLON, 59, 58	; ;, :
	#d16 VK_QUOTE, 39, 34	; ', "
	#d16 VK_BACK_SLASH, 92, 124	; \, |
	#d16 VK_COMMA, 44, 60	; ,, <
	#d16 VK_FULL_STOP, 46, 62	; ., >
	#d16 VK_LESS_THAN, 60, 62	; <, >
	#d16 VK_SLASH, 47, 63	; /, ?
	#d16 0xFFFF	

state:
	#d16 0
substate:
	#d16 0
is_key_pressed:
	#d16 0
points_str:
	#str "POINTS: \0"
buffer:
	#d8 0, 0, 0, 0, 0, 0
buffer_d:
	#d16 0, 0, 0, 0, 0, 0
n:
	#d16 0
direction:
	#d16 0
points:
	#d16 0
end:
	#d16 0
key:
	#d16 0
sx:
	#d16 0
sy:
	#d16 0
x:
	#d16 0
y:
	#d16 0
xx:
	#d16 0
yy:
	#d16 0
zx:
	#res 2000
zy:
	#res 2000
