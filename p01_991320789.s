#Andrew Wamboldt 2/13/2020
###########################################################
#		Program Description
#
#Write a program that will prompt the user to enter in a series of non-negative odd integers (greater
#than or equal to 0) ) keeping track of both the total number (count) and the sum of all valid numbers
#entered. The program will end once 15 valid integers have been input, or a cardinal value of -4
#has been entered. Any invalid integers that are entered should print an error message for each
#occurrence and ignore the input. Once all integers have been entered by the user, the program
#will output their sum, count, and average before ending the program.
###########################################################
#		Register Usage
#	$t0	holds base array address
#	$t1	holds Sum
#	$t2	holds count
#	$t3
#	$t4
#	$t5
#	$t6	holds temp user input
#	$t7
#	$t8
#	$t9
###########################################################
		.data
sum_p:	.asciiz "Sum: "
count_p:	.asciiz "\nCount: "
nextLine_p:	.asciiz "\n"
average_p:	.asciiz "\nAverage: "
array: .word 0:15	#creates an emepty array of 15 spaces
sum_var:	.word 0
###########################################################
		.text
main:
	la $a0, array	#loading the array
	
	jal read_values #jump and link

	

mainEnd:
	move $t0, $v0	#moves sum from fuction below to main
	#move $t1, $v1	#moves count

	li $v0, 4
	la $a0, sum_p	#prints "sum: "
	syscall

	li $v0, 1
	move $a0, $t0	#prints the actual sum of the numbers
	syscall
	
	li $v0, 4
	la $a0, count_p
	syscall			#prints out count on a new line

	li $v0, 1
	move $a0, $t3
	syscall

	
	li $v0, 4
	div $t8, $t0, $t3	#math for average (count / sum)
	mfhi $t4
	li $v0, 4
	la $a0, average_p
	syscall			#prints out average on a new line

	li $v0, 1
	move $a0, $t8
	syscall
	
	li $v0, 10		#End Program
	syscall

	.data
read_values_prompt:	.asciiz "Please enter a odd even Integer >0: "
error_mess:	.asciiz "Invalid Integer Please try again! \n"
	.text
read_values:
	move $t0, $a0	#arrays address now at $t0
	li $t1, 0	#Sum
	li $t2, 15	#Count
	li $t3, 0	#current count
	li $t9, -4	#quit program
read_loop:
	li $v0, 4
	la $a0, read_values_prompt
	syscall

	li $v0, 5	#loads in what the user entered
	syscall

	blez, $v0, negative #if user input is less than 0 go to negative
	add $t1, $t1, $v0	#adds for sum
	#add $t6, $v0, $t6

	andi $v0, 1 #extracts the LSB
	beqz $v0, even

	#add $t1, $t1, $v0	#adds for sum
	add $t3, $t3, 1	#adds 1 to the count

	sw $v0, 0($t0)	#writes whatever v0 holds to the array adress
	addi $t0, $t0, 4 #increments the index in the array by 1
	
	beq $t3, $t2, exit #ends when count equals 15

	j read_loop
even:
	li $v0, 4
	la $a0, error_mess
	syscall
	
	b read_loop	#returns back to read_loop
negative:
	beq $t9, $v0, exit #if user enters a -4 the program ends but does all the correct end procedures
	li $v0, 4
	la $a0, error_mess
	syscall
	b read_loop

exit:
	
	move $v0, $t1	#retruns all the values to where the sum is stored
	#move $v1, $t2	#retrun the count of the numbers ran
	jr $ra
###########################################################

