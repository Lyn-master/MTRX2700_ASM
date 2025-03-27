@Check if its a palindrome
@If it is, we caesar cipher it else we transmit as normal


.syntax unified
.thumb


.global main

#include "initialise.s"
#include "definitions.s"

.data

vowel_array: .asciz "aoeiu" @define vowel array

.align
incoming_buffer: .space 62

@ One strategy is to keep a variable that lets you know the size of the buffer.
incoming_counter: .byte 62

tx_terminating_char: .byte 35 @terminating character is #


.text
@ define text


@Loop through the characters inside R6 to check if its a palindrome and if it is we'll caesar cipher it
main:
	BL initialise_power
	BL enable_peripheral_clocks
	BL enable_uart

start:

	@ Get pointers to the buffer and counter memory areas
	LDR R6, =incoming_buffer
	LDR R7, =incoming_counter

	@ dereference the memory for the maximum buffer size, store it in R7
	LDRB R7, [R7]

	@ Keep a pointer that counts how many bytes have been received
	MOV R8, #0x00


@ continue reading forever (NOTE: eventually it will run out of memory as we don't have a big buffer)
loop_forever:

	LDR R0, =UART4 @ the base address for the register to set up UART
	LDR R1, [R0, USART_ISR] @ load the status of the UART

	TST R1, 1 << UART_ORE | 1 << UART_FE  @ 'TST' the current status with the bit mask that to check there is no frame error or overrun flag

	BNE clear_error

	TST R1, 1 << UART_RXNE @ 'TST' the current status with the bit mask to see if new byte ready to be read

	BEQ loop_forever @ loop back to check status again if the flag indicates there is no byte waiting

	LDRB R3, [R0, USART_RDR] @ load the lowest byte (RDR bits [0:7] for an 8 bit read)

	CMP R3, #35 @checking if last value read is temrinating character #
	BEQ Cal_middle @if it is loop to start of palindrome functions
	STRB R3, [R6, R8] @if not trasmite the byte
	ADD R8, #1 @increment place in string

	CMP R7, R8 @check if number of bytes transmitted is greater than buffer
	BGT no_reset @if not no reset
	MOV R8, #0 @if yes reset


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

Cal_middle:

	LSR R4,R8,#1    @ Calculates middle value e.g string of length 7, middle = 3.   --> 0 1 2 [3] 4 5 6. (Odd)
						    @ String of length 8, middle = 4. --> 0 1 2 3 [4] 5 6 7
	MOV R5, #0      @ Start counter


Check_palindrome:

	CMP R5, R4         @Check if incremented equals the middle value, if it does its a palindrome
	BGE is_palindrome

	SUB R1, R8, R5     @ R1 = R2 - R5    e.g. R2 = 8 - 0 = 8
	SUB R1, R1, #1     @ R1 = R2 -R5-1    e.g. R2 = 7 (As indexing starts at zero)

	LDRB R7,[R6,R5]    @ First character e.g. R6[7]
	LDRB R9,[R6,R1]    @ Last Character e.g. R6[0]


	ORR R7, #0x20       @ Convert foremost entry to lowercase   i.e. 0x20  = 32

	ORR R9, #0x20       @ Convert furthest entry to lowercase


	@Comparing character by character

	CMP R7,R9
	BNE vowel @since not palindrome branches to vowel loop

	ADD R5, #1

	B Check_palindrome


is_palindrome:

	@LDR R0, = palindrome_mess   @ For the sake of testing
	@BL printf 					@ For the sake of testing


	MOV R2, #3  @ Left shift value
	MOV R3, #0  @ Start counter

Decipher:
	@Decipher the caesar cipher


	LDRB R4, [R6, R3]          @ Load each character into R4
	CMP R4, #0                 @ Check end of string
	BEQ vowel               @ For the sake of testing  we'd have to branch to the vowel detector
	@ Enter transmission loop 'b tx_loop'

	@ Check if in alphabet range A = 65 Z = 90 a = 97 z = 122

	CMP R4, #65      @ Letter < A
	BLT next_letter

	CMP R4, #122     @ Letter > z
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


	@ Limits A = 65 Z = 90 a = 97 z = 122

upper_case:

	SUB R4, R2		@ De-step 3 characters back 
	CMP R4, #65   		@ Compare with lowest ascii A 
	BGE update_str
	ADD R4, R4, #26		@ Loop back from Z
	B update_str


lower_case:
	SUB R4, R2		@ De-step 3 characters back 
	CMP R4, #97		@ Compare with lowest ascii a
	BGE update_str
	ADD R4, R4, #26
	B update_str		@ Loop back from z

update_str:
	STRB R4, [R6,R3]  @store in current place of string

next_letter:

	@Increment and restart loop
	ADD R3, #1

	B Decipher


@ this is the entry function called from the startup file
vowel:

	LDR R2, =0x00 	@ counter to the current place in the string
	LDR R7, =0 @counter to vowels detected
	LDR R9, =0 @counter for letters (e.g. doesnt count punctuation characters)


string_loop:

	LDRB R3, [R6, R2]	@ load the byte from the ascii_string (byte number R2)
	CMP R3, #0	@ Test to see whether this byte is zero (for null terminated)
	BEQ finished_string  @ if it was null (0) then jump out of the loop
	ORR R3, R3, #32	@convert letter to lowercase
	LDR R5, =vowel_array
	BL letter_detecting @check if a letter
	ADD R2, #1  @ increment the offset R2

	B string_loop  @ loop to the next byte

@if letter is between a-z check if vowel otherwise return
letter_detecting:
	CMP R3, #97
	BHS lower_z
	BX LR

lower_z:
	CMP R3, #122
	BLS vowel_detecting
	BX LR

vowel_detecting:

	LDRB R8, [R5], #1 @load vowel from array and move to next
	CMP R8, #0 @check not end of vowel array
	BEQ no_vowel
	CMP R3, R8 @check if vowel
	BEQ found_vowel
	B vowel_detecting @run loop again


found_vowel:
	ADD R7, #1

no_vowel:
	MOV R8, #0  @ Clear R8
	ADD R9, #1 @if between a-z increase R9 - increasing letter count
	BX LR

finished_string:

	@ Branch with link to set the clocks for the I/O and UART
	BL enable_peripheral_clocks

	@ Once the clocks are started, need to initialise the discovery board I/O
	BL initialise_discovery_board

	MOV R2, R7 @value of vowels is now in R2

	B start_timer



light_up_leds:
	LDR R0, =GPIOE  @ load the address of the GPIOE register into R0
	STRB R7, [R0, #ODR + 1]   @ store this to the second byte of the ODR (bits 8-15)

delay_function:

	LDR R3, [R1, TIM_SR]
	CMP R3, #0x1f
	BEQ switch
	B delay_function

change_consonants:
	SUB R7, R9, R7
	B light_up_leds

change_vowels:
	MOV R7, R2
	B light_up_leds

start_timer:
	@ Branch with link to enable timer 2 clock
	BL enable_timer2_clock

	@ Branch with link to set ARPE=1
	BL enable_arpe

	BL initialise_timer

	BL trigger_prescaler

	LDR R8, =#0 @ flag for switching between consonants and vowels

	LDR R1, =TIM2
	LDR R3, =500
	STR R3, [R1, TIM_ARR]
	LDR R3, =1
	STR R3, [R1, TIM_CR1]
	LDR R3, =0
	STR R3, [R1, TIM_SR]

	B delay_function

switch:

	LDR R1, =TIM2
	LDR R3, =0
	STR R3, [R1, TIM_SR]
	EOR R8, R8, #1
	CMP R8, #0
	BEQ change_consonants
	B change_vowels

