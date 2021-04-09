###########################################################
#		Program Description
#
#	Name: Andrew Wamboldt				I used lab 12 as guide for this program and used code from it
#										Had to change a few things like allow it store double precision numbers  
#										Allowed for less coding on my half
#	Date: 4/23/2020
#
#	The goal of this program is to get familiar with floating point instructions and utilize multidimensional arrays. 
#	Specifically, you will be writing a program that will transpose a twodimensional m x n matrix,
#	where m is the number of rows and n is the number of columns. 
#	The program will get the dimensions of row major matrix, read in all of the values, and print it out
#	to the console. It will then transpose the matrix and print the transposed row major matrix out.
#	You will write four subprograms: create_matrix, read_matrix, print_matrix, and
#	transpose_matrix. 
###########################################################
#		Register Usage
#	$t0 Holds the base address
#	$t1	Holds the Array Height
#	$t2 Holds the array width
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
array_width:      .word 0     # hold width of multi-dimensional dynamic array (value)

print_array_transposed_p:	.asciiz "The array Transposed is:"
###########################################################
		.text
main:
# calling a subprogram create_array to dynamically create multi-dimensional array
    addi $sp, $sp, -4       # allocate one word for $ra
    sw $ra, 0($sp)          # store $ra on stack

                            # no register to backup in the stack

    addi $sp, $sp, -12      # allocate words for the arguments
                            # arguments IN:  NONE
                            # arguments OUT: array base address, array height, array width  <-- 3 words

    jal create_matrix   # call subprogram create_col_matrix

    lw $t0, 0($sp)          # read array base address from stack
    lw $t1, 4($sp)          # read array height from stack
    lw $t2, 8($sp)          # read array width from stack
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
#       create_matrix subprogram
#
#   Subprogram description:
#       ask the user for a height and width, then dynamically
#       allocate space for a matrix of words with the given dimensions (using system call 9)
#
#       call read_matrix to fill the matrix
#
#   High level design:
#       prompt and read array height and array width
#       array base address <-- allocate # of bytes: array height * array width * 4
#
#       call: null <-- read_matrix(array base address, array height, array width)
#
#       return array base address, array height, array width
#
###########################################################
#       Arguments IN and OUT of subprogram
#   $sp+0  Holds array base address (OUT)
#   $sp+4  Holds array base height (OUT)
#   $sp+8  Holds array base width (OUT)
###########################################################
#       Register Usage
#   $t0 Holds matrix height
#   $t1 Holds matrix width

###########################################################
		.data
create_matrix_height_p:     .asciiz "Enter matrix height: "
create_matrix_width_p:      .asciiz "Enter matrix width: "
create_matrix_invalid_p:    .asciiz "Invalid dimension\n"
###########################################################
		.text
create_matrix:

# prompt and read matrix height
create_matrix_height_loop:
    li $v0, 4               # prompt for height
    la $a0 create_matrix_height_p
    syscall

    li $v0, 5               # read integer value of height
    syscall

    bgtz $v0, create_matrix_height_valid    # check if height is valid

    li $v0, 4               # print error message
    la $a0, create_matrix_invalid_p
    syscall

    b create_matrix_height_loop             # branch unconditionally back to beginning of the loop (invalid dimension)

create_matrix_height_valid:
    move $t0, $v0           # move height value into register $t0
    sw $v0, 4($sp)          # store height for return at 4($sp)

# prompt and read matrix height
create_matrix_width_loop:
    li $v0, 4               # prompt for width
    la $a0, create_matrix_width_p
    syscall

    li $v0, 5               # read integer value of width
    syscall

    bgtz $v0, create_matrix_width_valid     # check if width is valid

    li $v0, 4               # print error message
    la $a0, create_matrix_invalid_p
    syscall

    b create_matrix_width_loop              # branch unconditionally back to beginning of the loop (invalid dimension)

create_matrix_width_valid:
    move $t1, $v0           # move width value into register $t1
    sw $v0, 8($sp)          # store width for return at 8($sp)


# allocate space for matrix
    mul $a0, $t0, $t1       # $a0 <-- height * width
    sll $a0, $a0, 2         # $a0 <-- 4 * (height * width)
  
	li $v0, 9
    syscall                 # allocate matrix using system call 9

    sw $v0, 0($sp)          # store base address for return

# calling subprogram read_col_matrix
    addi $sp, $sp, -4       # allocate one word for $ra
    sw $ra, 0($sp)          # store $ra on stack

                            # no register to backup in the stack

    addiu $sp, $sp, -12     # allocate words for the arguments
                            # arguments IN: array base address, matrix height, matrix width <-- 3 words
                            # arguments OUT: NONE

    sw $v0, 0($sp)          # store array base address
    sw $t0, 4($sp)          # store array height
    sw $t1, 8($sp)          # store array width

    jal read_matrix     # call subprogram read_matrix
    addiu $sp, $sp, 12      # deallocate words for the arguments IN & OUT

                            # we did not backup a register, so there is no register restoring

    lw $ra, 0($sp)          # load $ra from stack
    addi $sp, $sp, 4        # deallocate word for $ra
create_matrix_end:
	jr $ra                  # jump back to the main

	###########################################################
#       read_matrix subprogram
#
#   Subprogram description:
#       This subprogram reads words into a matrix until the matrix is full
#       elements must be stored in row-major order
#
#   Pseudo-code:
#       for (int i = 0; i < array height; i++) {
#           for (int j = 0; j < array width; j++) {
#
#               prompt and read array value
#
#               row index = i
#               column index = j
#
#               memory[array base address + 4 * (array width * row index + column index)] = array value
#
#           }
#       }
#
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
read_matrix_prompt_p:   .asciiz "Enter an integer: "
###########################################################
		.text
read_matrix:
	lw $t0, 0($sp)			#loads array base addres from the stack
	lw $t1, 4($sp)			# laods the matrix height from the stack
	lw $t2, 8($sp)			#loads the martix width from the stack

	li $t3, 0				#set row index to 0
	li $t6, -50				# sets the minimum value for a user to input
	li $t7, 100				# sets the maximum value for the user to input
readfor_Rows:
	bge $t3, $t1, endfor_Rows

	li $t4, 0				#sets the colum index to 0
readfor_Cols:
	bge $t4, $t2, endfor_Cols

	mul $t5, $t4, $t1       # $t5 <-- e * k
    add $t5, $t5, $t3       # $t5 <-- e * k + n'
    sll $t5, $t5, 2         # $t5 <-- s * (e * k + n')
    add $t5, $t0, $t5       # $t5 <-- b + s * (e * k + n') = i


	li $v0, 4				#print a string
	la $a0, read_matrix_prompt_p
	syscall


	li $v0, 5				# reads a integer from the user
	syscall


	#blt $v0, $t6, read_matrix_reprompt	#branch if user enters a value less than -50
	#bgt $v0, $t7, read_matrix_reprompt	# branch if the user enters a value more than 100

	sw $v0, 0($t5)			#stores the value into the array making sure it can hold a double precion number
	#l.d $f4, 0($t5)		# stores a double precision number
	addi $t4, $t4, 1
	b readfor_Cols
endfor_Cols:
	
	addi $t3, $t3, 1
	b readfor_Rows
endfor_Rows:

	#sw $v0, 0($t0)			#stores the value into the array

read_matrix_end:
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