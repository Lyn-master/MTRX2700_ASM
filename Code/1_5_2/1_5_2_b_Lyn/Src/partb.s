
.syntax unified
.thumb

.global main

#include "initialise.s"

.data
@ define variables


.align

incoming_buffer: .space 62

@ One strategy is to keep a variable that lets you know the size of the buffer.
incoming_counter: .byte 62



.text
@ define text


@ this is the entry function called from the c file
main:

	@ in class run through the functions to perform the config of the ports
	@ for more details on changing the UART, refer to the week 3 live lecture/tutorial session.

	BL initialise_power
	BL enable_peripheral_clocks
	BL enable_uart


	@ To read in data, we need to use a memory buffer to store the incoming bytes
	@ Get pointers to the buffer and counter memory areas
	LDR R1, =incoming_buffer
	LDR R7, =incoming_counter

	@ dereference the memory for the maximum buffer size, store it in R7
	LDRB R7, [R7]

	@ Keep a pointer that counts how many bytes have been received
	MOV R8, #0x00


@ continue reading forever (NOTE: eventually it will run out of memory as we don't have a big buffer)
loop_forever:

	LDR R0, =UART @ the base address for the register to set up UART
	LDR R6, [R0, USART_ISR] @ load the status of the UART

	TST R6, 1 << UART_ORE | 1 << UART_FE  	   @ 'AND' the current status with the bit mask that we are interested in
						   @ NOTE, the ANDS is used so that if the result is '0' the z register flag is set

	BNE clear_error

	TST R6, 1 << UART_RXNE @ 'AND' the current status with the bit mask that we are interested in
							  @ NOTE, the ANDS is used so that if the result is '0' the z register flag is set

	BEQ loop_forever @ loop back to check status again if the flag indicates there is no byte waiting

	LDRB R3, [R0, USART_RDR] @ Load the received character into register R3

	CMP R3, #35       @ If terminating character
	BEQ end_loop      @ Exit

	STRB R3, [R1, R8]  @ Store character into buffer space R1
	ADD R8, #1

	CMP R7, R8
	BGT no_reset
	MOV R8, #0  @Overwrite storage buffer



no_reset:

	@ load the status of the UART
	LDR R6, [R0, USART_RQR]  @ Move to request register
	ORR R6, 1 << UART_RXFRQ  @ Clear RXNE flag
	STR R6, [R0, USART_RQR]  @ Update value to request register

	BGT loop_forever


clear_error:

	LDR R6, [R0, USART_ICR]				     @ Activate interrupt flag clear register
	ORR R6, 1 << UART_ORECF | 1 << UART_FECF @ Clears overrun and framing error
	STR R6, [R0, USART_ICR]					 @ Update value in clear register
	B loop_forever

end_loop:
	b end_loop
