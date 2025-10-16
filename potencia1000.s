//==============================================================
// Autor: Juan Carmona con ChatGPT Tutor ARM64
// Descripción: Imprimir tabla de potencias de 2 que no exceda 1000
// Plataforma: Raspberry Pi 4 / Ubuntu ARM64
// Compilar:  as -o potencias2.o potencias2.s && ld -o potencias2 potencias2.o
// Ejecutar:  ./potencias2
//==============================================================

.section .data
buffer:   .space 32
igual:    .asciz " = "
pot:      .asciz "2^"
newline:  .asciz "\n"

.section .text
.global _start

_start:
    mov x19, #0              // exponente
    mov x20, #1              // valor actual = 2^0 = 1
    mov x21, #1000           // límite máximo

bucle:
    // --- imprimir "2^"
    mov x8, #64
    mov x0, #1
    adr x1, pot
    mov x2, #2
    svc #0

    // --- convertir exponente y mostrar
    mov x0, x19
    adr x1, buffer
    bl int_to_ascii
    mov x8, #64
    mov x0, #1
    mov x2, x9
    svc #0

    // --- imprimir " = "
    mov x8, #64
    mov x0, #1
    adr x1, igual
    mov x2, #3
    svc #0

    // --- convertir valor y mostrar
    mov x0, x20
    adr x1, buffer
    bl int_to_ascii
    mov x8, #64
    mov x0, #1
    mov x2, x9
    svc #0

    // --- salto de línea
    mov x8, #64
    mov x0, #1
    adr x1, newline
    mov x2, #1
    svc #0

    // siguiente potencia: valor *= 2
    lsl x20, x20, #1         // multiplica por 2
    add x19, x19, #1         // exponente++

    cmp x20, x21
    ble bucle                // mientras valor <= 1000

    // --- salir del programa
    mov x8, #93
    mov x0, #0
    svc #0


//--------------------------------------------------------------
// int_to_ascii: convierte entero en ASCII
// Entrada: x0=número, x1=buffer
// Salida:  x1 puntero al texto, x9 longitud
//--------------------------------------------------------------
int_to_ascii:
    add x1, x1, #15
    mov x9, #0

.conv:
    mov x2, #10
    udiv x3, x0, x2
    msub x4, x3, x2, x0
    add x4, x4, #'0'
    strb w4, [x1], #-1
    add x9, x9, #1
    mov x0, x3
    cbnz x0, .conv

    add x1, x1, #1
    ret
