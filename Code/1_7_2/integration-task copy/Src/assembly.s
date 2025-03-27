.syntax unified
.thumb

.global main

#include "initialise.s"
#include "definitions.s"

.data
@ define variables


.align
@ can allocate as an array
@incoming_buffer: .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
@ or allocate just as a block of space with this number of bytes
incoming_buffer: .space 62

@ One strategy is to keep a variable that lets you know the size of the buffer.
incoming_counter: .byte 62

tx_terminating_char: .byte 35 @terminating character is #



.text
@ define text


@ this is the entry function called from the c file
main:

	BL initialise_power
	BL enable_peripheral_clocks
	BL enable_uart

		@ To read in data, we need to use a memory buffer to store the incoming bytes
	@ Get pointers to the buffer and counter memory areas
	LDR R6, =incoming_buffer
	LDR R7, =incoming_counter

	@ dereference the memory for the maximum buffer size, store it in R7
	LDRB R7, [R7]

	@ Keep a pointer that counts how many bytes have been received
	MOV R8, #0x00


@ continue reading forever (NOTE: eventually it will run out of memory as we don't have a big buffer)
loop_forever:

	LDR R0, =UART @ the base address for the register to set up UART
	LDR R1, [R0, USART_ISR] @ load the status of the UART

	TST R1, 1 << UART_ORE | 1 << UART_FE  @ 'AND' the current status with the bit mask that we are interested in
				 		   @ NOTE, the ANDS is used so that if the result is '0' the z register flag is set

	BNE clear_error

	TST R1, 1 << UART_RXNE @ 'AND' the current status with the bit mask that we are interested in
							  @ NOTE, the ANDS is used so that if the result is '0' the z register flag is set

	BEQ loop_forever @ loop back to check status again if the flag indicates there is no byte waiting

	LDRB R3, [R0, USART_RDR] @ load the lowest byte (RDR bits [0:7] for an 8 bit read)
	STRB R3, [R6, R8]
	ADD R8, #1
	CMP R3, #35 @checking if last value read is temrinating character #
	BEQ palindrome @if it is check if it's a palindrome

	CMP R7, R8
	BGT no_reset
	MOV R8, #0


no_reset:

	@ load the status of the UART
	LDR R1, [R0, USART_RQR]
	ORR R1, 1 << UART_RXFRQ
	STR R1, [R0, USART_RQR]

	BGT loop_forever


clear_error:

	@ Clear the overrun/frame error flag in the register USART_ICR (see page 897)
	LDR R1, [R0, USART_ICR]
	ORR R1, 1 << UART_ORECF | 1 << UART_FECF @ clear the flags (by setting flags to 1)
	STR R1, [R0, USART_ICR]
	B loop_forever

palindrome:

SUB R8, R8, #1
LSR R4,R8,#1    @ Calculates middle value
MOV R5, #0      @ Start counter

check_palindrome_loop:
CMP R5, R4
BGE caesar_cipher @is a palindrome and therefore must be encoded

@During iteration


SUB R2, R8, R5    @ R2 = R8 -R5 (length of string minus current character count)
SUB R2, R2, #1    @ R6 = R2 -R5-1

LDRB R7,[R6,R5]    @Beginning of string
LDRB R3,[R6,R2]    @End of string

@Comparing character by character

ORR R7, #0x20       @ Convert foremost entry to lowercase

ORR R3, #0x20       @ Convert furthest entry to lowercase

CMP R7,R3
BNE finished

ADD R5, #1

b check_palindrome_loop

caesar_cipher:
MOV R2, #3 @ Value for right shift

Mov R3, #0 @ Offset for incrementation

cipher_loop:
LDRB R4, [R6, R3]
CMP R3, R8                 @ Check end of string by checking increment (R3) with length of string (R8)
BEQ tx_loop

@ Check if in alphabet range A = 65 Z = 90 a = 97 z = 122
CMP R4, #65
BLT next_letter

CMP R4, #122
BGT next_letter

@ Upper case range 65<= # < 91
CMP R4, #91
BLT upper_case

@ Invalid case range 91 <= # <= 96

CMP R4, #96
BLE next_letter

@ Lower case range 97 <= # <= 122
CMP R4, #97
BGE lower_case


upper_case:

ADD R4, R2
CMP R4, #90
BLE update_str
SUB R4, R4, #26
B update_str

lower_case:
ADD R4, R2
CMP R4, #122
BLE update_str
SUB R4, R4, #26
B update_str

update_str:
STRB R4, [R6,R3]  @store in current place of string

next_letter:
@Increment and restart loop
ADD R3, #1
b cipher_loop

tx_loop:

	@ the base address for the register to set up UART
	LDR R0, =UART4

	@ load the memory addresses of the buffer and length information

	LDR R4, =tx_terminating_char

	@ dereference the term char

	LDR R4, [R4]


tx_uart:

	LDR R3, [R0, USART_ISR] @ load the status of the UART
	ANDS R3, 1 << UART_TXE  @ 'AND' the current status with the bit mask that we are interested in
						    @ NOTE, the ANDS is used so that if the result is '0' the z register flag is set

	@ loop back to check status again if the flag indicates there is no byte waiting
	BEQ tx_uart

	@ load the next value in the string into the transmit buffer for the specified UART
	LDRB R5, [R6], #1
	CMP R5, R4 @check if next character to be transmitted is terminating one
	BEQ finished
	STRB R5, [R0, USART_TDR]

	@ make a delay before sending again
	BL delay_loop

	@ loop back to the start
	B tx_loop


delay_function:
	MOV R7, #0x03
	BX LR

@ a very simple delay
@ you will need to find better ways of doing this
delay_loop:
	LDR R9, =0xfffff

delay_inner:
	@ notice the SUB has an S on the end, this means it alters the condition register
	@ and can be used to make a branching decision.
	SUBS R9, #1
	BGT delay_inner
	BX LR @ return from function call

finished:
	B finished


