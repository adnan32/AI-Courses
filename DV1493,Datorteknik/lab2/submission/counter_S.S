#Abdulkarim, Adnan
.data
counter:    .quad 0
GPIO:        .quad 0

    .text
    .global interrupt
    .global setup
interrupt:
    call     Counter
    call     pin1
    call     pin2
    call     pin3
    call     pin4
    ret

Counter:

    movq    counter,%rdx
    incq    %rdx
    cmpq    $0x10,%rdx
    je    dec
    movq    %rdx,counter
    ret
dec:
    movq    $0,%rdx
    movq     %rdx,counter
    ret
pin1:        #mask = 1000 = 0x08
    movq    counter, %r15
    andq    $0x08, %r15
    cmpq    $0x08, %r15
    movq    $1, %rdi
    je        high
    jne        low
    ret

pin2:        #mask = 0100 = 0x04
    movq    counter, %r15
    andq    $0x04, %r15
    cmpq    $0x04, %r15
    movq    $2, %rdi
    je        high
    jne        low
    ret
pin3:        #mask = 0010 = 0x02
    movq    counter, %r15
    andq    $0x02, %r15
    cmpq    $0x02, %r15
    movq    $3, %rdi
    je        high
    jne        low
    ret

pin4:        #mask = 0001 = 0x01
    movq    counter, %r15
    andq    $0x01, %r15
    cmpq    $0x01, %r15
    movq    $4, %rdi
    je        high
    jne        low
    ret

high: # gpio_addr + 3 |= ((0x3 << 4)+1) << (8(GPIO_NR-1))

    movq    GPIO,%r15
    addq    $3,%r15
    #__r15
    movq    $0x3,%r9
    salq    $0x04,%r9
    addq    $1,%r9
    #_r9
    subq    $1,%rdi
    imulq    $8,%rdi
    #_rdi
    movq    %rdi,%rcx
    salq    %cl,%r9
    movq    %r15,%rdi
    orq    %r9,(%rdi)
    ret

low: #*gpio_addr + 3 &= ~(0xCF << (8(GPIO_NR-1)))

    movq    GPIO,%r15
    addq    $3,%r15
    #__r15
    subq    $1,%rdi
    imulq    $8,%rdi
    #_rdi
    movq    $0xCF,%r11
    movq    %rdi,%rcx
    sal    %cl,%r11
    notq    %r11
    movq    %r15,%rdi
    andq    %r11,(%rdi)
    ret

setup:
    call    calc_addr
    movq    $0, %rdi
    call     in_put
    movq    $1, %rdi
    call     out_put
    movq    $2, %rdi
    call     out_put
    movq    $3, %rdi
    call     out_put
    movq    $4, %rdi
    call     out_put
    ret


calc_addr:
    #gpio_addr = ((0x60 << 16) | (0xFFFF & 0x1000) | (~(0x9E) & 0xFF))
    movq    $0x60,%rdx
    salq    $0x10,%rdx
    movq    $0x1000,%rsi
    andq    $0xFFFF,%rsi
    orq    %rdx,%rsi
    movq    $0x9E,%rdx
    notq    %rdx
    movq    $0xFF,%rdi
    andq    %rdx,%rdi
    orq    %rsi,%rdi
    movq    %rdi,GPIO
    ret

out_put:
    #(short)gpio_addr = gpio_addr | ( (0x2 << 6) << ((4-GPIO_NR)2) )
    movq    $0x02, %rdx
    salq    $0x06, %rdx
    movq    $4, %rcx
    subq    %rdi, %rcx 
    imulq    $2, %rcx 
    sal    %cl,%rdx 
    movq     GPIO, %rdi
    orq    %rdx,(%rdi)
    ret

in_put:
    #(short)gpio_addr + (GPIO_NR/8) |= 0x3 << ((((3-GPIO_NR)2) % 8)+8)

    movq    GPIO,%r11
    movq    %rdi,%rax
    movq    $8,%r15
    cqto
    divq    %r15
    addq    %rax,%r11
    #___r11
    movq    $3,%r10
    subq    %rdi,%r10
    imulq    $2,%r10
    movq    %r10,%rax
    movq    $8,%r10
    cqto
    divq    %r10
    addq    $8,%rdx
    #_rdx
    movq    $0x3,%r9
    movq    %rdx,%rcx
    sal    %cl,%r9
    orq    %r9,(%r11)
    ret
