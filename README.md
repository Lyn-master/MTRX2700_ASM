
# Integration Task for STM32 using Assembly Language
This project exhibits serial communication between two STM32 boards using distinct UART interfaces (UART1 and UART4). Data is assessed for palindromic qualities before being conditionally encrypted or decrypted using the Caesar cypher.
Timers are integrated to switch between modes.
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




