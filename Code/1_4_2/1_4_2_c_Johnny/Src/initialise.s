.syntax unified
.thumb

#include "definitions.s"

@ enable the clocks for peripherals (GPIOA, C and E)
enable_peripheral_clocks:
	LDR R0, =RCC  @ load the address of the RCC address boundary (for enabling the IO clock)
	LDR R1, [R0, #AHBENR]  @ load the current value of the peripheral clock registers
	ORR R1, 1 << GPIOA_ENABLE | 1 << GPIOC_ENABLE | 1 << GPIOE_ENABLE  @ 21st bit is enable GPIOE clock, 17 is GPIOA clock
	STR R1, [R0, #AHBENR]  @ store the modified register back to the submodule
	BX LR @ return from function call



@ initialise the discovery board I/O (just outputs: inputs are selected by default)
initialise_discovery_board:
	LDR R0, =GPIOE 	@ load the address of the GPIOE register into R0
	LDR R1, =0x5555  @ load the binary value of 01 (OUTPUT) for each port in the upper two bytes
					 @ as 0x5555 = 01010101 01010101
	STRH R1, [R0, #MODER + 2]   @ store the new register values in the top half word representing
								@ the MODER settings for pe8-15
	BX LR @ return from function call

enable_timer2_clock:

	LDR R0, =RCC	@ load the base address for the timer
	LDR R1, [R0, APB1ENR] 	@ load the peripheral clock control register
	ORR R1, 1 << TIM2EN @ store a 1 in bit for the TIM2 enable flag
	STR R1, [R0, APB1ENR] @ enable the timer
	BX LR @ return

initialise_timer:
	LDR R0, =TIM2

	LDR R1, =7999
	STR R1, [R0, #TIM_PSC]

	@ store a value for the prescaler
	LDR R1, =0x1 @ make the timer overflow after counting to only 1
	STR R1, [R0, TIM_ARR] @ set the ARR register
	STR R1, [R0, TIM_CR1]

	LDR R8, =0x00
	STR R8, [R0, TIM_CNT] @ reset the clock
	NOP
	NOP

	@ Reset the counter and stop the timer
	LDR R5, =0
	STR R5, [R0, #TIM_CR1]  @ stop the timer (TIM2)
    STR R5, [R0, #TIM_CNT]  @ Reset the timer counter to 0
    STR R5, [R0, #TIM_SR]	@ clear the timer Status Register

	BX LR
