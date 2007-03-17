#include <avr/io.h>

.text
.global n64_sendData


#define GC_DATA_BIT		0x02	/* in PORTD */
#define IO_DDRD _SFR_IO_ADDR(DDRD)

#define SAVEREGS

	/************************************************
	* Send data using the N64/GC serial protocol which
	* is as follows:
	*   0          1
	*     __        _____
	* ____|       __|
	* ^   ^ ^     ^ ^   ^
	*  3us 1us    1us 3us
	*
	* To send a 1, the pin direction is set to input.
	* To send a 0, the pin direction is set to output. 
	*	(of course, it's value is preset to zero)
	* 
	* At 16 mhz, a 1us period is 16 cycles. Thus a 3us period
	* is 48 cycles.
	*
	* Number of bits to send is passed in r6
	* Z must point to first byte of data. Every byte
	* represents one bit (programming laziness..). A logic
	* 1 is sent when a byte is non-zero.
	* Used registers: r16, r17
	************************************************/
n64_sendData:
#ifdef SAVEREGS
	push r16
	push r17
#endif

lp_sendGCData_bits:
	ld r16, z+
	tst r16
	brne send1
	nop
send0:
	sbi IO_DDRD, GC_DATA_BIT	; Pull bus to 0 
	
	ldi r17, 15
lp_send0_3us:
	dec r17
	brne lp_send0_3us
	nop

	cbi IO_DDRD, GC_DATA_BIT	; Release bus to 1

	ldi r17, 2
lp_send0_1us:
	dec r17
	brne lp_send0_1us

	dec r6
	brne lp_sendGCData_bits
#ifdef SAVEREGS
	pop r17
	pop r16
#endif
	ret

send1:
	sbi IO_DDRD, GC_DATA_BIT	; Pull bus to 0

	ldi r17, 4
lp_send1_1us:
	dec r17
	brne lp_send1_1us
	nop
	nop
	
	cbi IO_DDRD, GC_DATA_BIT	; Release bus to 1

	ldi r17, 12
lp_send1_3us:
	dec r17
	brne lp_send1_3us
	nop
	nop

	dec r6
	brne lp_sendGCData_bits
#ifdef SAVEREGS
	pop r17
	pop r16
#endif
	ret

