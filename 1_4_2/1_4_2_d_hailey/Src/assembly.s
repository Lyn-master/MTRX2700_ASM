.syntax unified
.thumb

.global main

#include "definitions.s"
#include "initialise.s"
#include "button_function.s"


.data
@ define variables
ascii_string: .asciz "hello!\0" @ Define a null-terminated string
vowel_array: .asciz "aoeiu" @define vowels

.text

@ this is the entry function called from the startup file
main:

	LDR R0, =ascii_string  @ the address of the string
	LDR R2, =0x00 	@ counter to the current place in the string
	LDR R6, =0 @counter to vowels detected
	LDR R9, =0 @counter for letters (e.g. doesnt count punctuation characters)

string_loop:

	LDRB R3, [R0, R2]	@ load the byte from the ascii_string (byte number R2)
	STRB R3, [R1, R2]	@ store the byte in the string_buffer (byte number R2)
	CMP R3, #0	@ Test to see whether this byte is zero (for null terminated)
	BEQ finished_string  @ if it was null (0) then jump out of the loop
	ORR R3, R3, #32	@convert letter to lowercase
	LDR R5, =vowel_array
	BL letter_detecting @check if a letter
	ADD R2, #1  @ increment the offset R2

	B string_loop  @ loop to the next byte

@check if letter above or equal to ascii value for a
letter_detecting:
	CMP R3, ASCII_a
	BHS lower_z @if it is check it is below or equal to ascii value for z
	BX LR @if not back to main loop and moves onto next character

lower_z:
	CMP R3, ASCII_z
	BLS vowel_detecting @if it is a letter bracnhes to vowel_detecting
	BX LR @if not back to main loop and moves onto next character

vowel_detecting:

	LDRB R8, [R5], #1 @load vowel from array and move to next
	CMP R8, #0 @check not end of vowel array
	BEQ no_vowel
	CMP R3, R8 @check if vowel
	BEQ found_vowel
	B vowel_detecting @run loop again

found_vowel:
	ADD R6, #1

no_vowel:
	MOV R8, #0  @ Clear R8
	ADD R9, #1 @if between a-z increase R9 - increasing letter count
	BX LR

finished_string:

	@ Branch with link to set the clocks for the I/O and UART
	BL enable_peripheral_clocks

	@ Once the clocks are started, need to initialise the discovery board I/O
	BL initialise_discovery_board

	LDR R0, =GPIOE  @ load the address of the GPIOE register into R0
	STRB R6, [R0, #ODR + 1]   @ store this to the second byte of the ODR (bits 8-15)
	B finished_everything


finished_everything:
	BL button_loop @loops waiting for button press

	B finished_everything 	@ infinite loop here

switch_vowels_consonants:
	SUB R6, R9, R6 @subtracting the number of vowels/consonants from number of letters
	B finished_string
