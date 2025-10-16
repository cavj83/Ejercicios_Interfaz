//==============================================================
// Autor:Juan Carmona con ChatGPT Tutor ARM64
// Descripción: Imprimir los enteros del 1 al 30 apareados con sus recíprocos
// Plataforma: Raspberry Pi 4 / Ubuntu 64-bit (AArch64)
// Compilar:  as -o reciprocos.o reciprocos.s && ld -o reciprocos reciprocos.o
// Ejecutar:  ./reciprocos
//==============================================================

.section .data
num_buffer:    .space 16
float_buffer:  .space 32
newline:       .asciz "\n"
arrow:         .asciz " -> "

.section .text
.global _start

_start:
    mov x19, #1            // número inicial
    mov x20, #30           // número final

bucle:
    //------------------------------------
    // Convertir número entero a texto
    //------------------------------------
    mov x0, x19
    adr x1, num_buffer
    bl int_to_ascii        // convierte entero → ASCII
    // salida: x9 = longitud, x1 = dirección del texto

    // imprimir número
    mov x8, #64
    mov x0, #1             // stdout
    mov x2, x9
    svc #0

    // imprimir flecha " -> "
    mov x8, #64
    mov x0, #1
    adr x1, arrow
    mov x2, #4
    svc #0

    //------------------------------------
    // Calcular recíproco en punto flotante
    //------------------------------------
    scvtf d0, x19          // d0 = float(x19)
    fmov d1, #1.0
    fdiv d0, d1, d0        // d0 = 1.0 / d0

    //------------------------------------
    // Convertir d0 (float) a texto ASCII
    //------------------------------------
    adr x1, float_buffer
    bl float_to_ascii

    // imprimir recíproco
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

    //------------------------------------
    // siguiente número
    //------------------------------------
    add x19, x19, #1
    cmp x19, x20
    ble bucle

    //------------------------------------
    // salir
    //------------------------------------
    mov x8, #93
    mov x0, #0
    svc #0


//--------------------------------------------------------------
// int_to_ascii: convierte número entero en ASCII
// x0 = número, x1 = buffer, salida: x1 inicio texto, x9 longitud
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
// float_to_ascii: convierte un float (d0) en texto decimal
// Muy simple: muestra hasta 6 decimales
//--------------------------------------------------------------
float_to_ascii:
    // obtener parte entera
    fcvtzu x2, d0           // x2 = (int)d0
    adr x1, float_buffer
    bl int_to_ascii

    // imprimir punto decimal
    mov x8, #64
    mov x0, #1
    adr x1, punto
    mov x2, #1
    svc #0

    // procesar 6 decimales
    movz x2, #0x4240
    movk x2, #0xF, lsl #16
    scvtf d1, x2
    fmul d0, d0, d1
    fcvtzu x0, d0
    adr x1, float_buffer
    bl int_to_ascii
    ret

.section .data
punto: .asciz "."
