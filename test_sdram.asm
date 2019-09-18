	#addr 0
	VIDEO_0 = 1024
	ADDR2 = 51000

	mov.s r0, 65								; 'A' character
	mov.s r1, 50000
	st.s [r1], r0
	
	ld.s r2, [r1]
	mov.s r1, VIDEO_0 + 5*160		; 0000: 0120 0720 
	st.s [r1], r2								; 0008: 2183
	
	mov.s r2, 66								; 'B' character
	mov.s r0, 0x0320						
	st.s [ADDR2], r0						; c378 (51000): mov.s r3, xx
	mov.s r0, 0x0722						
	st.s [ADDR2 + 2], r0				; c37a (51002): mov.s r3, VIDEO_0 + 5*160 + 2
	mov.s r0, 0x2383						
	st.s [ADDR2 + 4], r0				; c37c (51004): st.s [r3], r2
	mov.s r0, 0xFFF0
	st.s [ADDR2 + 6], r0				; c37e (51006): halt
	j ADDR2
	
	halt											; 000A: FFF0
	
tekst:
	#str16 "TEKST\0"
	