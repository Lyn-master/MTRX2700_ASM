@ -1,27 +0,0 @@
.syntax unified
.thumb

.global main

#include "definitions.s"
#include "initialise.s"

.data
@ Define variables

.text

@ this is the entry function called from the startup file
main:

	@ Branch with link to set the clocks for the I/O and UART
	BL enable_peripheral_clocks

	@ Once the clocks are started, need to initialise the discovery board I/O
	BL initialise_discovery_board

	LDR R0, =GPIOE @ Load the address of GPIOE into register R0

	LDRB R4, =0b10101010 @ Load the bitmask for the LED pattern (every second one is lit) into register R4

	STRB R4, [R0, #ODR + 1] @ Store the pattern into the second byte of the ODR to display
