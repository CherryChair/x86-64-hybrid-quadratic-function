    section .text

extern printf
global drawQuadratic

drawQuadratic:
    push rbp
    mov rbp, rsp

    sub rsp, 48
    mov [rbp - 8], rdi
    mov [rbp - 12], esi
    mov [rbp - 16], edx
    movsd [rbp - 24], xmm0
    movsd [rbp - 32], xmm1
    movsd [rbp - 40], xmm2
    movsd [rbp - 48], xmm3
    mov rbx, 2
    mov rcx, 100

    

    ;rax = pPixelBuffer
    ;mov r8, [rbp + 16]
    ;rbx = witdh
    ;mov eax, [rbp + 20]
    ;rbx = height
    ;mov ebx, [rbp + 24]
    ;xmm0 = a
    ;movsd xmm0, [rbp + 32]
    ;xmm1 = b
    ;movsd xmm1, [rbp + 40]
    ;xmm2 = c
    ;movsd xmm2, [rbp + 48]
    ;xmm3 = S
    ;movsd xmm3, [rbp + 56]

    ;xmm4 - c_x current x
    ;xmm5 - c_y current y

    ;c_x = -b/2a

    movsd xmm4, xmm1
    ;negsd xmm4
    ;temporary
    mulsd xmm4, [rel negative]
    divsd xmm4, xmm0
    divsd xmm4, [rel two]

    ;c_y = (-b^2 + 4ac)/4a
    movsd xmm5, xmm1
    mulsd xmm5, xmm5
    ;negsd xmm5
    ;temporary
    mulsd xmm5, [rel negative]
    divsd xmm5, xmm0
    divsd xmm5, [rel four]
    addsd xmm5, xmm2

    ;we do bisection
    ;xmm6 - l_x left x
    ;xmm7 - r_x right x

    ;xmm8 - t_x center x
    ;xmm9 - t_y center y

loop1:
    dec rcx
    cmp rcx, 0
    je end
    ;l_x = c_x, r_x = c_x+s
    movsd xmm6, xmm4
    movsd xmm7, xmm4
    addsd xmm7, xmm3


loop2:
    
    ;t_x = (l_x+r_x)/2
    movsd xmm8, xmm6
    addsd xmm8, xmm7
    divsd xmm8, [rel two]

    ;t_y = a*t_x
    movsd xmm9, xmm0
    mulsd xmm9, xmm8
    ;t_y = a*t_x^2+b*t_x+c
    addsd xmm9, xmm1
    mulsd xmm9, xmm8
    addsd xmm9, xmm2


    ;xmm10 = (t_x-c_x)^2 + (t_y-c_y)^2
    movsd xmm10, xmm8
    movsd xmm11, xmm9
    subsd xmm10, xmm4
    subsd xmm11, xmm5
    mulsd xmm10, xmm10
    mulsd xmm11, xmm11 
    addsd xmm10, xmm11

    ;xmm11 = d^2
    movsd xmm11, xmm3
    mulsd xmm11, xmm11

    dec rbx
    cmp rbx, 0
    je draw

    ;t_x^2+t_y^2 - d^2
    subsd xmm10, xmm11
    comisd xmm10, [rel zero]
    ja go_left
    comisd xmm10, [rel zero]
    jb go_right
    
    jmp draw
    

go_right:
    movsd xmm7, xmm8
    jmp loop2
go_left:
    movsd xmm6, xmm8
    jmp loop2


draw:
    mov rdi, coordinates
    mov eax, 2
    movsd xmm0, xmm8
    movsd xmm1, xmm9
    call printf
    mov rdi, [rbp - 8]
    mov esi, [rbp - 12]
    mov edx, [rbp - 16]
    movsd xmm0, [rbp - 24]
    movsd xmm1, [rbp - 32]
    movsd xmm2, [rbp - 40]
    movsd xmm3, [rbp - 48]
    mov eax, 4
    jmp end

    mov rbx, 15
    movsd xmm4, xmm8
    movsd xmm5, xmm9
    cvtsi2sd xmm12, esi
    ucomisd xmm5, xmm12
    jb loop1

    

end:
    

    mov ecx, edx
    mov edx, esi
    mov rsi, rdi
    mov rdi, parameters
    call printf
    

    mov rsp, rbp
    pop rbp
    ret




    section .data 
epsilon: dq 0.1
neg_epsilon: dq -0.1
negative: dq -1.0
zero: dq 0.0
two: dq 2.0
four: dq 4.0
parameters: db `addr: %i width: %i height: %i a: %g b: %g c: %g S: %g\n`,0
coordinates: db `x: %g y: %g\n`,0