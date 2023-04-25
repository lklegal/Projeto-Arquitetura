#####################################################################
#
# Ludo project
# ##############
#
# Developers:
#	 Ramon Nepomuceno
#	 *your name*
# ##############
#
# Bitmap Display Configuration:
# ###############
# - Unit width in pixels: 16                                          
# - Unit height in pixels: 16
# - Display width in pixels: 256
# - Display height in pixels: 256
# - Base Address for Display: 0x10008000 ($gp)
#####################################################################

.data
	
	current_position_v:	.word	0, 0, 0, 0
	previous_colors_v: 	.word	0x008000, 0xFF0000, 0x0000FF, 0xFFFF00
	current_player:		.word   0
	players_colors:		.word   green_name, red_name, blue_name, yellow_name
	
	green_name:			.asciiz "Verde"			
	red_name:			.asciiz "Vermelho"
	blue_name:			.asciiz "Azul"
	yellow_name:			.asciiz "Amarelo"
	
	dice_roll_message_1:            .asciiz "Jogador "
	dice_roll_message_2:            .asciiz " rolou os dados, e tirou o numero "
	dice_roll_result:       .word   3
	
	players_paths_m:	.word   green_path, red_path, blue_path, yellow_path
	players_colors_v:	.word   0x00ff00, 0xff708e, 0x00008B, 0xffa500
	
		
	green:  		.word 	0x008000
	dark_green:     	.word 	0x00ff00
	red:	        	.word 	0xFF0000
	dark_red:		.word 	0xff708e
	blue:	        	.word 	0x0000FF
	dark_blue:		.word 	0x00008B
	dark_yellow:    	.word 	0xffa500
	yellow:         	.word 	0xFFFF00	
		
	path_size:		.word	57
	green_path:		.word 	17,97,98,99,100,101,86,70,54,38,22,6,7,8,24,40,56,72,88,105,106,107,108,109,110,126,142,141,140,139,138,137,152,168,184,200,216,232,231,230,214,198,182,166,150,133,132,131,130,129,128,112,113,114,115,116,117,118
	red_path:		.word	26,24,40,56,72,88,105,106,107,108,109,110,126,142,141,140,139,138,137,152,168,184,200,216,232,231,230,214,198,182,166,150,133,132,131,130,129,128,112,96,97,98,99,100,101,86,70,54,38,22,6,7,23,39,55,71,87,103
	blue_path:		.word   170,141,140,139,138,137,152,168,184,200,216,232,231,230,214,198,182,166,150,133,132,131,130,129,128,112,96,97,98,99,100,101,86,70,54,38,22,6,7,8,24,40,56,72,88,105,106,107,108,109,110,126,125,124,123,122,121,120
	yellow_path:		.word	161,214,198,182,166,150,133,132,131,130,129,128,112,96,97,98,99,100,101,86,70,54,38,22,6,7,8,24,40,56,72,88,105,106,107,108,109,110,126,142,141,140,139,138,137,152,168,184,200,216,232,231,215,199,183,167,151,135

.text

	#jal draw_board
main_loop:
	jal roll_dice
	lw $t0, current_player
	sll $t0, $t0, 2
	la $t1, current_position_v
	add $t1, $t1, $t0
	lw $t2, 0($t1) #current_position_v[current_player]
	seq $t4, $t2, $zero #if(current_position_v[current_player] == 0)
	lw $t3, dice_roll_result
	sne $t5, $t3, 6 # if(number != 6)
	and $t6, $t5, $t4
	beq $t6, 1, change_player_condition #if(current_position_v[current_player] == 0 && number != 6)
	j try_move #try_move();
	beq $t3, 6, main_loop #while(number == 6);
change_player_condition:
	srl $t0, $t0, 2
	beq $t0, 3, change_player_condition_true #if(current_player == 3)
	addi $t0, $t0, 1 #currente_player++;
	j change_player_condition_false
change_player_condition_true: #else:
	li $t0, 0 #current_player = 0
change_player_condition_false:
	sw $t0, current_player
	j main_loop
exit_game:
	li $v0,10
	syscall
	
try_move:
	j exit_game

roll_dice:
	li $v0, 4
	la $a0, dice_roll_message_1
	syscall #imprime "Jogador "
	li $v0, 1
	lw $a0, current_player
	addi $a0, $a0, 1
	syscall #imprime o número do jogador atual
	li $v0, 4
	la $a0, dice_roll_message_2
	syscall #imprime " rolou os dados, e tirou o numero "
	li $v0, 42
	li $a1, 6
	syscall #sorteia um número de 0 a 5
	addi $a0, $a0, 1 #adiciona 1 ao número sorteado, para ficar de 1 a 6
	sw $a0, dice_roll_result
	li $v0, 1
	syscall #imprime o número de 1 a 6 sorteado
	li $v0, 12
	syscall #espera um input do jogador
	jr $ra

draw_board:

	#store registers $s*
	addi $sp, $sp, -36
	sw $s0, 0 ($sp) 
	sw $s1, 4 ($sp)
	sw $s2, 8 ($sp)
	sw $s3, 12 ($sp)
	sw $s4, 16 ($sp)
	sw $s5, 20 ($sp)
	sw $s6, 24 ($sp)
	sw $s7, 28 ($sp)
	sw $ra, 32 ($sp)
	##------

	lw $t0, green
	addi $sp, $sp, -4
	sw $t0, 0 ($sp)
	li $a0, 0
	li $a1, 0
	jal draw_square
	
	lw $t0, red
	addi $sp, $sp, -4
	sw $t0, 0 ($sp)
	li $a0, 0
	li $a1, 9
	jal draw_square	
	
	lw $t0, yellow
	addi $sp, $sp, -4
	sw $t0, 0 ($sp)
	li $a0, 9
	li $a1, 0
	jal draw_square
	
	lw $t0, blue
	addi $sp, $sp, -4
	sw $t0, 0 ($sp)
	li $a0, 9
	li $a1, 9
	jal draw_square

	lw $t0, green
	addi $sp, $sp, -4
	sw $t0, 0 ($sp)
	li $a0, 7
	li $a1, 1	
	jal draw_line

	lw $t0, blue
	addi $sp, $sp, -4
	sw $t0, 0 ($sp)
	li $a0, 7
	li $a1, 8	
	jal draw_line

	lw $t0, red
	addi $sp, $sp, -4
	sw $t0, 0 ($sp)
	li $a0, 1
	li $a1, 7	
	jal draw_colum
	
	lw $t0, yellow
	addi $sp, $sp, -4
	sw $t0, 0 ($sp)
	li $a0, 8
	li $a1, 7	
	jal draw_colum
	
	
## dots green
	lw $t0, dark_green
	addi $sp, $sp, -4
	sw $t0, 0 ($sp)
	li $a0, 1
	li $a1, 1	
	jal draw_dot	
	
	
## red dots 
	lw $t0, dark_red
	addi $sp, $sp, -4
	sw $t0, 0 ($sp)
	li $a0, 1
	li $a1, 10	
	jal draw_dot	


## yellow dots 
	lw $t0, dark_yellow
	addi $sp, $sp, -4
	sw $t0, 0 ($sp)
	li $a0, 10
	li $a1, 1	
	jal draw_dot	

## blue dots 
	lw $t0, dark_blue
	addi $sp, $sp, -4
	sw $t0, 0 ($sp)
	li $a0, 10
	li $a1, 10	
	jal draw_dot

		##----
	lw $s0, 0 ($sp) 
	lw $s1, 4 ($sp)
	lw $s2, 8 ($sp)
	lw $s3, 12 ($sp)
	lw $s4, 16 ($sp)
	lw $s5, 20 ($sp)
	lw $s6, 24 ($sp)
	lw $s7, 28 ($sp)
	lw $ra, 32 ($sp)
	addi $sp, $sp, 36
	jr $ra	
		
				
#for(i=0;i<6;i++)
#  for(j=0;j<6;j++)
#     image[i*16][j] = green
#    

draw_square:
	lw $s3, 0 ($sp)
	addi $sp, $sp, 4
	#store registers $s0,
	addi $sp, $sp, -36
	sw $s0, 0 ($sp) 
	sw $s1, 4 ($sp)
	sw $s2, 8 ($sp)
	sw $s3, 12 ($sp)
	sw $s4, 16 ($sp)
	sw $s5, 20 ($sp)
	sw $s6, 24 ($sp)
	sw $s7, 28 ($sp)
	sw $ra, 32 ($sp)
	
	move $t0, $a0 	 # i
	addi $t1, $a0, 6 
for_i:	li $t3, 0
	slt $t3, $t0, $t1 # i < 6
	beq $t3, $zero, exit_for_i
	move $t4, $a1 # j
	add $t5 , $a1, 6
for_j:	li $t3, 0
	slt $t3, $t4, $t5 # i < 6
	beq $t3, $zero, exit_for_j
	lw $s0, green
	sll $s2, $t0, 4	  # i*16
	add $s2, $s2, $t4 # i*16+j
	sll $s2, $s2, 2   # (i*16+j)*4
	add $s2, $s2, $gp # img[i*16][j]
	sw  $s3, 0 ($s2)   #
	add $t4, $t4, 1
	j for_j
exit_for_j:
	add $t0, $t0, 1
	j for_i
exit_for_i:
	##----
	lw $s0, 0 ($sp) 
	lw $s1, 4 ($sp)
	lw $s2, 8 ($sp)
	lw $s3, 12 ($sp)
	lw $s4, 16 ($sp)
	lw $s5, 20 ($sp)
	lw $s6, 24 ($sp)
	lw $s7, 28 ($sp)
	lw $ra, 32 ($sp)
	addi $sp, $sp, 36
	jr $ra	
	
	
#for(i;i<6;i++)
#	image[i*16]=		
draw_line:
	lw $s3, 0 ($sp)
	addi $sp, $sp, 4
	#store registers $s0,
	addi $sp, $sp, -36
	sw $s0, 0 ($sp) 
	sw $s1, 4 ($sp)
	sw $s2, 8 ($sp)
	sw $s3, 12 ($sp)
	sw $s4, 16 ($sp)
	sw $s5, 20 ($sp)
	sw $s6, 24 ($sp)
	sw $s7, 28 ($sp)
	sw $ra, 32 ($sp)

	move $t0, $a0
	move $t4, $a1 # j
	add $t5 , $a1, 6
for_j_line:
	li $t3, 0
	slt $t3, $t4, $t5 # i < 6
	beq $t3, $zero, exit_for_line
	lw $s0, green
	sll $s2, $t0, 4	  # i*16
	add $s2, $s2, $t4 # i*16+j
	sll $s2, $s2, 2   # (i*16+j)*4
	add $s2, $s2, $gp # img[i*16][j]
	sw  $s3, 0 ($s2)   #
	add $t4, $t4, 1
	j for_j_line
exit_for_line:
	##----
	lw $s0, 0 ($sp) 
	lw $s1, 4 ($sp)
	lw $s2, 8 ($sp)
	lw $s3, 12 ($sp)
	lw $s4, 16 ($sp)
	lw $s5, 20 ($sp)
	lw $s6, 24 ($sp)
	lw $s7, 28 ($sp)
	lw $ra, 32 ($sp)
	addi $sp, $sp, 36
	jr $ra
	
			
draw_colum:
	lw $s3, 0 ($sp)
	addi $sp, $sp, 4
	#store registers $s0,
	addi $sp, $sp, -36
	sw $s0, 0 ($sp) 
	sw $s1, 4 ($sp)
	sw $s2, 8 ($sp)
	sw $s3, 12 ($sp)
	sw $s4, 16 ($sp)
	sw $s5, 20 ($sp)
	sw $s6, 24 ($sp)
	sw $s7, 28 ($sp)
	sw $ra, 32 ($sp)
	
	
	move $t0, $a0 # i
	move $t4, $a1 # j
	add $t5 , $a0, 6
for_j_colum:
	li $t3, 0
	slt $t3, $t0, $t5 # j < 6
	beq $t3, $zero, exit_for_colum
	sll $s2, $t0, 4	  # i*16
	add $s2, $s2, $t4 # i*16+j
	sll $s2, $s2, 2   # (i*16+j)*4
	add $s2, $s2, $gp # img[i*16][j]
	sw  $s3, 0 ($s2)   #
	add $t0, $t0, 1
	j for_j_colum
exit_for_colum:
		##----
	lw $s0, 0 ($sp) 
	lw $s1, 4 ($sp)
	lw $s2, 8 ($sp)
	lw $s3, 12 ($sp)
	lw $s4, 16 ($sp)
	lw $s5, 20 ($sp)
	lw $s6, 24 ($sp)
	lw $s7, 28 ($sp)
	lw $ra, 32 ($sp)
	addi $sp, $sp, 36
	jr $ra

draw_dot:
	lw $s3, 0 ($sp)
	addi $sp, $sp, 4
	#store registers $s0,
	addi $sp, $sp, -36
	sw $s0, 0 ($sp) 
	sw $s1, 4 ($sp)
	sw $s2, 8 ($sp)
	sw $s3, 12 ($sp)
	sw $s4, 16 ($sp)
	sw $s5, 20 ($sp)
	sw $s6, 24 ($sp)
	sw $s7, 28 ($sp)
	sw $ra, 32 ($sp)
	
	move $t0, $a0      # i
	move $t4, $a1 	   # j
	sll $s2, $t0, 4	   # i*16
	add $s2, $s2, $t4  # i*16+j
	sll $s2, $s2, 2    # (i*16+j)*4
	add $s2, $s2, $gp  # img[i*16][j]
	sw  $s3, 0 ($s2)   # 
		##----
	lw $s0, 0 ($sp) 
	lw $s1, 4 ($sp)
	lw $s2, 8 ($sp)
	lw $s3, 12 ($sp)
	lw $s4, 16 ($sp)
	lw $s5, 20 ($sp)
	lw $s6, 24 ($sp)
	lw $s7, 28 ($sp)
	lw $ra, 32 ($sp)
	addi $sp, $sp, 36
	jr $ra
