
# Integration Task for STM32 using Assembly Language

This project exhibits serial communication between two STM32 boards using distinct UART interfaces (UART1 and UART4). Data is assessed for palindromic qualities before being conditionally encrypted or decrypted using the Caesar cypher.
Timers are integrated to switch between modes.

![Image](https://github.com/user-attachments/assets/3b6fc4a3-fdd8-4821-9cd1-20658e4070c9)

### Team Members

- <H4>Hailey Thill-Turke</H4>

  - Coding/Implementation 
  - Quality Assurance  
  - Meeting minutes  
  
- <H4>Johnny Wang</H4>

  - Coding/Implementation
  - Quality Assurance
  - Documentation

- <H4>Marilyn Tek</H4>

  - Coding/Implementation
  - Quality Assurance
  - README file

### Implementation
<H3>[1.3.2 Tasks]</H3>
<H4>Part a:</H4>This program facilitates the conversion of a string byte by byte into either upper_case or lower_case depending on a designated
flag(R2 = 0 or 1) without altering non-alphabetical characters.
<br> </br>
<pre> 
  
	Main:
		Define Memory Buffer 
		Define Counter 
		Initialise Flag 

	String_Loop:
		Load character byte 
		Check if alphabetical character 
		Check end of string 

	Next_letter
		Non-alphabetical characters are left untouched

	End loop:
		Finish iteration
  
	Testing
		Input: ":)Hi[}"
		Output: ":)HI{}" --> R2 = 1 convert all to uppercase
</pre>


<H4>Part b:</H4> The furthermost and foremost entry of a traversed string centered around the middle index are checked whether it exhbits palindromic 
properties. All characters are initialised to lowercase to prevent case sensitivity.
<br> </br>
<pre> 

	Main:
		Determine Memory Buffer 
		Define Counter 

	String_length:
		Load Character byte
		Calculate string length
		End if null_teminating character reached
  
	Palindrome:
		Calculate middle index
		Convert entry to lower_case
		Compare first and last byte
  
	is_palindrome:
		Prints message 
  
	not_palindrome:
		Prints message
  
	end_loop:
		Finish iteration
  
	Testing
		Input: "@!Racecar!@"
		Output: "Is a palindrome\n"
</pre>

<H4>Part c:</H4> A string is traversed and checked whether it's alphabetical. If it is alphabetical, we’d check whether it's upper_case or lower_case. Based on this characteristic, each letter is right shifted with a fixed value of 3. 
<br> </br>
<pre> 
  
	Main: 
		Define memory buffer 
		Define right shift value and counter
	
	String_loop: 
		Checks if string alphabetical if not skip iteration
  
	upper_case:
		Convert each character right shifted by 3 spaces 
		Check boundary condition to loop back within upper_case range 
  
	lower_case: 
		Convert each character right shifted by 3 spaces 
		Check boundary condition to loop back within lower_case  range 
  
	update_str:
		Update memory buffer with modified byte
  
	end_loop:
		Finish iteration 
  
	Testing
		Input: "@ab!xZ" 
		Output:"@de!aC" 
</pre>

<H3>[1.4.2 Tasks]</H3>
<H4>Part a:</H4>The microcontroller’s LEDs are lit up according to a predefined bit mask.
<br> </br>
<pre> 
  
	Main:
		Enable board’s clocks
		Initialise board
		Load bit mask

	LED Function:
		Load GPIOE address
		Store bitmask to LED address in GPIOE

	Testing
		Input: 0b00000111
		Output: first 3 LEDs should light up

</pre>

<H4>Part b:</H4>
<br> </br>
<pre> 

	Button_press:
		Checks if board receives input from user through button press
		Updates flag to indicate button state

	Button_press_action:
		Branch to actions to be executed if button was pressed
		Branch back to program loop after

	Led_check:
		Checks if all LEDs are full through flag
		If flag is raised, branch to reset LED state
		Else would continue to function to light up one more LED

	Reset:
		Reset LED pattern to all off
		Branch to update LED state

	Increment_leds:
		Increase LEDs lit by one through bit masking and checks if all LEDs are lit
		Branch to update LED state

	Light_up_leds:
		Get current LED state and update board output

	Button_release:
		Use delay in between checks for button state
		Loop until button is unpressed and branch to program loop

	Delay_function:
		Use hardware timer to implement a 100ms 

	Testing
		One more LED would light up with each button press
		When all LEDs are lit, all LEDs would turn off with next button press

</pre>

<H4>Part c:</H4>
<br> </br>
<pre> 
</pre>

<H4>Part d:</H4>The number of vowels in a string is counted and displayed in binary on the LEDs. The system then waits for the button to be pressed and switches to displaying the number of consonants of the string in binary. Each time the button is pressed the LEDs will switch between displaying the number of consonants and vowels. 
<br> </br>
<pre> 
  
	Main:
		Enable board’s clocks
		Initialise board
		Initialise registers 
	Character_loop:
		Cycle through every character of the string
		If not end of string → letter_detecting
		Character_loop

	Letter_detecting:
		Check if character is a letter
		If character is a letter → vowel_detecting

	Vowel_detecting:
		Check if letter is a vowel
	Initialise_LEDs:
		Set up clock, board and address of LEDs

	light_up_LEDs:
		LED Function from 1-4-2 (a)
		Button Function from 1-4-2 (c)

	Button_pressed:
		Subtract number of vowels from number of letters
		→ light_up_LEDs

	Testing
		Input: “yoohoo!!!”
		Output: LEDs switch between 2nd and 3rd being lit up and only 2nd being lit up
</pre>

<H3>[1.5.2 Tasks]</H3>
<H4>Part a:</H4>Once a button is pressed a predefined string of characters is transmitted until it reaches the terminating character. 
<br> </br>
<pre> 
	
	Main:
		initialise_power
		enable_peripheral_clocks
		enable_uart
	
	Button Function from 1-4-2 (c)
	
	Button_pressed:
		→ tx_loop
	
	Tx_loop:
	Check if ready to receive next character 
	If not → tx_loop
		If character to be transmitted is terminating one → finished
		Transmit character
	
	Finished:
		finished
  
	Testing
		Input: “Go Team!# (this part won’t print)”
		Output: “Go Team#”

</pre>

<H4>Part b:</H4>Receiving a string and storing it in a register until a terminating character is reached. 
<br> </br>
<pre> 
	
	main: 
		BL initialise_power
		BL enable_peripheral_clocks
		BL enable_uart
		Define buffer space
		Define start counter
	
	loop_forever:
		Load UART
		Load status register to check errors
		Check if there's avaliable space in receiver (RXNE)
		Load character to receiver register
	no_reset:
		Clear RXNE flag
		Update flag to request register
		Re-loop to forever
	clear_error:
		Clear overrun and frame error 
	end_loop:
		terminate execution
	Testing
		Input: "He#llo"
		Output: "He"
</pre>

<H4>Part c:</H4>
<br> </br>
<pre> 
	
	Change_clock_speed - scaffold provided in unit repository
	 	Choose PLLMUL as 0001 which set clock to x3 frequency
	
	Enable UART - scaffold provided in unit repository
		Store 0x1A1 to baud rate register (USART_BRR)
	
	Calculations
		New clock speed = 8MHz x 3 = 24MHz
		0x1A1 = 0b417
		Baud rate = 24MHz/417 ≈ 57600
	
	Testing
		To test the new baud rate, 1-5-2 (a) was tested except using the cutecom at baud rate 57600 instead of 115200.
</pre>

<H4>Part d:</H4>A string is received by the microcontroller until the terminating character is detected. The string is then transmitted back on the same UART.
<br> </br>
<pre> 
	
	Main:
		Same initialisation as 1-5-2- (a)

	Receive_function from 1-5-2- (b)
		If terminating character → transmit_function

	Transmit_function from 1-5-2- (a)

	Testing

		Receive and transmit functions have already been tested in previous parts so just need to test integration.

	Integration test:
		Input [cutecom text bar]: “hello#”
		Output [cutecom display]: “hello”
</pre>

<H4>Part e:</H4>On one microcontroller USART 1 receives a string of characters and then retransmits it using UART 4 to a second microcontroller. This microcontroller receives the data through UART 4 and retransmits it through USART1.
<br> </br>
<pre> 
	
	Definition File additions

		UART4 peripheral boundary address - 0x40004C00 
		APB1 Peripheral clock enable register UART4 bit - 19

	Initialise file additions

		Set pins PC10 and PC11 to alternate function mode 5 [0101].
		Set pins PC10 and PC11 to enable high speed [1111]. 
		Set baud rate for UART 4
		Enable UART 4’s transmit, receive and whole bits

	In the Tx board transmit function, load the UART4 address at the beginning instead of the USART 1 address. Do this again for the Rx board receive function.
	Testing
		Input [cutecom text bar for tx board]]: “sending#”
		Output [cutecom display screen]: “sending”

</pre>

### Usage

[1]Instructions to import Projects
<br> </br>

1. Ensure the latest STM32CubeIDE software is downloaded on the chosen device.
   
2. Connect the STM32 board to the computer.
   
3. Open the application and select “Import Project”.
 ![Image](https://github.com/user-attachments/assets/75b6f0c1-c893-4c91-bc02-a9e28a2d47f0)
4. Select the desired project folder from your directory.
 ![Image](https://github.com/user-attachments/assets/07443769-289d-417c-8020-bdd395f53d06)
5. Select finish.
   
 ![Image](https://github.com/user-attachments/assets/1ca9df2c-acb4-4ba8-b99b-07bdb248d538) 
 
6. Within the project in the source folder select assembly.s file and click the debug button.

 ![Image](https://github.com/user-attachments/assets/8d616329-7b3a-4cbd-9536-0d6b6b57365e)

7. Select either the play button to run through the entire code or step through it line by line with the arrow.

 ![Image](https://github.com/user-attachments/assets/63089134-5046-4434-84d8-1fa757924fa1)

[2]Instructions to use Cutecom
<br> </br>

1. Download Cutecom
   
2. Open the application
   
3. Select connect

![Image](https://github.com/user-attachments/assets/0d5520aa-b567-46e0-a8f5-3b70bb563180)

4. Select the desired device and baud rate before hitting open device

![Image](https://github.com/user-attachments/assets/7ea8dd11-80e8-4ba9-b456-2e84afb75d7c)
 
5. You will now be able to transmit and receive data from your board
   

### Testing
- <H4>Unit Testing</H4>Our integration task relies heavily on transmission and reception of a string. Several unit testing was used to test the functionality of this. 

  - Testing String transmission
	<pre> 
		unit_test_transmit_string:
		LDR   R0, = TEST_UART_BUFFER  @ R0 = pointer to UART buffer
		LDR   R1, =test_string       @ R1 = pointer to test string "Test"
		BL    transmit_string
	
	</pre>
  - Deciphering Caesar Cipher
  
	<pre> 
		unit_test_decipher:
		LDR R0, = TEST_UART_BUFFER
		LDR R1,  = caesar_string
		BL decipher 
	</pre>
<br> </br>
- <H4>Integration Testing</H4>We stepped through our modular functions in debug mode to examine the values in each register against the expected values.

  - Palindrome Test
	<pre> 
		check_palindrome_loop:
			….
		caesar_cipher:
			….
	</pre>

[Expected] When string reaches terminating character  in ‘check_palindrome_loop’ we branch into caesar_cipher

[Output] Enters an infinite loop

From this We’d know shift our focus to check_palindrome_loop.

<br> </br>
- <H4>System Testing</H4>A series of test cases were created to test boundary conditions and cover all possible scenarios when testing the transmitted string from UART1 to UART4. 


  - Test Cases
	<pre> 
		Sending racecar#    With terminating character
		Sending racecar      Without terminating character
		Sending Hello#       Non-palindromic with terminating character
		Sending Hello         Non-palindromic without terminating character
	</pre>
 
- <H4>Sanity Testing</H4>This was implemented to ensure minor changes and bug fixes didn’t affect the overall logic flow of our program. 

  - Change byte configuration
	<pre> 
		LDR R4, =tx_terminating_char
		LDRB R4, [R4] —> Altered from LDR R4, [R4]

	</pre>
 
  - Change bit configuration
	<pre> 
		.equ UART_ORECF, 3 @ Overrun clear flag
		.equ UART_FECF, 1 @ Frame error clear flag  —-> Altered from   .equ UART_FECF, 3
	</pre>
<br> </br>

