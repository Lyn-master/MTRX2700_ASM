
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

</pre>

<H4>Part b:</H4>
<br> </br>
<pre> 
	
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
</pre>

<H3>Usage</H3>
Instructions to import Projects
<br> </br>
<ol>
	<li>Ensure the latest STM32CubeIDE software is downloaded on the chosen device. </li>
	<li>Connect the STM32 board to the computer</li>
	<li>Open the application and select “Import Project”</li>
</ol>
![Image](https://github.com/user-attachments/assets/0051edc1-82b4-4f1e-8cf3-7bb460e2ba0b) 
