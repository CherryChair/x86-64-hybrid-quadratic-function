    section .text

global drawQuadratic

drawQuadratic:
    push rbp
    mov rbp, rsp

    sub rsp, 56
    mov [rbp - 8], rdi      ;pixelBuffer
    mov [rbp - 12], esi     ;width
    mov [rbp - 16], edx     ;height
    movsd [rbp - 24], xmm0  ;a
    movsd [rbp - 32], xmm1  ;b
    movsd [rbp - 40], xmm2  ;c
    movsd [rbp - 48], xmm3  ;d
    movsd [rbp - 56], xmm4  ;scale

    ;x = -b/2a
    movsd xmm4, xmm1
    divsd xmm4, xmm0
    divsd xmm4, [rel two]
    mulsd xmm4, [rel negative]

    ;y = ax^2+bx+c
    movsd xmm5, xmm4
    mulsd xmm5, xmm0
    addsd xmm5, xmm1
    mulsd xmm5, xmm4
    addsd xmm5, xmm2

    

b_4_loop:

    ;x_l = x, x_r = x+d
    movsd xmm6, xmm4
    movsd xmm7, xmm4
    addsd xmm7, xmm3

    

loop1:
    ;x_c = (x_l+x_r)/2
    movsd xmm8, xmm6
    addsd xmm8, xmm7
    divsd xmm8, [rel two]

    ;y_c = ax_c^2+bx_c+
    movsd xmm9, xmm8
    mulsd xmm9, xmm0
    addsd xmm9, xmm1
    mulsd xmm9, xmm8
    addsd xmm9, xmm2

    ;(x_c-x)^2 + (y_c-y)^2
    movsd xmm10, xmm8
    subsd xmm10, xmm4
    mulsd xmm10, xmm10
    movsd xmm11, xmm9
    subsd xmm11, xmm5
    mulsd xmm11, xmm11
    addsd xmm10, xmm11

    ;d^2+epsilon, d^2-epsilon
    movsd xmm12, xmm3
    mulsd xmm12, xmm12
    movsd xmm13, xmm12

    addsd xmm12, [rel epsilon]
    subsd xmm13, [rel epsilon]




    ucomisd xmm10, xmm12
    ja left
    ucomisd xmm10, xmm13
    jb right
    jmp found


left:
    movsd xmm7, xmm8
    jmp loop1

right:
    movsd xmm6, xmm8
    jmp loop1



found:

    ;xmm6 = x_t, xmm7 = y_t
    ;xmm4 = x, xmm5 = y
    movsd xmm6, xmm8
    movsd xmm7, xmm9


    movsd xmm8, xmm4
    movsd xmm9, xmm5

    ;scale our coordinates
    mulsd xmm8, [rbp - 56]
    mulsd xmm9, [rbp - 56]

    ;convert to int
    cvtsd2si r8, xmm8
    cvtsd2si r9, xmm9

    

    movsd xmm10, xmm6
    movsd xmm11, xmm7

    ;scale our coordinates
    mulsd xmm10, [rbp - 56]
    mulsd xmm11, [rbp - 56]

    cvtsd2si r10, xmm10
    cvtsd2si r11, xmm11


    mov r12d, [rbp - 12]
    mov r13d, [rbp - 16]

    ;size of quadrants
    sar r12, 1
    sar r13, 1



draw:

    
    ;we count -b/2a
    movsd xmm12, xmm1
    divsd xmm12, xmm0
    divsd xmm12, [rel two]
    mulsd xmm12, [rel negative]

    ;we scale it and convert it
    mulsd xmm12, [rbp - 56]
    cvtsd2si r14, xmm12

    ;we move it to proper place
    add r14, r12

    add r8, r12
    add r9, r13
    add r10, r12
    add r11, r13

    sub rsp, 56
    mov [rbp - 64], r8      ;current x
    mov [rbp - 72], r9      ;current y
    mov [rbp - 80], r10     ;ending x
    mov [rbp - 88], r11     ;ending y
    mov [rbp - 96], r12    ;offset x
    mov [rbp - 104], r13    ;offset y
    mov [rbp - 112], r14    ;symmetrical


line:
    ucomisd xmm0, [rel zero]
    jb a_negative

a_positive:
    ;first possbile movement vector
    mov r8, 1
    mov r9, 1

    movsd xmm8, xmm6
    subsd xmm8, xmm4
    movsd xmm9, xmm7
    subsd xmm9, xmm5
    ucomisd xmm8, xmm9
    ja right_vector
    ;second possbile movement vector
    mov r10, 0
    mov r11, 1
    jmp find_line
a_negative:
    ;first possbile movement vector
    mov r8, 1
    mov r9, -1

    movsd xmm8, xmm6
    subsd xmm8, xmm4
    movsd xmm9, xmm5
    subsd xmm9, xmm7
    ucomisd xmm8, xmm9
    ja right_vector
    ;second possbile movement vector
    mov r10, 0
    mov r11, -1
    jmp find_line

right_vector:
    mov r10, 1
    mov r11, 0

find_line:
    

    ;a of the line (y_s-y_e)
    mov r12, [rbp - 72]
    mov r13, [rbp - 88]
    sub r12, [rbp - 88]
    ;b of the line (x_e-x_s)
	mov r14, [rbp - 64]
    mov r13, [rbp - 80]
    sub r13, [rbp - 64]

    ;c of the line   
	mov r15, [rbp - 80]
    imul r15, [rbp - 72]
    mov r14, [rbp - 64]
    imul r14, [rbp - 88]
    sub r14, r15    ;c

    sub rsp, 56
    mov [rbp - 120], r8     ;w1 x
    mov [rbp - 128], r9     ;w1 y
    mov [rbp - 136], r10    ;w2 x
    mov [rbp - 144], r11    ;w2 y
    mov [rbp - 152], r12    ;line a
    mov [rbp - 160], r13    ;line b
    mov [rbp - 168], r14    ;line c

draw_loop:

    mov r8, [rbp - 64]
    mov r9, [rbp - 72]
    ;we find symmetrical x
    mov r10, [rbp - 112]
    sal r10, 1
    sub r10, r8 
    ;we set up condition to paint symmetrical point
    mov r11, 2

color:
    ;we check whether height is not oob
    mov rax, 0
    mov eax, [rbp - 16]
    cmp rax, r9
    jle switch_point
    cmp r9, 0
    jl switch_point
    ;height
    mov r15, r9
    ;width
    mov eax, [rbp - 12]
    ;we check whether width is not oob
    cmp rax, r8
    jle switch_point
    cmp r8, 0
    jle switch_point
    ;width/8
    sar rax, 3
    ;offset to our desired line of file in byte array
    imul r15, rax
    ;line byte position
    mov rax, r8
    sar rax, 3
    ;byte offset
    add r15, rax
    add r15, 62
    ;desired bit
    mov rdx, rax
    sal rdx, 3
    sub r8, rdx
    ;get desired byte
    add r15, [rbp - 8]
    mov al, [r15]
    
    cmp r8, 0
    je case_0
    cmp r8, 1
    je case_1
    cmp r8, 2
    je case_2
    cmp r8, 3
    je case_3
    cmp r8, 4
    je case_4
    cmp r8, 5
    je case_5
    cmp r8, 6
    je case_6
    cmp r8, 7
    je case_7
case_0:
    and al, 0x7F
    jmp colored
case_1:
    and al, 0xBF
    jmp colored
case_2:
    and al, 0xDF
    jmp colored
case_3:
    and al, 0xEF
    jmp colored
case_4:
    and al, 0xF7
    jmp colored
case_5:
    and al, 0xFB
    jmp colored
case_6:
    and al, 0xFD
    jmp colored
case_7:
    and al, 0xFE
colored:
    mov [r15], al


switch_point:
    mov r8, r10
    dec r11
    cmp r11, 0
    jnz color
    
    ;we evaluate next possible 2 pixels
    mov r10, [rbp - 64]
    mov r11, [rbp - 72]
    add r10, [rbp - 120]
    add r11, [rbp - 128]
    imul r10, [rbp - 152]
    imul r11, [rbp - 160]
    add r10, r11
    add r10, [rbp - 168]

    cmp r10, 0
    jg second_pixel
    neg r10

second_pixel:
    mov r11, [rbp - 64]
    mov r12, [rbp - 72]
    add r11, [rbp - 136]
    add r12, [rbp - 144]
    imul r11, [rbp - 152]
    imul r12, [rbp - 160]
    add r11, r12
    add r11, [rbp - 168]

    cmp r11, 0
    jg compare
    neg r11

compare:
    cmp r10, r11
    jg second_closer

first_closer:
    mov r10, [rbp - 64]
    mov r11, [rbp - 72]
    add r10, [rbp - 120]
    add r11, [rbp - 128]
    jmp compare_to_next
    
second_closer:
    mov r10, [rbp - 64]
    mov r11, [rbp - 72]
    add r10, [rbp - 136]
    add r11, [rbp - 144]

compare_to_next:
    mov r8, [rbp - 64]
    mov r9, [rbp - 72]
    mov [rbp - 64], r10
    mov [rbp - 72], r11


cmpr:
    cmp r10, [rbp - 80]
    jne draw_loop
    cmp r11, [rbp - 88]
    jne draw_loop


finish_line:
    
    
    movsd xmm4, xmm6
    movsd xmm5, xmm7
    add rsp, 112

    mov r10, [rbp - 88]

    mov r11, 0
    mov r11d, [rbp - 16]

;we check if y passed our screen, if so, we stop drawing
    
b4_comp:
    ucomisd xmm0, [rel zero]
    ja parabola_upwards

    cmp r10, 0
    jl ending
    jmp b_4_loop

parabola_upwards:
    cmp r10, r11
    jg ending

    



    jmp b_4_loop

ending:
    

    mov rsp, rbp
    pop rbp
    ret

    section .data 
epsilon: dq 0.001
negative: dq -1.0
zero: dq 0.0
two: dq 2.0
four: dq 4.0