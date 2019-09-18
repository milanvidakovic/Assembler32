; this program will demonstrate sprites
; video memory starts at VIDEO
; each sprite is 16x16pixels
; each sprite byte definition contains two pixels, four bits each: xrgbxrgb
#include "consts.asm"
SPR_DEF = 0x9B00;


#addr PROGRAM_START
; ########################################################
; REAL START OF THE PROGRAM
; ########################################################

	mov.w sp, 0xF000

	mov.w r0, 1
	out [PORT_VIDEO_MODE], r0  ; set the video mode to graphics

	call wipe
	
  mov.w r2, 4			; red color (0100)
  mov.w r0, 50		; A.x = 50
  mov.w r1, 50		; A.y = 50
  mov.w r3, 150		; B.x = 150
  mov.w r4, 150		; B.y = 150
  call line
 
  mov.w r2, 2			; green color (0010)
  mov.w r0, 50		; A.x = 50
  mov.w r1, 50		; A.y = 50
  mov.w r3, 150		; B.x = 150
  mov.w r4, 50		; B.y = 50
	call line
	
 	mov.w r2, 1			; blue color (0001)
 	mov.w r0, 150		; A.x = 150
 	mov.w r1, 50		; A.y = 50
 	mov.w r3, 150		; B.x = 150
 	mov.w r4, 150		; B.y = 150
 	call line

 	mov.w r2, 7			; white color (0111)
 	mov.w r0, 150		; x = 150
 	mov.w r1, 150		; y = 150
 	mov.w r3, 50		; r = 50
 	call circle

end:

	mov.w r0, 0		; x coordinate
	mov.w r1, 150		; y coordinate
	mov.w r2, my_text		; address of a text
	mov.w r3, 4			; red color
	call draw_text

	mov.w r0, 0 + 1		; x coordinate
	mov.w r1, 150+8		; y coordinate
	mov.w r2, my_text		; address of a text
	mov.w r3, 2				; green color
	call draw_text

	mov.w r0, 0 + 2		; x coordinate
	mov.w r1, 150+16		; y coordinate
	mov.w r2, my_text		; address of a text
	mov.w r3, 1				; blue color
	call draw_text
	
	mov.w r0, 1000
	call delay
	
	call copy_sprite_def
	
	mov.w r2, 50
	mov.w r3, 100
sprite_loop:		
	mov.s r0, SPR_DEF
	mov.s r1, SPRITE_DEFINITION_ADDRESS    ; addr 64
	st.s [r1], r0  ; sprite definition is at sprite_def address
	mov.w r0, r2
	st.s [r1 + 2], r0  ; x = 25  at addr 66
	mov.w r0, r2
	st.s [r1 + 4], r0  ; y = 25  at addr 68
	mov.s r0, 0
	st.s [r1 + 6], r0  ; transparent color is black (0) at addr 70

	mov.s r0, SPR_DEF
	mov.s r1, SPRITE_DEFINITION_ADDRESS + 8    ; second sprite at addr 72
	st.s [r1], r0  ; sprite definition is at sprite_def address
	mov.w r0, r2
	add.s r0, 25
	st.s [r1 + 2], r0  ; x = 50  at addr 74
	mov.w r0, r2
	st.s [r1 + 4], r0  ; y = 25  at addr 76
	mov.s r0, 0
	st.s [r1 + 6], r0  ; transparent color is black (0) at addr 78

	mov.s r0, SPR_DEF
	mov.s r1, SPRITE_DEFINITION_ADDRESS + 16    ; third sprite at addr 80 
	st.s [r1], r0  ; sprite definition is at sprite_def address
	mov.w r0, r2
	add.s r0, 50
	st.s [r1 + 2], r0  ; x = 100  at addr 82
	mov.w r0, r2
	st.s [r1 + 4], r0  ; y = 25  at addr 84
	mov.s r0, 0
	st.s [r1 + 6], r0  ; transparent color is black (0) at addr 86

	mov.s r0, SPR_DEF
	mov.s r1, SPRITE_DEFINITION_ADDRESS + 24    ; fourth sprite at addr 88
	st.s [r1], r0  ; sprite definition is at sprite_def address
	mov.w r0, r2
	add.s r0, 75
	st.s [r1 + 2], r0  ; x = 125 at addr 90
	mov.w r0, r2
	st.s [r1 + 4], r0  ; y = 25 at addr 92
	mov.s r0, 0
	st.s [r1 + 6], r0  ; transparent color is black (0) at addr 94

	mov.w r0, 250
	call delay
	
	inc.w r2
	dec.w r3
	jp sprite_loop
	

	halt

copy_sprite_def:
	mov.w r1, sprite_def
	mov.w r2, SPR_DEF
	mov.s r3, 16*8
csd:
	ld.s r0, [r1]
	st.s [r2], r0
	add.w r1, 2
	add.w r2, 2
	dec.w r3
	jp csd
	ret
	
; sprite definition
sprite_def:
  #d16 0x0000, 0x0000, 0x0000, 0x0000  ; 0
  #d16 0x0000, 0x000f, 0xf000, 0x0000  ; 1
  #d16 0x0000, 0x000f, 0xf000, 0x0000  ; 2
  #d16 0x0000, 0x000f, 0xf000, 0x0000  ; 3
  #d16 0x0000, 0x004f, 0xf400, 0x0000  ; 4
  #d16 0x0000, 0x004f, 0xf400, 0x0000  ; 5
  #d16 0x0000, 0x044f, 0xf440, 0x0000  ; 6
  #d16 0x0000, 0x444f, 0xf444, 0x0000  ; 7
  #d16 0x0004, 0x444f, 0xf444, 0x4000  ; 8
  #d16 0x0044, 0x444f, 0xf444, 0x4400  ; 9
  #d16 0x0400, 0x004f, 0xf400, 0x0040  ; 10
  #d16 0x0000, 0x004f, 0xf400, 0x0000  ; 11
  #d16 0x0000, 0x004f, 0xf400, 0x0000  ; 12
  #d16 0x0000, 0x041f, 0xf140, 0x0000  ; 13
  #d16 0x0000, 0x4111, 0x1114, 0x0000  ; 14
  #d16 0x0004, 0x4444, 0x4444, 0x4000  ; 15

  
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


; ####################################################################################################
; function wipe()
; wipes the screen
; ####################################################################################################
wipe:
	mov.w r0, 0
	mov.w r1, VIDEO
	mov.w r2, 320*240/4
w1:
	st.s [r1], r0
	add.w r1, 2
	dec.w r2
	jp w1
	ret

; ####################################################################################################
; function pixel(x, y, c)
; r0 - x
; r1 - y
; r2 - color of the pixel (0 - 7)
; ####################################################################################################
pixel:
	push r0
	push r1
	push r2
	push r3
	push r4
	
	mul.w r1, 160	; gives the offset from the beginning of the framebuffer
	div.w r0, 2		; divide x coordinate by 4; it gives the offset from the beginning of the line
							; h holds the position of the pixel within the byte (0 - 1)
							; r0 is the offset in bytes
	add.w r1, VIDEO
	add.w r0, r1	; r0 holds the address of the pixel (the group of two pixels in that byte)
	
	mov.w r3, 0x1		; set the mask for wiping 
	sub.w r3, h			; (h == 0) -> (r3 == 1); (h == 1) -> (r3 == 0)
	shl.w r3, 2			; r3 = r3 * 4
	mov.w r1, 0xf		; set the mask for one pixel (four bits)
	shl.w r1, r3		; we shift the mask r3 times to the left
	inv.w r1				; invert the mask
	ld.b r4, [r0]	; r4 holds the surrounding pixels
	and.w r4, r1		; we erase the pixel to be changed
	
	shl.w r2, r3	; we shift the color of the pixel r3 times to the left
	or.w r4, r2		; we insert the pixel into surrounding pixels
	
	st.b [r0], r4	; save two pixels into the framebuffer

	pop r4
	pop r3
	pop r2
	pop r1
	pop r0	
	ret
	
; ####################################################################################################
; function line(x0, y0, x1, y1, c)
; r0 - x0	(A.x)
; r1 - y0	(A.y)
; r2 - color of the pixel (0 - 7)
; r3 - x1	(B.x)
; r4 - y1	(B.y)
; ####################################################################################################
line:
	push r0
	push r1
	push r2
	push r3
	push r4
	push r5
	push r6
	push r7
	
	mov.w r5, r4		; r5 = B.y
	sub.w r5, r1  	; r5 = B.y - A.y
	call line_abs	; r5 = abs(r5)
	mov.w r6, r5		; r6 = abs(B.y - A.y)

	mov.w r5, r3		; r5 = B.x
	sub.w r5, r0 		; r5 = B.x - A.x
	call line_abs	; r5 = abs(B.x - A.x)
	
	cmp.w r6, r5 		; if(abs(B.y - A.y) < abs(B.x - A.x)) 	
	js draw_one
	j draw_two
line_end:
	pop r7
	pop r6
	pop r5
	pop r4
	pop r3
	pop r2
	pop r1
	pop r0
	ret

; ######################################################################
draw_one:
	cmp.w r0, r3 		; if(A.x > B.x) 
	jg swap_and_draw_south
	
	j draw_south

swap_and_draw_south:
	swap r0, r3
	swap r1, r4

; draw_south
draw_south:	
	mov.w r6, r3		; r6 = B.x
	sub.w r6, r0		; r6 -> dx = B.x - A.x
	
	mov.w r5, r4		; r5 = B.y
	sub.w r5, r1  	; r5 -> dy = B.y - A.y
	
	mov.w r7, 1			; r7 -> yi
	cmp.w r5, 0			; if (dy < 0)
	js ds1

ds2:
	mov.w r4, r5 		; r4 = dy
	shl.w r4, 1
	sub.w r4, r6 		; r4 -> D = 2 * dy - dx

	shl.w r5, 1			; r5 -> 2*dy
	shl.w r6, 1			; r6 -> 2*dx

ds4:	
  cmp.w r0, r3		; if A.x > B.x then return
	jg line_end
	
	call pixel		; plot(x,y)	
	cmp.w r4, 0			; if (D > 0)
	jg ds3
ds5:	
  add.w r4, r5		; D = D + 2*dy
  
  inc.w r0				; A.x = A.x + 1
  j ds4
	
ds3:
 	add.w r1, r7		; y = y + yi
  sub.w r4, r6		; D = D - 2*dx
  j ds5
ds1:
	mov.w r7, -1		; yi = -1
  neg.w r5  			; dy = -dy
  j ds2
; ######################################################################

; ######################################################################
draw_two:
	cmp.w r1, r4 		; if(A.y > B.y) 
	jg swap_and_draw_north
	
	j draw_north

swap_and_draw_north:
	swap r0, r3
	swap r1, r4

; draw_north
draw_north:	
	mov.w r6, r3		; r6 = B.x
	sub.w r6, r0		; r6 -> dx = B.x - A.x
	
	mov.w r5, r4		; r5 = B.y
	sub.w r5, r1  	; r5 -> dy = B.y - A.y
	
	mov.w r7, 1			; r7 -> xi
	cmp.w r6, 0			; if (dx < 0)
	js dn1

dn2:
	mov.w r3, r6 		; r3 = dx
	shl.w r3, 1
	sub.w r3, r5 		; r3 -> D = 2 * dx - dy

	shl.w r5, 1			; r5 -> 2*dy
	shl.w r6, 1			; r6 -> 2*dx

dn4:	
	cmp.w r1, r4
	jg line_end
	
	call pixel		; plot(x,y)	
	cmp.w r3, 0			; if (D > 0)
	jg dn3
dn5:	
  add.w r3, r6		; D = D + 2*dx
  
  inc.w r1				; A.y = A.y + 1
  j dn4
	
dn3:
 	add.w r0, r7		; x = x + xi
  sub.w r3, r5		; D = D - 2*dy
  j dn5
dn1:
	mov.w r7, -1		; xi = -1
  neg.w r6     		; dx = -dx
  j dn2
; ######################################################################

; ####################################################################################################
; function r5=line_abs(r5)
; r5 = abs(r5)
; ####################################################################################################
line_abs:
	cmp.w r5, 0
	jg la1
	neg.w r5
la1:
	ret

; ####################################################################################################
; function circle(x0, y0, c, r)
; r0 - x0	
; r1 - y0	
; r2 - color of the pixel (0 - 7)
; r3 - radius
; ####################################################################################################
circle:
	push r0
	push r1
	push r2
	push r3
	push r4
	push r5
	push r6
	push r7
	
	mov.w r4, err
	mov.w r7, 0
	st.w [r4], r7
	
	mov.w r4, r3		; r4 -> radius
	sub.w r4, 1			; r4 -> x = radius - 1;
	
	mov.w r5, 0			; r5 -> y = 0
	
	mov.w r6, 1			; r6 -> dx = 1
	mov.w r7, 1			; r7 -> dy = 1
	
	call add_err_dxminus	; err += dx - (radius << 1);

circle_loop:	
	cmp.w r4, r5		; while (x >= y)
	jge circle_body	

circle_end:
	pop r7
	pop r6
	pop r5
	pop r4
	pop r3
	pop r2
	pop r1
	pop r0
	ret
; ########################################################################################################

circle_body:

	push r0				; r4 -> x
	push r1				; r5 -> y
	add.w r0, r4
	add.w r1, r5
	call pixel		;pixel (x0 + x, y0 + y)
	pop r1
	pop r0
	
	push r0
	push r1
	add.w r0, r5
	add.w r1, r4
	call pixel		;pixel (x0 + y, y0 + x)
	pop r1
	pop r0

	push r0
	push r1
	sub.w r0, r5
	add.w r1, r4
	call pixel		;pixel (x0 - y, y0 + x)
	pop r1
	pop r0

	push r0
	push r1
	sub.w r0, r4
	add.w r1, r5
	call pixel		;pixel (x0 - x, y0 + y)
	pop r1
	pop r0

	push r0
	push r1
	sub.w r0, r4
	sub.w r1, r5
	call pixel		;pixel (x0 - x, y0 - y)
	pop r1
	pop r0

	push r0
	push r1
	sub.w r0, r5
	sub.w r1, r4
	call pixel		;pixel (x0 - y, y0 - x)
	pop r1
	pop r0

	push r0
	push r1
	add.w r0, r5
	sub.w r1, r4
	call pixel		;pixel (x0 + y, y0 - x)
	pop r1
	pop r0

	push r0
	push r1
	add.w r0, r4
	sub.w r1, r5
	call pixel		;pixel (x0 + x, y0 - y)
	pop r1
	pop r0

	push r7
	push r4
	mov.w r4, err
	ld.w r7, [r4]
	cmp.w r7, 0				; if (err <= 0) {
	pop r4
	pop r7
	jse c1
c3:
	push r7
	push r4
	mov.w r4, err
	ld.w r7, [r4]
	cmp.w r7, 0				; if (err > 0) {
	pop r4
	pop r7
	jg c2
	j circle_loop

c1:
	inc.w r5					; y++;
	push r7					; r7 -> dy
	push r6
	push r4
	mov.w r4, err
	ld.w r6, [r4]
	add.w r7, r6		; err += dy;
	st.w [r4], r7
	pop r4
	pop r6
	pop r7
	add.w r7, 2				; dy += 2;
	j c3
c2:
	dec.w r4					; x--;
	add.w r6, 2				; dx += 2;
	call add_err_dxminus	;	err += dx - (radius << 1);
	j circle_loop
	
add_err_dxminus:
	; err += dx - (radius << 1);
	push r7				; r7 -> dy
	mov.w r7, r3		; r7 = radius
	shl.w r7, 1			; r7 = (radius << 1)
	push r6				; r6 -> dx
	push r5
	push r4
	mov.w r4, err
	sub.w r6, r7		; r6 = dx - (radius << 1)
	ld.w r5, [r4]
	add.w r6, r5	; err += dx - (radius << 1);
	st.w [r4], r6
	pop r4
	pop r5
	pop r6
	pop r7
	ret
err:
	#d32 0
			

; ####################################################################################################
; function draw_text(x, y, text)
; r0 - x
; r1 - y	
; r2 - address of a text
; r3 - color
; ####################################################################################################
#include "fonts.asm"
draw_text:
	push r0
	push r1
	push r2
	push r3
	push r4
	push r5
	push r6
	push r7
	push r8
	push r9
	push r10

	mul.w r1, 160	; gives the offset from the beginning of the framebuffer for the line (using the y coordinate)
	add.w r1, VIDEO
	div.w r0, 2 	; divide x coordinate by 8; it gives the offset from the beginning of the line
								; r0 is the offset in words (two bytes)
								; h holds the position of the pixel within the byte (0 - 1)
	add.w r0, r1	; r0 holds the address of the pixel (the group of 2 pixels in that byte)
	
draw_text_again:
	ld.b r7, [r2]	; get the current character
	cmp.b r7, 0		; null terminator?
	jz draw_text_end
	
	shl.w r7, 3  ; 8 bytes each character
	mov.w r4, font_8x8
	add.w r4, r7	; r4 points to the beginning of the font definition for the current character
	
	mov.w r1, 7		; 8 lines of font
	push r0
draw_next_line:	
	ld.b r5, [r4]	; r5 holds the current font definition of the current character
	
	cmp.w h, 1
	jz dtp_odd
	
	mov.w r6, 3
	mov.w r7, 128
dt_pagain:	
	mov.w r8, r5
	and.w r8, r7
	cmp.w r8, r7
	callz p0s
dtp1:
	shr.w r7, 1
	mov.w r8, r5
	and.w r8, r7
	cmp.w r8, r7
	callz p1s
dtp2:	
	shr.w r7, 1

	inc.w r0
	dec.w r6
	jp dt_pagain
	sub.w r0, 4

dtp_back:
	inc.w r4			; go to the next font byte
	add.w r0, 160	; go one line below
	dec.w r1
	jp draw_next_line
	pop r0
	add.w r0, 4		; go to the next position to the right
	inc.w r2			; go to the next character
	j draw_text_again

draw_text_end:
	pop r10
	pop r9
	pop r8
	pop r7
	pop r6
	pop r5
	pop r4
	pop r3
	pop r2
	pop r1
	pop r0
	ret

p0s:
	mov.w r9, r3
	shl.w r9, 4
	st.b [r0], r9
	ret
p1s:
	ld.b r9, [r0]
	or.w r9, r3
	st.b [r0], r9
	ret

dtp_odd:
	mov.w r6, 3
	mov.w r7, 128
dt_pagain_o:	
	mov.w r8, r5
	and.w r8, r7
	cmp.w r8, r7
	callz p0s_o
dtp1_o:
	inc.w r0
	shr.w r7, 1
	mov.w r8, r5
	and.w r8, r7
	cmp.w r8, r7
	callz p1s_o
dtp2_o:	
	shr.w r7, 1

	dec.w r6
	jp dt_pagain_o
	sub.w r0, 4
	
	j dtp_back

p0s_o:
	ld.b r9, [r0]
	or.w r9, r3
	st.b [r0], r9
	ret

p1s_o:
	mov.w r9, r3
	shl.w r9, 4
	st.b [r0], r9
	ret

my_text:
	#str "Hello World!\0"
	