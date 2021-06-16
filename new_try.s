    section .text

extern printf
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
    mov r14, 100
   
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

    ;draw line between (r8, r9) and (r10, r11)
    
    movsd xmm4, xmm6
    movsd xmm5, xmm7
    dec r14
    jnz b_4_loop

end:
    mov rdi, coordinates
    mov eax, 2
    movsd xmm0, xmm4
    movsd xmm1, xmm5
    call printf
    mov rdi, [rbp - 8]
    mov esi, [rbp - 12]
    mov edx, [rbp - 16]
    movsd xmm0, [rbp - 24]
    movsd xmm1, [rbp - 32]
    movsd xmm2, [rbp - 40]
    movsd xmm3, [rbp - 48]
    mov eax, 4



    mov ecx, edx
    mov edx, esi
    mov rsi, rdi
    mov rdi, parameters
    call printf
    

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
coordinates: db `x: %g y: %g\n`,0