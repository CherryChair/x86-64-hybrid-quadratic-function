    section .text

global drawQuadratic

drawQuadratic:
    push rbp
    mov rbp, rsp

    sub rsp, 48
    mov [rbp - 8], rdi      ;pixelBuffer
    mov [rbp - 12], esi     ;width
    mov [rbp - 16], edx     ;height
    movsd [rbp - 24], xmm0  ;a
    movsd [rbp - 32], xmm1  ;b
    movsd [rbp - 40], xmm2  ;c
    movsd [rbp - 48], xmm3  ;d

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
    mov edx, [rbp - 16] ;potencjalnie do poprawy

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
    mulsd xmm8, [rel scale]
    mulsd xmm9, [rel scale]

    ;convert to int
    cvtsd2si r8, xmm8
    cvtsd2si r9, xmm9

    

    movsd xmm10, xmm6
    movsd xmm11, xmm7

    ;scale our coordinates
    mulsd xmm10, [rel scale]
    mulsd xmm11, [rel scale]

    cvtsd2si r10, xmm10
    cvtsd2si r11, xmm11


    mov r12, rsi
    mov r13, rdx

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
    mulsd xmm12, [rel scale]
    cvtsd2si r14, xmm12

    ;we move it to proper place
    add r14, r12

    add r8, r12
    add r9, r13
    add r10, r12
    add r11, r13

    sub rsp, 56
    mov [rbp - 72], r8      ;current x
    mov [rbp - 80], r9      ;current y
    mov [rbp - 88], r10     ;ending x
    mov [rbp - 96], r11     ;ending y
    mov [rbp - 104], r12    ;offset x
    mov [rbp - 112], r13    ;offset y
    mov [rbp - 120], r14    ;symmetrical


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
    mov r12, [rbp - 80]
    mov r13, [rbp - 96]
    sub r12, [rbp - 96]
    ;b of the line (x_e-x_s)
	mov r14, [rbp - 72]
    mov r13, [rbp - 88]
    sub r13, [rbp - 72]

    ;c of the line   
	mov r15, [rbp - 88]
    imul r15, [rbp - 80]
    mov r14, [rbp - 72]
    imul r14, [rbp - 96]
    sub r14, r15    ;c

    sub rsp, 56
    mov [rbp - 128], r8     ;w1 x
    mov [rbp - 136], r9     ;w1 y
    mov [rbp - 144], r10    ;w2 x
    mov [rbp - 152], r11    ;w2 y
    mov [rbp - 160], r12    ;line a
    mov [rbp - 168], r13    ;line b
    mov [rbp - 176], r14    ;line c

draw_loop:

    mov r8, [rbp - 72]
    mov r9, [rbp - 80]
    ;we find symmetrical x
    mov r10, [rbp - 120]
    sal r10, 1
    sub r10, r8 
    ;we set up condition to paint symmetrical point
    mov r11, 2

color:
    ;we check whether height is not oob
    mov rax, 0
    mov eax, [rbp - 12]
    cmp rax, r9
    jle switch_point
    cmp r9, 0
    jle switch_point
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
    mov r10, [rbp - 72]
    mov r11, [rbp - 80]
    add r10, [rbp - 128]
    add r11, [rbp - 136]
    imul r10, [rbp - 160]
    imul r11, [rbp - 168]
    add r10, r11
    add r10, [rbp - 176]

    cmp r10, 0
    jg second_pixel
    neg r10

second_pixel:
    mov r11, [rbp - 72]
    mov r12, [rbp - 80]
    add r11, [rbp - 144]
    add r12, [rbp - 152]
    imul r11, [rbp - 160]
    imul r12, [rbp - 168]
    add r11, r12
    add r11, [rbp - 176]

    cmp r11, 0
    jg compare
    neg r11

compare:
    cmp r10, r11
    jg second_closer

first_closer:
    mov r10, [rbp - 72]
    mov r11, [rbp - 80]
    add r10, [rbp - 128]
    add r11, [rbp - 136]
    jmp compare_to_next
    
second_closer:
    mov r10, [rbp - 72]
    mov r11, [rbp - 80]
    add r10, [rbp - 144]
    add r11, [rbp - 152]

compare_to_next:
    mov r8, [rbp - 72]
    mov r9, [rbp - 80]
    mov [rbp - 72], r10
    mov [rbp - 80], r11


cmpr:
    cmp r10, [rbp - 88]
    jne draw_loop
    cmp r11, [rbp - 96]
    jne draw_loop


finish_line:
    
    
    movsd xmm4, xmm6
    movsd xmm5, xmm7

    mov r10, [rbp - 88]
    mov r11, [rbp - 96]

    mov r12, 0
    mov r13, 0
    mov r12d, [rbp - 12]
    mov r13d, [rbp - 16]

    add rsp, 112
b4_comp:
    cmp r10, r12
    jg end
    cmp r10, 0
    jl end
    
    cmp r11, 0
    jg y_pos
    neg r11
    cmp r11, r13
    jg end
    neg r11
    jmp b_4_loop
y_pos:
    cmp r11, r13
    jg end


    jmp b_4_loop

end:
    

    mov rsp, rbp
    pop rbp
    ret

    section .data 
epsilon: dq 0.001
negative: dq -1.0
zero: dq 0.0
two: dq 2.0
four: dq 4.0
parameters: db `\naddr: %i width: %i height: %i a: %.1f b: %.1f c: %.1f S: %.1f\n`,0
scale: dq 10.0
coordinates: db `(%.5f, %.5f)\n`,0
pixels: db `Pixels: (%i, %i)\n`,0