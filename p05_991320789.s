###########################################################
#		Program Description
#
#	Name: Andrew Wamboldt				
#										
#								I used a  previous program so it could help me cut down the need for more coding		
#	Date: 05/06/2020
#
#	This program will perform several tasks with data structures. The program will create and read an array
#	of data structures, then will perform calculations on each data structure, and finally will print a table of
#	the results. A sample program run can be found on the last page.

###########################################################
#		Register Usage
#	$t0 ddress
#	$t1	
#	$t2 
#	$t3
#	$t4
#	$t5
#	$t6
#	$t7
#	$t8
#	$t9
###########################################################
		.data
array_pointer:    .word 0     # holds address of multi-dimensional dynamic array pointer (address)
array_height:     .word 0     # hold height of multi-dimensional dynamic array (value)


###########################################################
		.text
main:
# calling a subprogram create_measurments to dynamically create array
    addi $sp, $sp, -4       # allocate one word for $ra
    sw $ra, 0($sp)          # store $ra on stack

                            # no register to backup in the stack

    addi $sp, $sp, -36      # allocate words for the arguments
                            # arguments IN:  NONE
                            # arguments OUT: array base address, length  <-- 2 words

    jal create_measurements   # call subprogram create_measurements

    lw $t0, 0($sp)          # read array base address from stack
    lw $t1, 4($sp)          # read array height from stack
   
    addi $sp, $sp, 12       # deallocate words for the arguments IN & OUT

                            # we did not backup a register, so there is no register restoring

    lw $ra, 0($sp)          # load $ra from stack
    addi $sp, $sp, 4        # deallocate word for $ra


# save array base, array height, array width in static variables,
# if we store them in registers only, we might lose the array base address array sizes
    la $t9, array_pointer
    sw $t0, 0($t9)          # store base address

    la $t9, array_height
    sw $t1, 0($t9)          # store array height

    la $t9, array_width
    sw $t2, 0($t9)          # store array width


# calling a subprogram print_col_matrix to print the array contents
# load base, array height, array length from static memory
    la $t9, array_pointer
    lw $t0, 0($t9)          # store base address

    la $t9, array_height
    lw $t1, 0($t9)          # store array height

    la $t9, array_width
    lw $t2, 0($t9)          # store array width


    addi $sp, $sp, -4       # allocate one word for $ra
    sw $ra, 0($sp)          # store $ra on stack

                            # no register to backup in the stack

    addi $sp, $sp, -12      # allocate words for the arguments
                            # arguments IN: array base address, array height, array width
                            # arguments OUT: NONE

    sw $t0, 0($sp)          # store array base address to stack
    sw $t1, 4($sp)          # store array height to stack
    sw $t2, 8($sp)          # store array width to stack

    jal print_matrix    # call subprogram print_matrix
    addi $sp, $sp, 12       # deallocate words for the arguments IN & OUT

                            # we did not backup a register, so there is no register restoring

    lw $ra, 0($sp)          # load $ra from stack
    addi $sp, $sp, 4        # deallocate word for $ra
	
	
	########## Print transposed###########
	li $v0, 4
	la $a0, print_array_transposed_p
	syscall

	 la $t9, array_pointer
    lw $t0, 0($t9)          # store base address

    la $t9, array_height
    lw $t1, 0($t9)          # store array height

    la $t9, array_width
    lw $t2, 0($t9)          # store array width


    addi $sp, $sp, -4       # allocate one word for $ra
    sw $ra, 0($sp)          # store $ra on stack

                            # no register to backup in the stack

    addi $sp, $sp, -20      # allocate words for the arguments
                            # arguments IN: array base address, array height, array width
                            # arguments OUT: base address of transposed matrix, height of transopsed matrix, width of transposed matrix

    sw $t0, 0($sp)          # store array base address to stack
    sw $t1, 4($sp)          # store array height to stack
    sw $t2, 8($sp)          # store array width to stack
mainEnd:
	li $v0, 10		#End Program
	syscall
###########################################################
###########################################################
#       create_measurments subprogram
#
#   Subprogram description:
#       will have no arguments IN and one argument OUT
#       1) ask the user for the length of the array
#		2) validate that the length is greater than 0 and reprompt the user if it is Invalid
#		3) call allocate_array to allocate an array with the given length
#		4) call read_measurements to read values into the array
#		5) retrun the base address and the legnth of the array
#
#  
#       return array base address, array length
#
###########################################################
#       Arguments IN and OUT of subprogram
#   $sp+0  Holds array base address (OUT)
#   $sp+4  Holds array base height (OUT)
###########################################################
#       Register Usage
#   $t0 Holds array length

###########################################################
		.data
create_array_length_p:     .asciiz "Enter the number of measurements  "

create_array_invalid_p:    .asciiz "Invalid number\n"
###########################################################
		.text
create_measurements:

# prompt and read length
create_measurements__loop:
    li $v0, 4               # prompt for length
    la $a0 create_array_length_p
    syscall

    li $v0, 5               # read integer value of length
    syscall

    bgtz $v0, create_measurements_valid    # check if length is valid

    li $v0, 4               # print error message
    la $a0, create_array_invalid_p
    syscall

    b create_measurements_loop             # branch unconditionally back to beginning of the loop (invalid dimension)

create_measurements_valid:
    move $t0, $v0           # move length value into register $t0
    sw $v0, 4($sp)          # store length for return at 4($sp)


# allocate space for the array to hold double precision numbers
    
	mul $t0, $t0, 4		#multiplying the user inputed number of measurements so thhat it can hold 4 of each measurement
    sll $a0, $t0, 3         # shift for 8 bytes instead of 4 bytes
  
	li $v0, 9
    syscall                 # allocate matrix using system call 9

    sw $v0, 0($sp)          # store base address for return

# calling subprogram read_measurements
    addi $sp, $sp, -4       # allocate one word for $ra
    sw $ra, 0($sp)          # store $ra on stack

                            # no register to backup in the stack

    addiu $sp, $sp, -8     # allocate words for the arguments
                            # arguments IN: array base address, array length
                            # arguments OUT: NONE

    sw $v0, 0($sp)          # store array base address
    sw $t0, 4($sp)          # store array length
    
    jal read_measurements     # call subprogram read_measurements
    addiu $sp, $sp, 8      # deallocate words for the arguments IN & OUT

                            # we did not backup a register, so there is no register restoring

    lw $ra, 0($sp)          # load $ra from stack
    addi $sp, $sp, 4        # deallocate word for $ra
create_measurements_end:
	jr $ra                  # jump back to the main

	###########################################################
#       read_measurements subprogram
#
#   Subprogram description:
#       print a prompt for each entery to be read
#       read the qunatity (an integer) and the three readings (doubles) for each data structure
#		store the quantity and reading (but not the average!) in the data structures 
#
#   SO I am assuming i provide the values, i am very consfused on this so im just going to provide my own numbers
###########################################################
#       Arguments IN and OUT of subprogram
#   $sp+0  Holds array base address (IN)
#   $sp+4  Holds array base height (IN)
#   $sp+8  Holds array base width (IN)
###########################################################
#       Register Usage
#   $t0 Holds matrix base address
#   $t1 Holds matrix height
#   $t2 Holds matrix width
#	$t3 Holds the Row index
#	$t4 Holds the Column Index
#	$t5 Holds the indx address (i) for the given column
#	$t6 Holds the value -50
#	$t7 Holds the value 100
###########################################################
		.data
number_of_p:				.asciiz "Enter the number of measurements: same number as the array"
read_measurements_integer_p:.asciiz "\nEnter quantity: "
read_measurements_Double1:	.asciiz "Enter First Reading: "
read_measurements_Double2:	.asciiz "Enter second reading: "
read_measurements_Double3:	.asciiz "Enter third reading: "

print_next_line:			.asciiz "\n"

###########################################################
		.text
read_measurements:
	lw $t0, 0($sp)			# loads array base addres from the stack
	lw $t1, 4($sp)			# laods the measurements length from the stack
	
	li $t3, 0				# set  to 0
	
	li $v0, 4				#print a string
	la $a0, number_of_p
	syscall


	li $v0, 5				# reads a integer from the user
	syscall
	
	move $t4, $v0			#moves this value fo user prompt to know how many times to run the loop

readfor_measurements_loop:
	blez $t4, endfor_measurements

	li $v0, 4				#print a string
	la $a0, read_measurements_integer_p
	syscall


	li $v0, 5				# reads a integer from the user
	syscall
	
	sw $v0, 0($t0)			#stores the value into the array making sure it can hold a double precion number
	addi $t0, $t0, 8		# increment array pointer by 8

	li $v0, 4				#print a string
	la $a0, read_measurements_Double1
	syscall

	li $v0, 7				# reads the user inputed double
	syscall

	s.d $f0, 0($t0)			#$ stores the double that the user has entered
	addi $t0, $t0, 8		# increment array pointer by 8

	li $v0, 4				#print a string
	la $a0, read_measurements_Double2
	syscall

	li $v0, 7				# reads the user inputed double
	syscall

	s.d $f0, 0($t0)			#$ stores the double that the user has entered
	addi $t0, $t0, 8		# increment array pointer by 8

	li $v0, 4				#print a string
	la $a0, read_measurements_Double3
	syscall

	li $v0, 7				# reads the user inputed double
	syscall

	s.d $f0, 0($t0)			#$ stores the double that the user has entered
	addi $t0, $t0, 8		# increment array pointer by 8

	li $v0, 4				#print a string --> it prints a new line
	la $a0, print_next_line
	syscall

	addi $t4, $t4, -1
	b readfor_measurements_loop

endfor_measurements:

read_measurements_end:
	jr $ra                  # jump back to the main

####################################################
#		Print Matix
##       Arguments IN and OUT of subprogram
#   $sp+0  Holds array base address (IN)
#   $sp+4  Holds array base height (IN)
#   $sp+8  Holds array base width (IN)
############################################
#   $t0 Holds matrix base address
#   $t1 Holds matrix height
#   $t2 Holds matrix width
#   $t3 Holds outer-loop counter
#   $t4 Holds inner-loop counter
#   $t5 Holds temporarily value
###################################################
	.data

	########################
	.text
print_matrix:
# save arguments so we do not lose them
    lw $t0, 0($sp)          # load array base address
    lw $t1, 4($sp)          # load array height
    lw $t2, 8($sp)          # load array width

    li $t3, 0
print_matrix_loop_outer:
    bge $t3, $t1, print_matrix_loop_outer_end


    li $t4, 0
print_matrix_loop_inner:
    bge $t4, $t2, print_matrix_loop_inner_end


    mul $t5, $t4, $t1       # $t5 <-- e * k
    add $t5, $t5, $t3       # $t5 <-- e * k + n'
    sll $t5, $t5, 2         # $t5 <-- s * (e * k + n')
    add $t5, $t0, $t5       # $t5 <-- b + s * (e * k + n') = i

    lw $a0, 0($t5)          # load a value from array into register $a0
    li $v0, 1
    syscall

    li $a0, 9               # ASCII code 9 - horizontal tab character
    li $v0, 11
    syscall

    addiu $t4, $t4, 1       # increment inner-loop counter

    b print_matrix_loop_inner   # branch unconditionally back to beginning of the inner loop

print_matrix_loop_inner_end:
    li $a0, 10              # ASCII code 10 - newline character
    li $v0, 11
    syscall

    addiu $t3, $t3, 1       # increment outer-loop counter

    b print_matrix_loop_outer   # branch unconditionally back to beginning of the outer loop

print_matrix_loop_outer_end:
print_matrix_end:
	jr $ra                  # jump back to the main

	     #Arguments IN and OUT of subprogram
#   $sp+0  Holds array base address (IN)
#   $sp+4  Holds array base height (IN)
#   $sp+8  Holds array base width (IN)
#	$sp+12 base address of transposed matrix (Out)
#	$sp+16 Height of transposed Matrix (out)
#	$sp+20 Width of transposed Matrix (out)

#   $t0 Holds matrix base address
#   $t1 Holds matrix height
#   $t2 Holds matrix width

	.data

###################
	.text
transpose_matrix:
	lw $t0, 0($sp)			#holds the matrix base address
	lw $t1, 4($sp)			#holds the matrix Height
	lw $t2, 8($sp)			#holds the matrix width

transpose_matrix_loop:
	mul $a0, $t1, $t2		# $a0 = height x width
	sll $a0, $a0, 2			# $a0 4 (height x width)

	li $v0, 9				#allocate matrix using sysetm call 9
	syscall