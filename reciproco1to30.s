//==============================================================
// Autor: Juan Carmona con ChatGPT Tutor ARM64
// Descripción: Imprimir los enteros del 1 al 30 apareados con sus recíprocos
// Plataforma: Raspberry Pi 4 / Ubuntu ARM64
// Compilar:  as -o reciproco1to30.o reciproco1to30.s && ld -o reciproco1to30 reciproco1to30.o
// Ejecutar:  ./reciproco1to30
//==============================================================

.section .data
num_buffer:     .space 32
float_buffer:   .space 64
newline:        .asciz "\n"
arrow:          .asciz " -> "
punto:          .asciz "."
float_millon:   .double 1000000.0        // ← constante segura

.section .text
.global _start

_start:
    mov x19, #1              // número inicial
    mov x20, #30             // número final

bucle:
    //----------------------------------------------------------
    // 1. Imprimir número entero
    //----------------------------------------------------------
    mov x0, x19
    adr x1, num_buffer
    bl int_to_ascii
    // x1 = dirección de texto, x9 = longitud

    // escribir número
    mov x8, #64
    mov x0, #1
    mov x2, x9
    svc #0

    // imprimir flecha " -> "
    mov x8, #64
    mov x0, #1
    adr x1, arrow
    mov x2, #4
    svc #0

    //----------------------------------------------------------
    // 2. Calcular recíproco: 1.0 / n
    //----------------------------------------------------------
    scvtf d0, x19          // d0 = float(n)
    fmov  d1, #1.0
    fdiv  d0, d1, d0       // d0 = 1.0 / n

    //----------------------------------------------------------
    // 3. Convertir recíproco a texto (6 decimales)
    //----------------------------------------------------------
    adr x1, float_buffer
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
    // 4. siguiente número
    //----------------------------------------------------------
    add x19, x19, #1
    cmp x19, x20
    ble bucle

    //----------------------------------------------------------
    // 5. salir del programa
    //----------------------------------------------------------
    mov x8, #93
    mov x0, #0
    svc #0


//--------------------------------------------------------------
// int_to_ascii: convierte entero positivo en texto ASCII
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
// float_to_ascii: convierte d0 (float) a texto decimal
// muestra 6 decimales
//--------------------------------------------------------------
float_to_ascii:
    // parte entera
    fcvtzu x2, d0           // x2 = (int)d0
    adr x1, float_buffer
    bl int_to_ascii

    // imprimir punto decimal
    mov x8, #64
    mov x0, #1
    adr x1, punto
    mov x2, #1
    svc #0

    // multiplicar por 1 000 000 para obtener decimales
    ldr x1, =float_millon   // ✅ cargar dirección en registro general
    ldr d1, [x1]            // ✅ cargar valor double 1000000.0
    fmul d0, d0, d1
    fcvtzu x0, d0           // x0 = entero(d0 * 1000000)

    // convertir decimales a texto
    adr x1, float_buffer
    bl int_to_ascii
    ret
