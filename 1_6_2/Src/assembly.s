.syntax unified
.thumb

@#include "initialise.s"
@#include "part_a.s"
#include "part_c.s"

.global main


.data
@ define variables
delay_time: .word 1000000 @ desired delay time in microseconds


.text
@ define code


@ this is the entry function called from the startup file
main:

	# initialisation
	BL enable_timer2_clock
	BL enable_peripheral_clocks
	BL initialise_discovery_board

	@ un comment these two lines for part a to store desired delay time in R1
	@LDR R1, =delay_time
	@LDR R1, [R1]

	BL delay
