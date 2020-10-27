.text

.global add_3
.func add_3, add_3
.type add_3, %function

add_3:
add r0, r0, r1
add r0, r0, r2
bx lr
.endfunc

.text

.global add_10
.func add_10, add_10
.type add_10, %function

add_10:
cmp r1, #0
beq end_add
mov r2, #0
add_loop:
	ldr r3, [r0], #4
	add r2, r2, r3
	subs r1, r1, #1
	bne  add_loop
mov r0, r2
end_add:
bx lr
.endfunc

.text

.global arr_copy
.func arr_copy, arr_copy
.type arr_copy, %function

arr_copy:
cmp r2, #0
beq end_add
copy_loop:
	ldr r3, [r0], #4
	str r3, [r1], #4
	subs r2, r2, #1
	bne  copy_loop
end_copy:
bx lr
.endfunc

.text




.global sub_cond_as
.func sub_cond_as, sub_cond_as
.type sub_cond_as, %function
// r0 = u   r1 = n   r2 = size   r3 = t   r4 = res   r5 = sub   r6 = b    r7 =i    r8 = U[i]   r9 = n[i]
sub_cond_as:
	push {r4-r9}
	//mov r6, #0
	mov r7, #0
sub_for:
	teq r7 ,r2
	beq end_sub_for
	ldr r8, [r0, r7, lsl #2]  //u[i] load
	ldr r9, [r1, r7, lsl #2]  //n[i] load
	sbcs r5, r8, r9	// u-n

	str r5, [r3, r7, lsl #2] // store sub in t[i]
	add r7, r7, #1
	b sub_for
end_sub_for:
	//sbcs r5, r8, r9	// u-n
	bcc end_sub_cond_ass //jump if not equal
	mov r7, #0
loop2:
	cmp r7, r2
	beq end_sub_cond_ass //check if r7 equals size
	ldr r9, [r3, r7, lsl #2] //load t[i]
	str r9, [r0, r7, lsl #2] //store t[i] in u[i]
	add r7, r7, #1
	b loop2
end_sub_cond_ass:
	pop {r4-r9}
	bx lr
.endfunc

.global outer_for
.func outer_for, outer_for
.type outer_for, %function



outer_for:
	push {r4-r12}
	ldr r11, [sp, #40] // size
	mov r12, #0	//i

outer_for_loop:
	cmp r12, r11
	beq end_outer_for
	ldr r4, [r0]	// Load t
	ldr r5, [r1]	// Load a
	ldr r6, [r2, r12, lsl #2]	// Load b[i]
	umull r8, r7, r5, r6
	adds r8, r8, r4 //does addition and puts flag high if overflow
	adc r7, r7, #0 //does addition taking into account the carry
	mov r10, #1
add_f:
	cmp r7, #0
	beq endloop5
	ldr r4, [r0, r10, lsl #2] // Load t[j+1]
	adds r5, r4, r7 //r5 = sum
	str r5, [r0, r10, lsl #2]

	//store sum in t[j+1]
	add r10, r10, #1
	bcc endloop5
loop5:
	ldr r4, [r0, r10, lsl #2] // Load t[j+1]
	adcs r5, r4, #0 //r5 = sum
	str r5, [r0, r10, lsl #2] //store sum in t[j+1]
	add r10, r10, #1
	bcs loop5
endloop5:
	ldr r4, [sp, #36]
	ldr r4, [r4] //load value n prime
	umull r9, r7, r8, r4 // S*n_prime = m
	ldr r5, [r3] //load n[0]
	umull r5, r7, r5, r9
	adds r8, r8, r5 //does addition and puts flag high if overflow
	adc r7, r7, #0 //does addition taking into account the carry

// Start inner for
	//mov r6, r12
	push {r12}
	mov r12, r3
	mov r5, r9
	mov r10, r0
	mov r3, r2
	mov r2, r1
	mov r1, r11
	mov r0, r7

	mov r11, #1
for:
	cmp r11, r1
	beq endfor
	ldr r4, [r10, r11,lsl #2]	// Load t[j]

	ldr r5, [r2, r11, lsl #2]	// Load a[j]

	umull r8, r7, r5, r6
	adds r8, r8, r0// mult result + carry
	adc r7, r7, #0 // add carry

	adds r8, r8, r4 //does addition and puts flag high if overflow
	adc r7, r7, #0 //does addition taking into account the carry
	
	add r0, r11, #1

	cmp r7, #0
	beq endloop4
	ldr r4, [r10, r0, lsl #2] // Load t[j+1]
	//mov r4, r5
	adds r5, r4, r7 //r5 = sum
	str r5, [r10, r0, lsl #2] //store sum in t[j+1]
	add r0, r0, #1
	bcc endloop4
loop4:
	ldr r4, [r10, r0, lsl #2] // Load t[j+1]
	adcs r5, r4, #0 //r5 = sum
	str r5, [r10, r0, lsl #2] //store sum in t[j+1]
	add r0, r0, #1
	bcs loop4
	
endloop4:
	//pop {r11}

	ldr r7, [r12, r11, lsl #2] //Load n[j]

	mov r0, r8
	umull r8, r7, r9, r7
	adds r8, r8, r0 // mult result + carry
	adc r7, r7, #0 // add carry
	sub r0, r11, #1 //r6<-j-1
	str r8, [r10, r0, lsl #2]
	mov r0, r7
	add r11, r11, #1
	b for
endfor:
	//str r7, [r0]
	ldr r4, [r10, r1, lsl #2]
	adds r8, r7, r4      
	mov r7, #0				
	adc r7, r7, #0
	
	sub r1, r1, #1
	str r8, [r10, r1, lsl #2] //store s in t[i-1]
	add r1, r1, #2
	ldr r4, [r10, r1, lsl #2] //load t[size+1]
	add r4, r4, r7				//lo
	mov r8, #0
	str r8, [r10, r1, lsl #2]
	sub r1, r1, #1
	str r4, [r10, r1, lsl #2]



	mov r1, r2
	mov r2, r3
	mov r3, r12
	mov r0, r10
	pop {r12}
	add r12, r12, #1
	b outer_for_loop
end_outer_for:
	pop {r4-r11}
	bx lr
.endfunc





@USEFUL FUNCTIONS

@ add Rx, Ry, Rz	//Rx = Ry + Rz  second operand can be constant
@ sub Rx, Ry, Rz	//Rx = Ry - Rz second operand can be constant
@ addc Rx, Ry, Rz	//Rx = Ry + Rz + CARRY   one operand can be constant
@ cmp Rx, Ry		//compares Rx and Ry and if they are equal sets Z flag, otherwise resets Z flag (works by subtracting two values and checks if result is zero)
@ b{cond} <label>		//Jumps to given label in the code if given condition is satisfied
@ umull Rn, Rm, Rx, Ry 	//{Rm, Rn} = Rx * Ry Multiplies unsigned 32bit values in Rx and Ry. Stores the higher 32 bits in Rm, and lower in Rn
@ ldr Rx, [Ry]		//Loads from memory pointed by Ry to register Rx, see addressing modes for post increment, pre decrement
@ str Rx, [Ry]		//Stores to memory pointed by Ry value in register Rx, see addressing modes for post increment, pre decrement
@ pop {}			//Pops values from stack to specified registers in order they are specified
@ push {}			//Push registers to stack in orded they are specified
@ ldmia rx, {set of registers} //Loads to specified set of registers memory values, starting from rx. Increasing addresses
@ stmia rx, {set of registers} //Stores specified set of registers in memory, starting from address pointed by rx. Increasing addresses
