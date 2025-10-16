//==============================================================
// Autor: ChatGPT Tutor ARM64
// Descripción: Imprime los enteros del 1 al 30 apareados con sus recíprocos.
// Plataforma: Raspberry Pi 4 / Ubuntu 64-bit (AArch64)
// Compilar:  as -o reciproco1to30.o reciproco1to30.s && ld -o reciproco1to30 reciproco1to30.o
// Ejecutar:  ./reciproco1to30
//==============================================================

.section .data
buffer:        .space 64
newline:       .asciz "\n"
arrow:         .asciz " -> "
punto:         .asciz "."
.align 3
float_millon:  .double 1000000.0   // constante usada para 6 decimales

.section .text
.global _start

_start:
    mov x19, #1          // número inicial
    mov x20, #30         // número final

loop:
    //----------------------------------------------------------
    // Imprimir número entero
    //----------------------------------------------------------
    mov x0, x19
    adr x1, buffer
    bl int_to_ascii
    // salida: x1 = inicio texto, x9 = longitud

    // syscall write(stdout, buffer, longitud)
    mov x8, #64
    mov x0, #1
    mov x2, x9
    svc #0

    // imprimir " -> "
    mov x8, #64
    mov x0, #1
    adr x1, arrow
    mov x2, #4
    svc #0

    //----------------------------------------------------------
    // Calcular recíproco: 1.0 / n
    //----------------------------------------------------------
    scvtf d0, x19       // d0 = float(n)
    fmov  d1, #1.0
    fdiv  d0, d1, d0    // d0 = 1.0 / n

    //----------------------------------------------------------
    // Convertir recíproco a texto con 6 decimales
    //----------------------------------------------------------
    adr x1, buffer
    bl float_to_ascii

    // imprimir resultado
    mov x8, #64
    mov x0, #1
    mov x2, x9
    svc #0

    // salto de línea
    mov x8, #64
    mov x0, #1
    adr x1, newline
    mov x2, #1
    svc #0

    //----------------------------------------------------------
    // siguiente número
    //----------------------------------------------------------
    add x19, x19, #1
    cmp x19, x20
    ble loop

    //----------------------------------------------------------
    // salir del programa
    //----------------------------------------------------------
    mov x8, #93
    mov x0, #0
    svc #0


//--------------------------------------------------------------
// int_to_ascii: convierte entero positivo a cadena ASCII
// Entrada: x0 = número, x1 = buffer
// Salida:  x1 = inicio texto, x9 = longitud
//--------------------------------------------------------------
int_to_ascii:
    add x1, x1, #15
    mov x9, #0
.int_loop:
    mov x2, #10
    udiv x3, x0, x2
    msub x4, x3, x2, x0
    add x4, x4, #'0'
    strb w4, [x1], #-1
    add x9, x9, #1
    mov x0, x3
    cbnz x0, .int_loop
    add x1, x1, #1
    ret


//--------------------------------------------------------------
// float_to_ascii: convierte número double a texto con 6 decimales
//--------------------------------------------------------------
float_to_ascii:
    // parte entera
    fcvtzu x0, d0           // x0 = parte entera
    adr x1, buffer
    bl int_to_ascii

    // imprimir punto decimal
    mov x8, #64
    mov x0, #1
    adr x1, punto
    mov x2, #1
    svc #0

    // obtener parte fraccional * 1,000,000
    fcvtzu x2, d0           // x2 = entero(d0)
    scvtf d1, x2
    fsub d0, d0, d1         // d0 = parte fraccional
    ldr x3, =float_millon
    ldr d1, [x3]
    fmul d0, d0, d1         // d0 = d0 * 1,000,000
    fcvtzu x0, d0           // x0 = entero(fracción * 1e6)

    // convertir decimales a texto
    adr x1, buffer
    bl int_to_ascii
    ret
