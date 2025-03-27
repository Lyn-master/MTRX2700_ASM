.syntax unified
.thumb

#include "definitions.s"

@ function to enable the clock for Timer 2
enable_timer2_clock:

	LDR R3, =RCC
	LDR R1, [R3, APB1ENR]
	ORR R1, 1 << TIM2EN
	STR R1, [R3, APB1ENR]
	BX LR

initialise_timer:

	LDR R1, =TIM2

	LDR R3, =7999
	STR R3, [R1, TIM_PSC]

	LDR R3, =500
	STR R3, [R1, TIM_ARR]

	LDR R3, =0
	STR R3, [R1, TIM_CNT]
	STR R3, [R1, TIM_SR]

	BX LR

trigger_prescaler:

	LDR R1, =TIM2

	@ start timer
	LDR R3, =0x1
	STR R3, [R1, TIM_CR1]
	STR R3, [R1, TIM_ARR]

	LDR R8, =0x00
	STR R8, [R1, TIM_CNT]
	NOP
	NOP

	@ stop timer
	STR R8, [R1, TIM_CR1]

	@ reset Auto-Reload Register
	LDR R3, =0xffffffff
	STR R3, [R1, TIM_ARR]

	BX LR

enable_arpe:

	LDR R1, =TIM2

	LDR R3, [R1]
	ORR R3, R3, #0b10000000
	STR R3, [R1]

	BX LR

@ function to enable the clocks for the peripherals we could be using (A, B, C, D and E)
enable_peripheral_clocks:

	@ load the address of the RCC address boundary (for enabling the IO clock)
	LDR R0, =RCC

	@ enable all of the GPIO peripherals in AHBENR
	LDR R1, [R0, #AHBENR]
	ORR R1, 1 << GPIOE_ENABLE | 1 << GPIOD_ENABLE | 1 << GPIOC_ENABLE | 1 << GPIOB_ENABLE | 1 << GPIOA_ENABLE  @ enable GPIO
	STR R1, [R0, #AHBENR]

	BX LR @ return



@ function to enable a UART device - this requires:
@  setting the alternate pin functions for the UART (select the pins you want to use)
@
@ BAUD rate needs to change depending on whether it is 8MHz (external clock) or 24MHz (our PLL setting)
enable_uart:

	@make a note about the different ways that we set specific bits in this configuration section

	@ select which UART you want to enable
	LDR R0, =GPIOC

	@ set the alternate function for the UART pins (what ever you have selected)
	LDR R1, =0x77
	STRB R1, [R0, AFRL + 2]

	@for uart 4
	LDR R1, =0x55 @set for alternate function 5
	STRB R1, [R0, AFRH + 1] @set bits 8-15 to enable alternate function for pins


	@ modify the mode of the GPIO pins you want to use to enable 'alternate function mode'
	LDR R1, [R0, GPIO_MODER]
	ORR R1, 0x0A00000 @ Mask for pins to change to 'alternate function mode' for uart 1 and 4
	ORR R1, 0xA00
	STR R1, [R0, GPIO_MODER]



	@ modify the speed of the GPIO pins you want to use to enable 'high speed'
	LDR R1, [R0, GPIO_OSPEEDR]
	ORR R1, 0x0F00000 @ Mask for pins to change to 'alternate function mode' for uart 1 and 4
	ORR R1, 0xF00
	STR R1, [R0, GPIO_OSPEEDR]

	@ Set the enable bit for the specific UART you want to use
	@ Note: this might be in APB1ENR or APB2ENR
	@ you can find this out by looking in the datasheet
	LDR R0, =RCC @ the base address for the register to turn clocks on/off
	LDR R1, [R0, #APB2ENR] @ load the original value from the enable register
	ORR R1, 1 << UART_EN  @ apply the bit mask to the previous values of the enable the UART
	STR R1, [R0, #APB2ENR] @ store the modified enable register values back to RCC

	@same as above but for uart 4
	LDR R0, =RCC @ the base address for the register to turn clocks on/off
	LDR R1, [R0, #APB1ENR] @ load the original value from the enable register
	ORR R1, 1 << UART_EN4  @ turning on 19th bit to en uart 4
	STR R1, [R0, #APB1ENR] @ store the modified enable register values back to RCC

	@ this is the baud rate
	MOV R1, #0x46 @ hailey changed this line, for new calculation to get different baud rate when clock is 6x faster
	LDR R0, =UART @ the base address for the register to turn clocks on/off
	STRH R1, [R0, #USART_BRR] @ store this value directly in the first half word (16 bits) of
							  	 @ the baud rate register

	@for uart4
	MOV R1, #0x1A1 @ hailey changed this line, for new calculation to get different baud rate when clock is 6x faster
	LDR R0, =UART4 @ the base address for the register to turn clocks on/off
	STRH R1, [R0, #USART_BRR] @ store this value directly in the first half word (16 bits) of
							  	 @ the baud rate register

	@ we want to set a few things here, lets define their bit positions to make it more readable
	LDR R0, =UART @ the base address for the register to set up the specified UART
	LDR R1, [R0, #USART_CR1] @ load the original value from the enable register
	ORR R1, 1 << UART_TE | 1 << UART_RE | 1 << UART_UE @ make a bit mask with a '1' for the bits to enable,
													   @ apply the bit mask to the previous values of the enable register

	STR R1, [R0, #USART_CR1] @ store the modified enable register values back to RCC

	@uart 4
	LDR R0, =UART4 @ the base address for the register to set up the specified UART
	LDR R1, [R0, #USART_CR1] @ load the original value from the enable register
	ORR R1, 1 << UART_TE | 1 << UART_RE | 1 << UART_UE @ make a bit mask with a '1' for the bits to enable,
													   @ apply the bit mask to the previous values of the enable register

	STR R1, [R0, #USART_CR1] @ store the modified enable register values back to RCC

	BX LR @ return



@ set the PLL (clocks are described in page 125 of the large manual)
change_clock_speed:
@ step 1, set clock to HSE (the external clock)
	@ enable HSE (and wait for complete)
	LDR R0, =RCC @ the base address for the register to turn clocks on/off
	LDR R1, [R0, #RCC_CR] @ load the original value from the enable register
	LDR R2, =1 << HSEBYP | 1 << HSEON @ make a bit mask with a '1' in the 0th bit position
	ORR R1, R2 @ apply the bit mask to the previous values of the enable register
	STR R1, [R0, #RCC_CR] @ store the modified enable register values back to RCC

	@ wait for the changes to be completed
wait_for_HSERDY:
	LDR R1, [R0, #RCC_CR] @ load the original value from the enable register
	TST R1, 1 << HSERDY @ Test the HSERDY bit (check if it is 1)
	BEQ wait_for_HSERDY

@ step 2, now the clock is HSE, we are allowed to switch to PLL
	@ clock is set to External clock (external crystal) - 8MHz, can enable the PLL now
	LDR R1, [R0, #RCC_CFGR] @ load the original value from the enable register
	LDR R2, =1 << 18 | 1 << PLLSRC | 1 << 22 @ the last term is for the USB prescaler to be 1
	ORR R1, R2  @ set PLLSRC (use PLL) and PLLMUL to 0100 - bit 20 is 1 (set speed as 6x faster)
				@ see page 140 of the large manual for options
				@ NOTE: cannot go faster than 72MHz)
	STR R1, [R0, #RCC_CFGR] @ store the modified enable register values back to RCC

	@ enable PLL (and wait for complete)
	LDR R0, =RCC @ the base address for the register to turn clocks on/off
	LDR R1, [R0, #RCC_CR] @ load the original value from the enable register
	ORR R1, 1 << PLLON @ apply the bit mask to turn on the PLL
	STR R1, [R0, #RCC_CR] @ store the modified enable register values back to RCC

wait_for_PLLRDY:
	LDR R1, [R0, #RCC_CR] @ load the original value from the enable register
	TST R1, 1 << PLLRDY @ Test the HSERDY bit (check if it is 1)
	BEQ wait_for_PLLRDY

@ step 3, PLL is ready, switch over the system clock to PLL
	LDR R0, =RCC  @ load the address of the RCC address boundary (for enabling the IO clock)
	LDR R1, [R0, #RCC_CFGR]  @ load the current value of the peripheral clock registers
	MOV R2, 1 << 10 | 1 << 1  @ some more settings - bit 1 (SW = 10)  - PLL set as system clock
									   @ bit 10 (HCLK=100) divided by 2 (clock is faster, need to prescale for peripherals)
	ORR R1, R2	@ Set the values of these two clocks (turn them on)
	STR R1, [R0, #RCC_CFGR]  @ store the modified register back to the submodule

	LDR R1, [R0, #RCC_CFGR]  @ load the current value of the peripheral clock registers
	ORR R1, 1 << USBPRE	@ Set the USB prescaler (when PLL is on for the USB)
	STR R1, [R0, #RCC_CFGR]  @ store the modified register back to the submodule

	BX LR @ return



@ initialise the power systems on the microcontroller
@ PWREN (enable power to the clock), SYSCFGEN system clock enable
initialise_power:

	LDR R0, =RCC @ the base address for the register to turn clocks on/off

	@ enable clock power in APB1ENR
	LDR R1, [R0, #APB1ENR]
	ORR R1, 1 << PWREN @ apply the bit mask for power enable
	STR R1, [R0, #APB1ENR]

	@ enable clock config in APB2ENR
	LDR R1, [R0, #APB2ENR]
	ORR R1, 1 << SYSCFGEN @ apply the bit mask to allow clock configuration
	STR R1, [R0, #APB2ENR]

	BX LR @ return

@ initialise the discovery board I/O (just outputs: inputs are selected by default)
initialise_discovery_board:
	LDR R0, =GPIOE 	@ load the address of the GPIOE register into R0
	LDR R1, =0x5555  @ load the binary value of 01 (OUTPUT) for each port in the upper two bytes
					 @ as 0x5555 = 01010101 01010101
	STRH R1, [R0, #MODER + 2]   @ store the new register values in the top half word representing
								@ the MODER settings for pe8-15
	BX LR @ return from function call

