    section .text

extern printf
global drawQuadratic

drawQuadratic:
    push rbp
    mov rbp, rsp

    sub rsp, 88
    mov [rbp - 8], rdi      ;pixelBuffer
    mov [rbp - 12], esi     ;width
    mov [rbp - 16], edx     ;height
    movsd [rbp - 24], xmm0  ;a
    movsd [rbp - 32], xmm1  ;b
    movsd [rbp - 40], xmm2  ;c
    movsd [rbp - 48], xmm3  ;d
    ;X_C x_s, y_s, x_e, y_e
   
    ;x = -b/2a
    movsd xmm4, xmm1
    divsd xmm4, xmm0
    divsd xmm4, [rel two]
    mulsd xmm4, [rel negative]
    movsd [rbp - 56], xmm4  ;X_C

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
    mulsd xmm8, [rel scale]
    mulsd xmm9, [rel scale]

    ;convert to int
    cvtsd2si r8, xmm4
    cvtsd2si r9, xmm5

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

    cmp r10, r12
    jg end
    
    cmp r11, 0
    jg y_pos
    neg r11
y_pos:
    cmp r11, r13
    jg end


draw:
    
    add r8, r12
    add r9, r13
    add r10, r12
    add r11, r13
    mov [rbp - 64], r8  ;x_s
    mov [rbp - 72], r9  ;y_s
    mov [rbp - 80], r10 ;x_e
    mov [rbp - 88], r11 ;y_e
;__________________________________________________________________________________
    ;draw line between (r8, r9) and (r10, r11)
color:
    
    
    ;height
    mov r15, 0
    mov r15d, [rbp- 16]
    sub r15, [rbp - 88]
    ;width
    mov eax, [rbp - 12]
    ;width/8
    sar rax, 3
    ;offset to our desired line of file in byte array
    imul r15, rax
    ;line byte position
    mov rax, [rbp - 80]
    sar rax, 3
    ;byte offset
    add r15, rax
    add r15, 62
    ;desired bit
    mov rdx, rax
    sal rdx, 3
    sub rdx, [rbp - 64]
    ;get desired byte
    add r15, [rbp - 8]

    mov al, [r15]

    
    cmp rdx, 0
    je case_0
    cmp rdx, 1
    je case_1
    cmp rdx, 2
    je case_2
    cmp rdx, 3
    je case_3
    cmp rdx, 4
    je case_4
    cmp rdx, 5
    je case_5
    cmp rdx, 6
    je case_6
    cmp rdx, 7
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
    
;__________________________________________________________________________________
    movsd xmm4, xmm6
    movsd xmm5, xmm7

    
    jmp b_4_loop

end:

    mov rdi, coordinates
    mov eax, 2
    movsd xmm0, xmm4
    movsd xmm1, xmm5
    ;call printf
    mov rdi, [rbp - 8]
    mov esi, [rbp - 12]
    mov edx, [rbp - 16]
    movsd xmm0, [rbp - 24]
    movsd xmm1, [rbp - 32]
    movsd xmm2, [rbp - 40]
    movsd xmm3, [rbp - 48]
    mov r8, [rbp - 64]
    mov r9, [rbp - 72]
    mov r10, [rbp - 80]
    mov r11, [rbp - 88]
    mov eax, 4



    mov ecx, edx
    mov edx, esi
    mov rsi, rdi
    mov rdi, parameters
    ;call printf
    

    mov rsp, rbp
    pop rbp
    ret




    section .data 
epsilon: dq 0.001
negative: dq -1.0
zero: dq 0.0
two: dq 2.0
four: dq 4.0
parameters: db `addr: %i width: %i height: %i a: %g b: %g c: %g S: %g\n`,0
scale: dq 10.0
coordinates: db `x: %f y: %f\n`,0
message: db "Hello world", 10