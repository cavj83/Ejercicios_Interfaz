//==============================================================
// Autor: Juan Carmona ChatGPT Tutor ARM64
// Descripción: Imprimir los enteros del 1 al 30 apareados con sus recíprocos
// Plataforma: Raspberry Pi 4 / Ubuntu ARM64
// Compilar:  as -o reciproco1to30.o reciproco1to30.s && ld -o reciproco1to30 reciproco1to30.o
// Ejecutar:  ./reciproco1to30
//==============================================================

.section .data
buffer:        .space 64
newline:       .asciz "\n"
arrow:         .asciz " -> "
punto:         .asciz "."
float_millon:  .double 1000000.0

.section .text
.global _start

_start:
    mov x19, #1
    mov x20, #30

loop:
    //------------------------------------
    // Imprimir número entero
    //------------------------------------
    mov x0, x19
    adr x1, buffer
    bl int_to_ascii
    // x1 = dirección de texto, x9 = longitud
    mov x8, #64
    mov x0, #1
    mov x2, x9
    svc #0

    // Imprimir " -> "
    mov x8, #64
    mov x0, #1
    adr x1, arrow
    mov x2, #4
    svc #0

    //------------------------------------
    // Calcular recíproco (1.0 / n)
    //------------------------------------
    scvtf d0, x19       // d0 = float(n)
    fmov  d1, #1.0
    fdiv  d0, d1, d0    // d0 = 1.0 / n

    //------------------------------------
    // Convertir d0 a texto decimal
    //------------------------------------
    adr x1, buffer
    bl float_to_ascii

    // Imprimir recíproco
    mov x8, #64
    mov x0, #1
    mov x2, x9
    svc #0

    // Salto de línea
    mov x8, #64
    mov x0, #1
    adr x1, newline
    mov x2, #1
    svc #0

    //------------------------------------
    // Siguiente número
    //------------------------------------
    add x19, x19, #1
    cmp x19, x20
    ble loop

    //------------------------------------
    // Salir
    //------------------------------------
    mov x8, #93
    mov x0, #0
    svc #0


//--------------------------------------------------------------
// int_to_ascii: convierte entero positivo a cadena
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
// float_to_ascii: convierte número double en texto con 6 decimales
//--------------------------------------------------------------
float_to_ascii:
    // parte entera
    fcvtzu x0, d0
    adr x1, buffer
    bl int_to_ascii

    // imprimir punto
    mov x8, #64
